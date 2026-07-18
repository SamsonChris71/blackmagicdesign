import 'package:blackmagicdesign/blackmagicdesign.dart';
import 'package:test/test.dart';

void main() {
  group('HyperDeck', () {
    tearDown(HyperDeck.close);

    test('requires a connection before sending commands', () {
      expect(HyperDeck.record, throwsStateError);
    });

    test('parses transport information', () {
      HyperDeck.dataHandler('500 transport info:\n'
          'status: play\n'
          'speed: 100\n'
          'slot id: 1\n'
          'clip id: 2\n'
          'display timecode: 00:00:01:00\n'
          'timecode: 00:00:01:00\n'
          'video format: 1080p25\n'
          'loop: false\n'
          'timeline: true\n'
          'input video format: 1080p25\n'.codeUnits);

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

    test('builds documented record spill variants', () {
      expect(HyperDeckCommand.recordSpill, 'record spill\n');
      expect(
        HyperDeckCommand.single('record', {'spill': 'slot id: 2'}),
        'record: spill: slot id: 2\n',
      );
    });
  });

  group('WebPresenter', () {
    test('parses escaped protocol lists', () {
      final block = WebPresenterBlock('STREAM XML', {
        'Files': r'Alpha.xml, Name\, With Comma.xml, Folder\\File.xml',
      }, '');

      expect(block.listValue('Files'), <String>[
        'Alpha.xml',
        'Name, With Comma.xml',
        r'Folder\File.xml',
      ]);
    });

    test('builds streaming XML documents', () {
      final xml = StreamingXmlDocument(services: [
        StreamingService(
          name: 'My Streaming Service',
          servers: [
            StreamingServer(
              name: 'Primary',
              url: 'srt://example.com:2010',
              group: 'Primary',
              srtStreamIdExtensions: const {'copy': '0'},
            ),
          ],
          defaultProfile: 'Streaming High',
          profiles: [
            StreamingProfile(
              name: 'Streaming High',
              configs: [
                StreamingConfig(
                  resolution: '1080p',
                  fps: '60',
                  bitrate: 7500000,
                  audioBitrate: 128000,
                ),
              ],
            ),
          ],
          credentials: StreamingCredentials(
            username: 'operator',
            password: 'secret',
          ),
        ),
      ]).toXml();

      expect(xml, contains('<streaming>'));
      expect(xml, contains('<service>'));
      expect(xml, contains('<server group="Primary">'));
      expect(xml, contains('<item key="copy" value="0"/>'));
      expect(xml, contains('<profiles default="Streaming High">'));
      expect(xml, contains('<audio-bitrate>128000</audio-bitrate>'));
      expect(xml, contains('<credentials>'));
    });
  });
}