import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:blackmagicdesign/atem/src/command/atem_command.dart';
import 'package:blackmagicdesign/atem/src/command/atem_command_builder.dart';
import 'package:blackmagicdesign/atem/src/command/atem_commands_impl.dart';
import 'package:blackmagicdesign/atem/src/transport/atem_packet.dart';

void main() {
  group('AtemCommandBuilder', () {
    test('builds uint8', () {
      final builder = AtemCommandBuilder().addUint8(0xFF);
      expect(builder.build(), [0xFF]);
    });

    test('builds uint16 big endian', () {
      final builder = AtemCommandBuilder().addUint16(0x1234);
      expect(builder.build(), [0x12, 0x34]);
    });

    test('builds uint32 big endian', () {
      final builder = AtemCommandBuilder().addUint32(0x12345678);
      expect(builder.build(), [0x12, 0x34, 0x56, 0x78]);
    });

    test('builds bool', () {
      expect(AtemCommandBuilder().addBool(true).build(), [0x01]);
      expect(AtemCommandBuilder().addBool(false).build(), [0x00]);
    });

    test('adds padding', () {
      final builder = AtemCommandBuilder().addUint8(0x01).addPadding(3);
      expect(builder.build(), [0x01, 0x00, 0x00, 0x00]);
    });

    test('chains multiple values', () {
      final builder = AtemCommandBuilder()
          .addUint8(0x01)
          .addUint16(0x0203)
          .addBool(true)
          .addPadding(2);
      expect(builder.build(), [0x01, 0x02, 0x03, 0x01, 0x00, 0x00]);
    });
  });

  group('ProgramInputCommand (CPgI)', () {
    test('builds correct payload for ME 0, source 1', () {
      const cmd = ProgramInputCommand(meIndex: 0, source: 1);
      final data = cmd.data;

      expect(data[0], 0); // meIndex
      expect(data[1], 0); // padding
      expect(data[2], 0); // source high byte
      expect(data[3], 1); // source low byte
      expect(cmd.code, 'CPgI');
    });

    test('builds with different ME index', () {
      const cmd = ProgramInputCommand(meIndex: 1, source: 5);
      final data = cmd.data;

      expect(data[0], 1); // meIndex
      expect(data[2], 0); // source high byte
      expect(data[3], 5); // source low byte
    });

    test('builds with source 1000', () {
      const cmd = ProgramInputCommand(meIndex: 0, source: 1000);
      final data = cmd.data;

      // 1000 = 0x03E8
      expect(data[2], 0x03);
      expect(data[3], 0xE8);
    });
  });

group('PreviewInputCommand (CPvI)', () {
    test('builds correct payload for ME 0, source 2', () {
      const cmd = PreviewInputCommand(meIndex: 0, source: 2);
      final data = cmd.data;

      expect(data[0], 0); // meIndex
      expect(data[1], 0); // padding
      expect(data[2], 0); // source high byte
      expect(data[3], 2); // source low byte
      expect(cmd.code, 'CPvI');
    });

    test('builds with ME index 2, source 10', () {
      const cmd = PreviewInputCommand(meIndex: 2, source: 10);
      final data = cmd.data;

      expect(data[0], 2);
      expect(data[3], 10);
      expect(cmd.code, 'CPvI');
    });
  });

  group('CutCommand (CTPr)', () {
    test('builds correct payload for ME 0', () {
      const cmd = CutCommand(meIndex: 0);
      final data = cmd.data;

      expect(data[0], 0); // meIndex
      expect(data[1], 0); // padding
      expect(data[2], 0); // padding
      expect(data[3], 0); // padding
      expect(cmd.code, 'CTPr');
    });

    test('builds with ME index 1', () {
      const cmd = CutCommand(meIndex: 1);
      expect(cmd.data[0], 1);
    });

    test('builds with ME index 3', () {
      const cmd = CutCommand(meIndex: 3);
      expect(cmd.data[0], 3);
    });
  });

  group('ATEM command records', () {
    test('includes the ATEM command record header', () {
      const command = CutCommand(meIndex: 0);

      expect(command.toBytes(), [
        0x00, 0x0C, // record length: header (8) + payload (4)
        0x00, 0x00, // reserved
        0x43, 0x54, 0x50, 0x72, // CTPr
        0x00, 0x00, 0x00, 0x00, // ME 0 and padding
      ]);
    });

    test('packs and unpacks multiple command records', () {
      final payload = packCommands(const [
        CutCommand(meIndex: 0),
        AutoTransitionCommand(meIndex: 1),
      ]);

      final commands = unpackCommands(payload);
      expect(commands, hasLength(2));
      expect(commands[0].code, 'CTPr');
      expect(commands[0].data, [0, 0, 0, 0]);
      expect(commands[1].code, 'ATPr');
      expect(commands[1].data, [1, 0, 0, 0]);
    });
  });

  group('AutoTransitionCommand (ATPr)', () {
    test('builds correct payload for ME 0', () {
      const cmd = AutoTransitionCommand(meIndex: 0);
      final data = cmd.data;

      expect(data[0], 0); // meIndex
      expect(data[1], 0); // padding
      expect(data[2], 0); // padding
      expect(data[3], 0); // padding
      expect(cmd.code, 'ATPr');
    });

    test('builds with ME index 1', () {
      const cmd = AutoTransitionCommand(meIndex: 1);
      expect(cmd.data[0], 1);
    });
  });

  group('KeyOnAirCommand (KeOn)', () {
    test('builds key on air on for ME 0, keyer 0', () {
      const cmd = KeyOnAirCommand(meIndex: 0, keyerIndex: 0, onAir: true);
      final data = cmd.data;

      expect(data[0], 0); // meIndex
      expect(data[1], 0); // keyerIndex
      expect(data[2], 1); // onAir = true
      expect(data[3], 0); // padding
      expect(cmd.code, 'KeOn');
    });

    test('builds key on air off', () {
      const cmd = KeyOnAirCommand(meIndex: 0, keyerIndex: 1, onAir: false);
      final data = cmd.data;

      expect(data[0], 0); // meIndex
      expect(data[1], 1); // keyerIndex
      expect(data[2], 0); // onAir = false
      expect(cmd.code, 'KeOn');
    });

    test('builds for ME 1, keyer 2', () {
      const cmd = KeyOnAirCommand(meIndex: 1, keyerIndex: 2, onAir: true);
      final data = cmd.data;

      expect(data[0], 1);
      expect(data[1], 2);
      expect(data[2], 1);
    });
  });

  group('FadeToBlackCommand (FtbP)', () {
    test('builds with rate', () {
      const cmd = FadeToBlackCommand(meIndex: 0, rate: 100);
      final data = cmd.data;

      expect(data[0], 1); // mask = 1 (rate present)
      expect(data[1], 0); // padding
      expect(data[2], 0); // meIndex
      expect(data[3], 0); // rate high byte
      expect(data[4], 100); // rate low byte
      expect(cmd.code, 'FtbP');
    });

    test('builds without rate', () {
      const cmd = FadeToBlackCommand(meIndex: 1);
      final data = cmd.data;

      expect(data[0], 0); // mask = 0 (no rate)
      expect(data[2], 1); // meIndex
      expect(cmd.code, 'FtbP');
    });

    test('builds with max rate', () {
      const cmd = FadeToBlackCommand(meIndex: 0, rate: 65535);
      final data = cmd.data;

      expect(data[3], 0xFF);
      expect(data[4], 0xFF);
    });
  });

  group('FadeToBlackExecuteCommand (FtbS)', () {
    test('builds execute on for ME 0', () {
      const cmd = FadeToBlackExecuteCommand(meIndex: 0, onAir: true);
      final data = cmd.data;

      expect(data[0], 0); // meIndex
      expect(data[1], 1); // onAir = true
      expect(data[2], 0); // padding
      expect(data[3], 0); // padding
      expect(cmd.code, 'FtbS');
    });

    test('builds execute off', () {
      const cmd = FadeToBlackExecuteCommand(meIndex: 1, onAir: false);
      final data = cmd.data;

      expect(data[0], 1); // meIndex
      expect(data[1], 0); // onAir = false
      expect(cmd.code, 'FtbS');
    });
  });

  group('AuxSourceCommand (AuxS)', () {
    test('builds correct payload', () {
      const cmd = AuxSourceCommand(auxIndex: 0, source: 1);
      final data = cmd.data;

      expect(data[0], 0); // auxIndex
      expect(data[1], 0); // padding
      expect(data[2], 0); // source high byte
      expect(data[3], 1); // source low byte
      expect(cmd.code, 'AuxS');
    });

    test('builds with aux 5, source 100', () {
      const cmd = AuxSourceCommand(auxIndex: 5, source: 100);
      final data = cmd.data;

      expect(data[0], 5);
      expect(data[2], 0);
      expect(data[3], 100);
    });
  });

  group('ColorGeneratorCommand (ColV)', () {
    test('builds with all values', () {
      const cmd = ColorGeneratorCommand(
        index: 0,
        hue: 100,
        saturation: 200,
        luminance: 300,
      );
      final data = cmd.data;

      expect(data[0], 7); // mask: hue | saturation | luminance (0b111)
      expect(data[1], 0); // padding
      expect(data[2], 0); // index
      expect(data[3], 0); // hue high
      expect(data[4], 100); // hue low
      expect(data[5], 0); // saturation high
      expect(data[6], 200); // saturation low
      expect(data[7], 1); // luminance high
      expect(data[8], 44); // luminance low (300 = 0x012C)
      expect(cmd.code, 'ColV');
    });

    test('builds with only hue', () {
      const cmd = ColorGeneratorCommand(index: 1, hue: 50);
      final data = cmd.data;

      expect(data[0], 1); // mask: hue only (0b001)
      expect(data[2], 1); // index
    });

    test('builds with hue and saturation', () {
      const cmd = ColorGeneratorCommand(
        index: 2,
        hue: 100,
        saturation: 200,
      );
      final data = cmd.data;

      expect(data[0], 3); // mask: hue | saturation (0b011)
      expect(data[2], 2); // index
    });
  });

  group('KeyPropertiesBaseCommand (KeBP)', () {
    test('builds with all fields', () {
      const cmd = KeyPropertiesBaseCommand(
        meIndex: 0,
        keyerIndex: 0,
        keyType: 1,
        enabled: true,
        flyEnabled: false,
        fillSource: 10,
        keySource: 20,
        maskEnabled: true,
        maskTop: 100,
        maskBottom: 200,
        maskLeft: 50,
        maskRight: 150,
      );
      final data = cmd.data;

      expect(data.length, greaterThan(0));
      expect(cmd.code, 'KeBP');
    });

    test('builds with only required fields', () {
      const cmd = KeyPropertiesBaseCommand(
        meIndex: 1,
        keyerIndex: 0,
      );
      final data = cmd.data;

      expect(data[0], 0); // mask = 0 (no optional fields)
      expect(data[1], 0); // mask high byte = 0
      expect(data[2], 1); // meIndex
      expect(data[3], 0); // keyerIndex
      expect(cmd.code, 'KeBP');
    });
  });

  group('AtemPacket', () {
    test('encodes and decodes SYN packet', () {
      final syn = AtemPacket.createSyn(sessionId: 0x1234);
      final bytes = syn.toBytes();
      final decoded = AtemPacket.fromBytes(bytes);

      expect(decoded.flags, AtemPacketFlags.syn);
      expect(decoded.session, 0x1234);
      expect(decoded.sequenceNumber, 0);
      expect(decoded.acknowledgementNumber, 0);
      expect(decoded.remoteSequenceNumber, 0);
    });

    test('encodes and decodes ACK packet', () {
      final ack = AtemPacket.createAck(
        session: 0x1337,
        ackNumber: 5,
        remoteSequence: 3,
      );
      final bytes = ack.toBytes();
      final decoded = AtemPacket.fromBytes(bytes);

      expect(decoded.flags, AtemPacketFlags.ack);
      expect(decoded.session, 0x1337);
      expect(decoded.acknowledgementNumber, 5);
      expect(decoded.remoteSequenceNumber, 3);
    });

    test('encodes and decodes data packet', () {
      final data = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
      final pkt = AtemPacket.createData(
        session: 0x1337,
        sequenceNumber: 10,
        ackNumber: 5,
        remoteSequence: 3,
        data: data,
        reliable: true,
      );
      final bytes = pkt.toBytes();
      final decoded = AtemPacket.fromBytes(bytes);

      expect(AtemPacketFlags.isReliable(decoded.flags), true);
      expect(decoded.session, 0x1337);
      expect(decoded.sequenceNumber, 10);
      expect(decoded.acknowledgementNumber, 5);
      expect(decoded.remoteSequenceNumber, 3);
      expect(decoded.data, data);
    });

    test('stores the sequence number in the final header field', () {
      final packet = AtemPacket.createData(
        session: 0x1337,
        sequenceNumber: 0x1234,
        ackNumber: 0,
        remoteSequence: 0,
        data: Uint8List(0),
      );

      expect(packet.toBytes().sublist(8, 12), [0x00, 0x00, 0x12, 0x34]);
    });

    test('round-trips data packet without reliability flag', () {
      final data = Uint8List.fromList([0x10, 0x20, 0x30]);
      final pkt = AtemPacket.createData(
        session: 0xABCD,
        sequenceNumber: 100,
        ackNumber: 50,
        remoteSequence: 25,
        data: data,
        reliable: false,
      );
      final bytes = pkt.toBytes();
      final decoded = AtemPacket.fromBytes(bytes);

      expect(AtemPacketFlags.isReliable(decoded.flags), false);
      expect(decoded.session, 0xABCD);
      expect(decoded.sequenceNumber, 100);
      expect(decoded.data, data);
    });

    test('validates packet length', () {
      // Create a packet with mismatched length
      final bytes = Uint8List(12);
      bytes[0] = 0x00; // length high (0x0020 = 32, but actual is 12)
      bytes[1] = 0x20;
      // Fill rest with zeros
      expect(() => AtemPacket.fromBytes(bytes), throwsFormatException);
    });
  });
}
