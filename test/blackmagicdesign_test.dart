import 'package:blackmagicdesign/blackmagicdesign.dart';
import 'package:test/test.dart';

void main() {
  group('HyperDeck', () {
    tearDown(HyperDeck.close);

    test('requires a connection before sending commands', () {
      expect(HyperDeck.record, throwsStateError);
    });

    test('parses transport information', () {
      HyperDeck.dataHandler('500 transport info:\nstatus: play\nspeed: 100\nslot id: 1\nclip id: 2\ndisplay timecode: 00:00:01:00\ntimecode: 00:00:01:00\nvideo format: 1080p25\nloop: false\ntimeline: true\ninput video format: 1080p25\n'.codeUnits);

      expect(HyperDeck.deviceStatus, 'play');
      expect(HyperDeck.clipId, '2');
      expect(HyperDeck.videoFormat, '1080p25');
    });
  });
}
