/// Command builder for ATEM protocol.
library atem_command_builder;

import 'dart:typed_data';

/// Builder for ATEM command payloads.
class AtemCommandBuilder {
  final BytesBuilder _buffer = BytesBuilder();

  /// Adds a uint8 value.
  AtemCommandBuilder addUint8(int value) {
    _buffer.addByte(value & 0xFF);
    return this;
  }

  /// Adds a uint16 value (big endian).
  AtemCommandBuilder addUint16(int value) {
    _buffer.addByte((value >> 8) & 0xFF);
    _buffer.addByte(value & 0xFF);
    return this;
  }

  /// Adds a uint32 value (big endian).
  AtemCommandBuilder addUint32(int value) {
    _buffer.addByte((value >> 24) & 0xFF);
    _buffer.addByte((value >> 16) & 0xFF);
    _buffer.addByte((value >> 8) & 0xFF);
    _buffer.addByte(value & 0xFF);
    return this;
  }

  /// Adds an int8 value.
  AtemCommandBuilder addInt8(int value) {
    _buffer.addByte(value & 0xFF);
    return this;
  }

  /// Adds an int16 value (big endian).
  AtemCommandBuilder addInt16(int value) {
    _buffer.addByte((value >> 8) & 0xFF);
    _buffer.addByte(value & 0xFF);
    return this;
  }

  /// Adds an int32 value (big endian).
  AtemCommandBuilder addInt32(int value) {
    _buffer.addByte((value >> 24) & 0xFF);
    _buffer.addByte((value >> 16) & 0xFF);
    _buffer.addByte((value >> 8) & 0xFF);
    _buffer.addByte(value & 0xFF);
    return this;
  }

  /// Adds a boolean value (1 byte).
  AtemCommandBuilder addBool(bool value) {
    _buffer.addByte(value ? 1 : 0);
    return this;
  }

  /// Adds padding bytes.
  AtemCommandBuilder addPadding(int count) {
    _buffer.add(List.filled(count, 0));
    return this;
  }

  /// Adds raw bytes.
  AtemCommandBuilder addBytes(Uint8List bytes) {
    _buffer.add(bytes);
    return this;
  }

  /// Builds the final Uint8List.
  Uint8List build() => _buffer.toBytes();
}
