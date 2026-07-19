/// ATEM UDP packet structure.
///
/// The ATEM protocol uses a custom UDP-based protocol with sequence numbers,
/// acknowledgments, and reliability flags.
library atem_packet_internal;

import 'dart:typed_data';

/// ATEM protocol packet flags.
class AtemPacketFlags {
  static const int reliable = 1 << 0;
  static const int syn = 1 << 1;
  static const int retransmission = 1 << 2;
  static const int requestRetransmission = 1 << 3;
  static const int ack = 1 << 4;
}

/// ATEM UDP packet.
class AtemPacket {
  AtemPacket({
    this.flags = 0,
    this.length = 0,
    this.session = 0,
    this.sequenceNumber = 0,
    this.acknowledgementNumber = 0,
    this.remoteSequenceNumber = 0,
    Uint8List? data,
  }) : data = data ?? Uint8List(0);

  int flags;
  int length;
  int session;
  int sequenceNumber;
  int acknowledgementNumber;
  int remoteSequenceNumber;
  Uint8List data;

  /// Header size in bytes (12 bytes).
  static const int headerSize = 12;

  /// Creates an AtemPacket from raw bytes.
  factory AtemPacket.fromBytes(Uint8List bytes) {
    if (bytes.length < headerSize) {
      throw ArgumentError('Packet too short for header');
    }

    final header = ByteData.view(bytes.buffer, bytes.offsetInBytes, headerSize);

    // First 2 bytes: length (11 bits) + flags (5 bits)
    final firstWord = header.getUint16(0, Endian.big);
    final length = firstWord & 0x07FF;
    final flags = (firstWord >> 11) & 0x1F;

    if (length != bytes.length) {
      throw FormatException(
          'Incomplete or corrupt packet: header says $length but data length is ${bytes.length}');
    }

    final session = header.getUint16(2, Endian.big);
    final acknowledgementNumber = header.getUint16(4, Endian.big);
    final remoteSequenceNumber = header.getUint16(6, Endian.big);
    final sequenceNumber = header.getUint16(8, Endian.big);

    final data =
        bytes.length > headerSize ? bytes.sublist(headerSize) : Uint8List(0);

    return AtemPacket(
      flags: flags,
      length: length,
      session: session,
      sequenceNumber: sequenceNumber,
      acknowledgementNumber: acknowledgementNumber,
      remoteSequenceNumber: remoteSequenceNumber,
      data: data,
    );
  }

  /// Serializes the packet to bytes.
  Uint8List toBytes() {
    final dataLen = data.length;
    final packetLen = headerSize + dataLen;

    final buffer = ByteData(headerSize + dataLen);

    // First word: length (11 bits) | flags (5 bits)
    buffer.setUint16(
        0, (packetLen & 0x07FF) | ((flags & 0x1F) << 11), Endian.big);
    buffer.setUint16(2, session, Endian.big);
    buffer.setUint16(4, acknowledgementNumber, Endian.big);
    buffer.setUint16(6, remoteSequenceNumber, Endian.big);
    buffer.setUint16(8, sequenceNumber, Endian.big);

    if (dataLen > 0) {
      buffer.buffer.asUint8List(headerSize).setAll(0, data);
    }

    return buffer.buffer.asUint8List();
  }

  /// Creates a SYN packet for connection initiation.
  factory AtemPacket.syn({
    required int session,
    required int sequenceNumber,
  }) {
    return AtemPacket(
      flags: AtemPacketFlags.syn | AtemPacketFlags.reliable,
      session: session,
      sequenceNumber: sequenceNumber,
      data: Uint8List(0),
    );
  }

  /// Creates an ACK packet.
  factory AtemPacket.ack({
    required int session,
    required int sequenceNumber,
    required int acknowledgementNumber,
  }) {
    return AtemPacket(
      flags: AtemPacketFlags.ack | AtemPacketFlags.reliable,
      session: session,
      sequenceNumber: sequenceNumber,
      acknowledgementNumber: acknowledgementNumber,
      data: Uint8List(0),
    );
  }

  /// Creates a data packet with payload.
  factory AtemPacket.data({
    required int session,
    required int sequenceNumber,
    required int acknowledgementNumber,
    required Uint8List data,
    bool reliable = true,
  }) {
    int flags = reliable ? AtemPacketFlags.reliable : 0;
    return AtemPacket(
      flags: flags,
      session: session,
      sequenceNumber: sequenceNumber,
      acknowledgementNumber: acknowledgementNumber,
      data: data,
    );
  }

  /// Creates a retransmission request packet.
  factory AtemPacket.retransmissionRequest({
    required int session,
    required int sequenceNumber,
    required int remoteSequenceNumber,
    required int acknowledgementNumber,
  }) {
    return AtemPacket(
      flags: AtemPacketFlags.reliable | AtemPacketFlags.requestRetransmission,
      session: session,
      sequenceNumber: sequenceNumber,
      acknowledgementNumber: acknowledgementNumber,
      remoteSequenceNumber: remoteSequenceNumber,
      data: Uint8List(0),
    );
  }

  bool get isSyn => (flags & AtemPacketFlags.syn) != 0;
  bool get isAck => (flags & AtemPacketFlags.ack) != 0;
  bool get isReliable => (flags & AtemPacketFlags.reliable) != 0;
  bool get isRetransmission => (flags & AtemPacketFlags.retransmission) != 0;
  bool get isRetransmissionRequest =>
      (flags & AtemPacketFlags.requestRetransmission) != 0;
  bool get hasData => data.isNotEmpty;

  @override
  String toString() {
    final flagsStr = <String>[];
    if (isSyn) flagsStr.add('SYN');
    if (isAck) flagsStr.add('ACK');
    if (isReliable) flagsStr.add('RELIABLE');
    if (isRetransmission) flagsStr.add('RETRANSMISSION');
    if (isRetransmissionRequest) flagsStr.add('REQ_RETRANS');

    return 'AtemPacket(flags: [${flagsStr.join(', ')}], '
        'seq: $sequenceNumber, ack: $acknowledgementNumber, '
        'remoteSeq: $remoteSequenceNumber, session: $session, '
        'data: ${data.length} bytes)';
  }
}
