/// ATEM connection and protocol handling.
library atem_connection;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:collection';

import '../transport/atem_packet.dart';
import '../field/atem_fields.dart';
import '../command/atem_commands.dart';
import '../state/atem_state.dart';

/// ATEM connection events.
sealed class AtemEvent {}

class AtemConnected extends AtemEvent {}

class AtemDisconnected extends AtemEvent {
  AtemDisconnected([this.reason]);
  final String? reason;
}

class AtemError extends AtemEvent {
  AtemError(this.error, this.stackTrace);
  final Object error;
  final StackTrace stackTrace;
}

class AtemStateChanged extends AtemEvent {
  AtemStateChanged(this.state);
  final AtemState state;
}

class AtemPacketReceived extends AtemEvent {
  AtemPacketReceived(this.packet);
  final AtemPacket packet;
}

/// ATEM connection configuration.
class AtemConnectionConfig {
  const AtemConnectionConfig({
    this.host = '192.168.1.10',
    this.port = 9910,
    this.timeout = const Duration(seconds: 5),
    this.keepAliveInterval = const Duration(seconds: 1),
    this.reconnect = false,
    this.reconnectInterval = const Duration(seconds: 5),
  });

  final String host;
  final int port;
  final Duration timeout;
  final Duration keepAliveInterval;
  final bool reconnect;
  final Duration reconnectInterval;
}

/// Main ATEM connection class.
class AtemConnection {
  AtemConnection({AtemConnectionConfig? config})
      : _config = config ?? const AtemConnectionConfig();

  final AtemConnectionConfig _config;
  RawDatagramSocket? _socket;
  StreamSubscription<RawSocketEvent>? _socketSubscription;
  final StreamController<AtemEvent> _events = StreamController.broadcast();

  // Protocol state
  int _sessionId = 0x1337;
  int _localSequence = -1;
  int _localAck = 0;
  int _remoteSequence = 0;
  bool _enableAck = false;
  bool _connected = false;

  // Reliability
  final Map<int, AtemPacket> _retransmissionBuffer = {};
  final Queue<AtemPacket> _sendQueue = Queue();

  // Timers
  Timer? _keepAliveTimer;
  Timer? _retransmitTimer;
  Timer? _reconnectTimer;
  Timer? _queueFlushTimer;

  // State
  final AtemState _state = AtemState();

  // Pending commands
  final Map<int, Completer<AtemPacket>> _pendingCommands = {};

  Stream<AtemEvent> get events => _events.stream;
  AtemState get state => _state;
  bool get isConnected => _connected;

  /// Connects to the ATEM switcher.
  Future<void> connect() async {
    if (_connected) return;

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
          .timeout(_config.timeout);

      _socketSubscription = _socket!.listen(_onSocketEvent);

      // Start handshake
      _sendSyn();

      // Start keepalive
      _startKeepAlive();

      // Start retransmission timer
      _startRetransmitTimer();
    } catch (e, st) {
      _events.add(AtemError(e, st));
      rethrow;
    }
  }

  /// Disconnects from the ATEM switcher.
  Future<void> disconnect() async {
    _stopTimers();
    _socketSubscription?.cancel();
    _socket?.close();
    _connected = false;
    _state.setConnected(false);
    await _events.close();
  }

  /// Sends a command to the switcher.
  Future<AtemPacket?> sendCommand(AtemCommand command,
      {bool reliable = true}) async {
    if (!_connected) throw StateError('Not connected');

    final data = command.toBytes();
    final packet = _createDataPacket(data, reliable: reliable);

    if (reliable) {
      final completer = Completer<AtemPacket>();
      _pendingCommands[packet.sequenceNumber] = completer;
      _sendPacket(packet);
      try {
        return await completer.future.timeout(_config.timeout);
      } finally {
        _pendingCommands.remove(packet.sequenceNumber);
        _retransmissionBuffer.remove(packet.sequenceNumber);
      }
    } else {
      _sendPacket(packet);
      return null;
    }
  }

  /// Sends multiple commands in a single packet.
  Future<void> sendCommands(List<AtemCommand> commands,
      {bool reliable = true}) async {
    if (!_connected) throw StateError('Not connected');

    final builder = BytesBuilder();
    for (final cmd in commands) {
      builder.add(cmd.toBytes());
    }

    if (builder.length > 1300) {
      throw ArgumentError('Command packet too large: ${builder.length} bytes');
    }

    final packet = _createDataPacket(builder.toBytes(), reliable: reliable);
    _sendPacket(packet);
  }

  /// Sends raw data.
  void sendRaw(Uint8List data, {bool reliable = true}) {
    if (!_connected) throw StateError('Not connected');
    final packet = _createDataPacket(data, reliable: reliable);
    _sendPacket(packet);
  }

  /// Sets program input for an ME.
  Future<void> setProgramInput(int meIndex, int source) async {
    await sendCommand(ProgramInputCommand(meIndex: meIndex, source: source));
  }

  /// Sets preview input for an ME.
  Future<void> setPreviewInput(int meIndex, int source) async {
    await sendCommand(PreviewInputCommand(meIndex: meIndex, source: source));
  }

  /// Performs a cut on an ME.
  Future<void> cut(int meIndex) async {
    await sendCommand(CutCommand(meIndex: meIndex));
  }

  /// Performs an auto transition on an ME.
  Future<void> autoTransition(int meIndex) async {
    await sendCommand(AutoTransitionCommand(meIndex: meIndex));
  }

  /// Sets key on air state.
  Future<void> setKeyOnAir(int meIndex, int keyerIndex, bool onAir) async {
    await sendCommand(KeyOnAirCommand(
      meIndex: meIndex,
      keyerIndex: keyerIndex,
      onAir: onAir,
    ));
  }

  /// Sets key properties.
  Future<void> setKeyProperties({
    required int meIndex,
    required int keyerIndex,
    int? keyType,
    bool? enabled,
    bool? flyEnabled,
    int? fillSource,
    int? keySource,
    bool? maskEnabled,
    int? maskTop,
    int? maskBottom,
    int? maskLeft,
    int? maskRight,
  }) async {
    await sendCommand(KeyPropertiesBaseCommand(
      meIndex: meIndex,
      keyerIndex: keyerIndex,
      keyType: keyType,
      enabled: enabled,
      flyEnabled: flyEnabled,
      fillSource: fillSource,
      keySource: keySource,
      maskEnabled: maskEnabled,
      maskTop: maskTop,
      maskBottom: maskBottom,
      maskLeft: maskLeft,
      maskRight: maskRight,
    ));
  }

  /// Sets aux output source.
  Future<void> setAuxSource(int auxIndex, int source) async {
    await sendCommand(AuxSourceCommand(auxIndex: auxIndex, source: source));
  }

  /// Sets color generator.
  Future<void> setColorGenerator(int index,
      {int? hue, int? saturation, int? luminance}) async {
    await sendCommand(ColorGeneratorCommand(
      index: index,
      hue: hue,
      saturation: saturation,
      luminance: luminance,
    ));
  }

  /// Sets fade to black.
  Future<void> setFadeToBlack(int meIndex, {int? rate}) async {
    await sendCommand(FadeToBlackCommand(meIndex: meIndex, rate: rate));
  }

  /// Executes fade to black.
  Future<void> executeFadeToBlack(int meIndex, bool onAir) async {
    await sendCommand(
        FadeToBlackExecuteCommand(meIndex: meIndex, onAir: onAir));
  }

  /// Sets transition settings.
  Future<void> setTransition({
    required int meIndex,
    int? type,
    int? duration,
    int? style,
  }) async {
    // Build transition settings command
    // TODO: Implement TransitionSettingsCommand
  }

  /// Requests a time (keepalive).
  void sendTimeRequest() {
    sendRaw(_buildTimeRequest(), reliable: true);
  }

  Uint8List _buildTimeRequest() {
    // TiRq command (empty)
    return Uint8List.fromList([0x54, 0x69, 0x52, 0x71]);
  }

  // Private methods

  void _onSocketEvent(RawSocketEvent event) {
    switch (event) {
      case RawSocketEvent.read:
        _onRead();
        break;
      case RawSocketEvent.write:
        _flushSendQueue();
        break;
      case RawSocketEvent.closed:
        _onDisconnected('Socket closed');
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
      _events.add(AtemPacketReceived(packet));
      _handlePacket(packet);
    } catch (e, st) {
      _events.add(AtemError(e, st));
    }
  }

  void _handlePacket(AtemPacket packet) {
    // Update session ID from first packet
    if (_sessionId == 0x1337 && packet.session != 0x1337) {
      _sessionId = packet.session;
    }

    // Handle SYN
    if (AtemPacketFlags.isSyn(packet.flags)) {
      if (packet.data != null && packet.data!.isNotEmpty) {
        final responseCode = packet.data![0];
        if (responseCode == 0x02) {
          _connected = true;
          _enableAck = true;
          _state.setConnected(true);
          _events.add(AtemConnected());
        }
      }

      // Send ACK for SYN
      final ack = AtemPacket.createAck(
        session: _sessionId,
        ackNumber: packet.sequenceNumber,
        remoteSequence: 0,
      );
      _sendRaw(ack);
      return;
    }

    // Handle ACK
    if (AtemPacketFlags.isAck(packet.flags)) {
      _handleAck(packet);
    }

    // Handle retransmission request
    if (AtemPacketFlags.isRequestRetransmission(packet.flags)) {
      _handleRetransmissionRequest(packet);
    }

    // Handle data
    if (packet.data != null && packet.data!.isNotEmpty) {
      // Send ACK if reliable
      if (AtemPacketFlags.isReliable(packet.flags) && _enableAck) {
        final ack = AtemPacket.createAck(
          session: _sessionId,
          ackNumber: packet.sequenceNumber,
          remoteSequence: _remoteSequence,
        );
        _sendRaw(ack);
      }

      _remoteSequence = packet.sequenceNumber;
      _localAck = packet.sequenceNumber;

      // Parse fields
      _parseFields(packet.data!);
    }
  }

  void _handleAck(AtemPacket packet) {
    final ackedSeq = packet.acknowledgementNumber;
    _retransmissionBuffer.remove(ackedSeq);

    // Complete pending commands
    final completer = _pendingCommands.remove(ackedSeq);
    completer?.complete(packet);
  }

  void _handleRetransmissionRequest(AtemPacket packet) {
    final requestedSeq = packet.remoteSequenceNumber;
    final buffered = _retransmissionBuffer[requestedSeq];
    if (buffered != null) {
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

  void _parseFields(Uint8List data) {
    int offset = 0;
    while (offset + 8 <= data.length) {
      final view = ByteData.view(data.buffer, data.offsetInBytes + offset, 8);
      final fieldLength = view.getUint16(0);
      final fieldCode =
          String.fromCharCodes(data.sublist(offset + 4, offset + 8));

      if (fieldLength < 8 || offset + fieldLength > data.length) {
        break; // Malformed field
      }

      final fieldData = data.sublist(offset + 8, offset + fieldLength);
      final field = parseAtemField(fieldCode, fieldData);

      // Update state based on field
      _updateStateFromField(field);

      offset += fieldLength;
    }
  }

  void _updateStateFromField(AtemField field) {
    switch (field) {
      case ProgramInputField f:
        _state.setProgramInput(f.meIndex, f.source);
        break;
      case PreviewInputField f:
        _state.setPreviewInput(f.meIndex, f.source);
        break;
      case VideoModeField f:
        _state.setVideoMode(f.videoMode);
        break;
      case AutoInputVideoModeField f:
        _state.setAutoVideoMode(f.enabled, f.detected);
        break;
      case TransitionPositionField f:
        final trans = _state.transitions[f.meIndex] ?? TransitionState();
        _state.updateTransition(
            f.meIndex, trans.copyWith(position: f.position));
        break;
      case TransitionPreviewField f:
        final trans = _state.transitions[f.meIndex] ?? TransitionState();
        _state.updateTransition(f.meIndex, trans.copyWith(preview: f.preview));
        break;
      case TransitionSettingsField f:
        final trans = _state.transitions[f.meIndex] ?? TransitionState();
        _state.updateTransition(
            f.meIndex,
            trans.copyWith(
              type: f.type,
              style: f.style,
              rate: f.rate,
            ));
        break;
      case InputPropertiesField _:
        // Store input name mapping
        break;
      case KeyOnAirField f:
        _state.keyers[f.meIndex]?[f.keyerIndex];
        // Update onAir
        break;
      case KeyPropertiesBaseField f:
        _state.keyers[f.meIndex]?[f.keyerIndex];
        // Update keyer properties
        break;
      case AuxSourceField f:
        _state.setAuxSource(f.auxIndex, f.source);
        break;
      case ColorGeneratorField _:
        // Update color generator
        break;
      case ProductIdField f:
        _state.setProductInfo(f.model, f.productName, '');
        break;
      case FirmwareVersionField f:
        _state.setProductInfo(
            _state.productModel, _state.productName, f.versionString);
        break;
      case TopologyField f:
        _state.setTopology(Topology(
          meCount: f.meCount,
          keyerCount: f.keyerCount,
          dskCount: f.dskCount,
          auxCount: f.auxCount,
          mediaPlayerCount: f.mediaPlayerCount,
          superSourceCount: f.superSourceCount,
          multiviewerCount: f.multiviewerCount,
          audioMixerChannels: f.audioMixerChannels,
        ));
        break;
      case InitCompleteField _:
        // Initial state dump complete
        _events.add(AtemStateChanged(_state));
        break;
    }
  }

  AtemPacket _createDataPacket(Uint8List data, {required bool reliable}) {
    int seq;
    if (_localSequence == -1) {
      _localSequence = 0;
    }
    seq = (_localSequence + 1) % 65536;
    _localSequence = seq;

    return AtemPacket.createData(
      session: _sessionId,
      sequenceNumber: seq,
      ackNumber: _localAck,
      remoteSequence: _remoteSequence,
      data: data,
      reliable: reliable,
    );
  }

  void _sendSyn() {
    final syn = AtemPacket.createSyn(sessionId: _sessionId);
    _sendRaw(syn);
  }

  void _sendRaw(AtemPacket packet) {
    final bytes = packet.toBytes();
    _socket?.send(bytes, InternetAddress(_config.host), _config.port);
  }

  void _sendPacket(AtemPacket packet) {
    if (AtemPacketFlags.isReliable(packet.flags)) {
      _retransmissionBuffer[packet.sequenceNumber] = packet;
    }
    _sendQueue.add(packet);
    _flushSendQueue();
  }

  void _flushSendQueue() {
    while (_sendQueue.isNotEmpty) {
      final packet = _sendQueue.removeFirst();
      _sendRaw(packet);
    }
  }

  void _startKeepAlive() {
    _keepAliveTimer = Timer.periodic(_config.keepAliveInterval, (_) {
      if (_connected) {
        sendTimeRequest();
      }
    });
  }

  void _startRetransmitTimer() {
    _retransmitTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _retransmitUnacked();
    });
  }

  void _retransmitUnacked() {
    for (final entry in _retransmissionBuffer.entries) {
      final packet = entry.value;
      if (packet.flags & AtemPacketFlags.retransmission == 0) {
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
  }

  void _stopTimers() {
    _keepAliveTimer?.cancel();
    _retransmitTimer?.cancel();
    _reconnectTimer?.cancel();
    _queueFlushTimer?.cancel();
  }

  void _onDisconnected(String? reason) {
    _connected = false;
    _enableAck = false;
    _state.setConnected(false);
    _stopTimers();
    _events.add(AtemDisconnected(reason));

    if (_config.reconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer = Timer(_config.reconnectInterval, () {
      if (!_connected) {
        connect().catchError((e) {
          _events.add(AtemError(e, StackTrace.current));
        });
      }
    });
  }
}
