/// ATEM UDP packet structure and encoding/decoding.
library atem_packet;

import 'dart:typed_data';

/// ATEM UDP protocol flags.
class AtemPacketFlags {
  static const int reliable = 0x01;
  static const int syn = 0x02;
  static const int retransmission = 0x04;
  static const int requestRetransmission = 0x08;
  static const int ack = 0x10;

  static bool isReliable(int flags) => (flags & reliable) != 0;
  static bool isSyn(int flags) => (flags & syn) != 0;
  static bool isRetransmission(int flags) => (flags & retransmission) != 0;
  static bool isRequestRetransmission(int flags) =>
      (flags & requestRetransmission) != 0;
  static bool isAck(int flags) => (flags & ack) != 0;
}

/// ATEM UDP packet.
class AtemPacket {
  static const int headerSize = 12;
  static const int maxDataSize = 1300; // MTU safe size

  int flags = 0;
  int length = 0;
  int session = 0;
  int sequenceNumber = 0;
  int acknowledgementNumber = 0;
  int remoteSequenceNumber = 0;
  Uint8List? data;

  AtemPacket();

  /// Creates a packet from raw bytes.
  static AtemPacket fromBytes(Uint8List bytes) {
    if (bytes.length < headerSize) {
      throw ArgumentError('Packet too short: ${bytes.length} < $headerSize');
    }

    final packet = AtemPacket();
    final view = ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.length);

    // First 2 bytes: length (11 bits) + flags (5 bits)
    final firstWord = view.getUint16(0);
    packet.length = firstWord & 0x07FF;
    packet.flags = (firstWord >> 11) & 0x1F;

    // Validate length
    if (packet.length != bytes.length) {
      throw FormatException(
          'Packet length mismatch: header says ${packet.length}, actual ${bytes.length}');
    }

    packet.session = view.getUint16(2);
    packet.acknowledgementNumber = view.getUint16(4);
    packet.remoteSequenceNumber = view.getUint16(6);
    // Bytes 8-9 are reserved. The packet sequence number is the final
    // 16-bit field in the 12-byte ATEM UDP header.
    packet.sequenceNumber = view.getUint16(10);

    if (packet.length > headerSize) {
      packet.data = bytes.sublist(headerSize);
    }

    return packet;
  }

  /// Encodes the packet to bytes.
  Uint8List toBytes() {
    final dataLen = data?.length ?? 0;
    final packetLen = headerSize + dataLen;
    final buffer = ByteData(packetLen);

    // Length (11 bits) + flags (5 bits)
    buffer.setUint16(0, (packetLen & 0x07FF) | ((flags & 0x1F) << 11));
    buffer.setUint16(2, session);
    buffer.setUint16(4, acknowledgementNumber);
    buffer.setUint16(6, remoteSequenceNumber);
    // Bytes 8-9 are reserved and remain zero.
    buffer.setUint16(10, sequenceNumber);

    if (data != null && data!.isNotEmpty) {
      buffer.buffer.asUint8List().setRange(headerSize, packetLen, data!);
    }

    return buffer.buffer.asUint8List();
  }

  /// Creates a SYN packet for connection initiation.
  static AtemPacket createSyn({int sessionId = 0x1337}) {
    final packet = AtemPacket();
    packet.flags = AtemPacketFlags.syn;
    packet.session = sessionId;
    packet.data = Uint8List.fromList([
      0x01,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
    ]);
    return packet;
  }

  /// Creates an ACK packet.
  static AtemPacket createAck({
    required int session,
    required int ackNumber,
    required int remoteSequence,
  }) {
    final packet = AtemPacket();
    packet.flags = AtemPacketFlags.ack;
    packet.session = session;
    packet.acknowledgementNumber = ackNumber;
    packet.remoteSequenceNumber = remoteSequence;
    return packet;
  }

  /// Creates a data packet.
  static AtemPacket createData({
    required int session,
    required int sequenceNumber,
    required int ackNumber,
    required int remoteSequence,
    required Uint8List data,
    bool reliable = true,
  }) {
    final packet = AtemPacket();
    packet.flags = reliable ? AtemPacketFlags.reliable : 0;
    packet.session = session;
    packet.sequenceNumber = sequenceNumber;
    packet.acknowledgementNumber = ackNumber;
    packet.remoteSequenceNumber = remoteSequence;
    packet.data = data;
    return packet;
  }

  @override
  String toString() {
    final flagStr = <String>[];
    if (AtemPacketFlags.isReliable(flags)) {
      flagStr.add('RELIABLE');
    }
    if (AtemPacketFlags.isSyn(flags)) {
      flagStr.add('SYN');
    }
    if (AtemPacketFlags.isRetransmission(flags)) {
      flagStr.add('RETRANS');
    }
    if (AtemPacketFlags.isRequestRetransmission(flags)) {
      flagStr.add('REQ_RETRANS');
    }
    if (AtemPacketFlags.isAck(flags)) {
      flagStr.add('ACK');
    }

    return 'AtemPacket(flags: [${flagStr.join(', ')}], '
        'len: ${data?.length ?? 0}, seq: $sequenceNumber, '
        'ack: $acknowledgementNumber, remoteSeq: $remoteSequenceNumber, '
        'session: 0x${session.toRadixString(16).padLeft(4, '0')})';
  }
}
