import 'package:blackmagicdesign/blackmagicdesign.dart';
import 'package:test/test.dart';

void main() {
  group('HyperDeck', () {
    tearDown(HyperDeck.close);

    test('requires a connection before sending commands', () {
      expect(HyperDeck.record, throwsStateError);
    });

    test('parses transport information', () {
      HyperDeck.dataHandler(
          '500 transport info:\nstatus: play\nspeed: 100\nslot id: 1\nclip id: 2\ndisplay timecode: 00:00:01:00\ntimecode: 00:00:01:00\nvideo format: 1080p25\nloop: false\ntimeline: true\ninput video format: 1080p25\n'
              .codeUnits);

      expect(HyperDeck.deviceStatus, 'play');
      expect(HyperDeck.clipId, '2');
      expect(HyperDeck.videoFormat, '1080p25');
    });

    test('builds single-line commands with all parameters', () {
      expect(
        HyperDeckCommand.single('play', {
          'clip id': 3,
          'speed': 100,
          'loop': true,
        }),
        'play: clip id: 3 speed: 100 loop: true\n',
      );
    });

    test('builds multiline commands', () {
      expect(
        HyperDeckCommand.multiline('nas add', {'url': 'smb://nas/media'}),
        'nas add:\nurl: smb://nas/media\n\n',
      );
    });

    test('uses the documented multiline authentication operation', () {
      expect(
        HyperDeckCommand.multiline('authenticate', {
          'username': 'operator',
          'password': 'secret',
        }),
        'authenticate:\nusername: operator\npassword: secret\n\n',
      );
    });
  });
}
