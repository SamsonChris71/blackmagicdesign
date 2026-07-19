/// ATEM UDP transport layer with reliability, sequencing, and retransmission.
library atem_udp_transport;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:collection';
import 'atem_packet.dart';

/// Events from the UDP transport.
sealed class AtemTransportEvent {}

class AtemTransportData extends AtemTransportEvent {
  AtemTransportData(this.packet);
  final AtemPacket packet;
}

class AtemTransportConnected extends AtemTransportEvent {}

class AtemTransportDisconnected extends AtemTransportEvent {
  AtemTransportDisconnected([this.reason]);
  final String? reason;
}

class AtemTransportError extends AtemTransportEvent {
  AtemTransportError(this.error, this.stackTrace);
  final Object error;
  final StackTrace stackTrace;
}

/// UDP transport for ATEM protocol.
class AtemUdpTransport {
  AtemUdpTransport({
    required this.host,
    this.port = 9910,
    this.timeout = const Duration(seconds: 5),
  });

  final String host;
  final int port;
  final Duration timeout;

  RawDatagramSocket? _socket;
  StreamSubscription<RawSocketEvent>? _subscription;
  final StreamController<AtemTransportEvent> _events =
      StreamController<AtemTransportEvent>.broadcast();
  final Queue<AtemPacket> _sendQueue = Queue<AtemPacket>();
  final Map<int, AtemPacket> _retransmissionBuffer = {};

  int _localSequence = -1;
  int _localAck = 0;
  int _remoteSequence = 0;
  int _sessionId = 0x1337;
  bool _enableAck = false;
  bool _connected = false;
  bool _closed = false;

  Timer? _keepAliveTimer;
  Timer? _retransmitTimer;

  /// Stream of transport events.
  Stream<AtemTransportEvent> get events => _events.stream;

  bool get isConnected => _connected;
  bool get isClosed => _closed;

  /// Connects to the ATEM switcher.
  Future<void> connect() async {
    if (_connected || _closed) return;

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .timeout(timeout);

    _subscription = _socket!.listen(_onSocketEvent);

    // Start connection handshake
    _sendSyn();
  }

  /// Sends a packet.
  void sendPacket(AtemPacket packet) {
    if (_closed) return;

    if (packet.flags & AtemPacketFlags.reliable != 0) {
      // Assign sequence number for reliable packets
      if (_localSequence == -1) _localSequence = 0;
      packet.sequenceNumber = (_localSequence + 1) % 65536;
      _localSequence = packet.sequenceNumber;

      // Store for potential retransmission
      _retransmissionBuffer[_localSequence] = packet;
    }

    _sendQueue.add(packet);
    _flushQueue();
  }

  /// Sends raw data as a reliable packet.
  void sendData(Uint8List data, {bool reliable = true}) {
    final packet = AtemPacket.createData(
      session: _sessionId,
      sequenceNumber: 0, // Will be assigned in sendPacket
      ackNumber: _localAck,
      remoteSequence: _remoteSequence,
      data: data,
      reliable: reliable,
    );
    sendPacket(packet);
  }

  /// Closes the connection.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    _keepAliveTimer?.cancel();
    _retransmitTimer?.cancel();
    _subscription?.cancel();
    _socket?.close();

    await _events.close();
    _connected = false;
  }

  void _onSocketEvent(RawSocketEvent event) {
    switch (event) {
      case RawSocketEvent.read:
        _onRead();
        break;
      case RawSocketEvent.write:
        _flushQueue();
        break;
      case RawSocketEvent.closed:
        _events.add(AtemTransportDisconnected('Socket closed'));
        break;
      default:
        break;
    }
  }

  void _onRead() {
    final datagram = _socket!.receive();
    if (datagram == null) return;

    try {
      final packet = AtemPacket.fromBytes(datagram.data);
      _handlePacket(packet);
    } catch (e, st) {
      _events.add(AtemTransportError(e, st));
    }
  }

  void _handlePacket(AtemPacket packet) {
    // Update session ID from first packet
    if (_sessionId == 0x1337 && packet.session != 0x1337) {
      _sessionId = packet.session;
    }

    // Handle SYN handshake
    if (AtemPacketFlags.isSyn(packet.flags)) {
      if (packet.data != null && packet.data!.isNotEmpty) {
        final responseCode = packet.data![0];
        if (responseCode == 0x02) {
          _connected = true;
          _enableAck = true;
          _events.add(AtemTransportConnected());
          _startKeepAlive();
          _startRetransmitTimer();
        }
      }

      // Send ACK for SYN
      final ack = AtemPacket.createAck(
        session: _sessionId,
        ackNumber: packet.sequenceNumber,
        remoteSequence: 0x61,
      );
      _sendRaw(ack);
      return;
    }

    // Handle ACK
    if (AtemPacketFlags.isAck(packet.flags)) {
      _handleAck(packet);
      return;
    }

    // Handle retransmission request
    if (AtemPacketFlags.isRequestRetransmission(packet.flags)) {
      _handleRetransmissionRequest(packet);
      return;
    }

    // Handle data packets
    if (packet.data != null && packet.data!.isNotEmpty) {
      // Send ACK if reliable
      if (AtemPacketFlags.isReliable(packet.flags) && _enableAck) {
        final ack = AtemPacket.createAck(
          session: _sessionId,
          ackNumber: packet.sequenceNumber,
          remoteSequence: 0,
        );
        _sendRaw(ack);
      }

      // Update remote sequence
      _remoteSequence = packet.sequenceNumber;
      _localAck = packet.acknowledgementNumber;

      // Deliver data
      _events.add(AtemTransportData(packet));
    }
  }

  void _handleAck(AtemPacket packet) {
    // Remove acknowledged packets from retransmission buffer
    final ackedSeq = packet.acknowledgementNumber;
    _retransmissionBuffer.remove(ackedSeq);
  }

  void _handleRetransmissionRequest(AtemPacket packet) {
    final requestedSeq = packet.remoteSequenceNumber;
    final buffered = _retransmissionBuffer[requestedSeq];
    if (buffered != null) {
      // Retransmit with retransmission flag
      final retransmit = AtemPacket.createData(
        session: _sessionId,
        sequenceNumber: buffered.sequenceNumber,
        ackNumber: _localAck,
        remoteSequence: _remoteSequence,
        data: buffered.data!,
        reliable: true,
      );
      retransmit.flags |= AtemPacketFlags.retransmission;
      _sendRaw(retransmit);
    }
  }

  void _sendSyn() {
    final syn = AtemPacket.createSyn(sessionId: _sessionId);
    _sendRaw(syn);
  }

  void _sendRaw(AtemPacket packet) {
    final bytes = packet.toBytes();
    _socket?.send(bytes, InternetAddress(host), port);
  }

  void _flushQueue() {
    while (_sendQueue.isNotEmpty) {
      final packet = _sendQueue.removeFirst();
      _sendRaw(packet);
    }
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_connected || _closed) return;

      // Send time request as keepalive
      final timeReq = _buildTimeRequest();
      sendData(timeReq, reliable: true);
    });
  }

  void _startRetransmitTimer() {
    _retransmitTimer?.cancel();
    _retransmitTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_closed) return;

      // Retransmit unacknowledged packets
      for (final entry in _retransmissionBuffer.entries) {
        // Simple retransmission after timeout
        final packet = entry.value;
        if (packet.flags & AtemPacketFlags.retransmission == 0) {
          // First retransmission
          final retransmit = AtemPacket.createData(
            session: _sessionId,
            sequenceNumber: packet.sequenceNumber,
            ackNumber: _localAck,
            remoteSequence: _remoteSequence,
            data: packet.data!,
            reliable: true,
          );
          retransmit.flags |= AtemPacketFlags.retransmission;
          _sendRaw(retransmit);
        }
      }
    });
  }

  Uint8List _buildTimeRequest() {
    // TiRq command (empty)
    return Uint8List.fromList([0x54, 0x69, 0x52, 0x71, 0x00, 0x00, 0x00, 0x00]);
  }
}
