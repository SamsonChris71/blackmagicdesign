# Blackmagic Design

Dart utilities for building remote-control applications for Blackmagic Design
devices. This package supports the complete Ethernet protocol and the
HyperDeck Control REST API, plus Blackmagic Streaming Encoder/Web Presenter
Ethernet, REST and Streaming XML helpers.

> This is an independent, unofficial package and is not affiliated with
> Blackmagic Design.

## Getting Started

The HyperDeck API communicates through a TCP socket using Blackmagic Design's
Ethernet protocol. Configure the device address, await a connection, and issue
commands. Device and transport responses update the corresponding static
properties on `HperDeck`.For new applications, prefer `HperDeckConnection`:
it has a response future for every command and a stream of unsolicited device
notifications.

## Installation

### Dependency

Add the package as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  blackmagicdesign: ^0.1.0`
```

### Import

Import the package in your code file.

```dart
import 'package:blackmagicdesign/blackmagicdesign.dart';
```

# HyperDeck example

```dart
import 'package:blackmagicdesign/blackmagicdesign.dart';

Future<void> main() async {
  HyperDeck.hyperDeckIP = '192.168.10.50';
  await HyperDeck.connect();

  final device = await HyperDeck.deviceInfo();
  final transport = await HyperDeck.info();
  await HyperDeck.record();

  print(device.values['model']);
  print(transport.values['status']);

  await HyperDeck.close();
}
```

Calling a command before `connect()` throws a `StateError`. Connection failures
are reported as `SocketException`s from `connect()`.

## Complete Ethernet protocol

Every command in the Ethernet protocol is available through `command` and
`multilineCommand`, so support is not limited by this package when device
firmware adds a parameter.

```dart
final deck = await HyperDeckConnection.connect('192.168.10.50');
await deck.command('play', {
  'clip id': 5,
  'speed': 100,
  'loop': true,
});
await deck.multilineCommand('nas add', {
  'url': 'smb://nas.local/media',
  'username': 'editor',
  'password': 'secret',
});
await deck.close();
```

`HyperDeckConnection` also provides named methods for every documented
Ethernet operation, including `clipsAdd`, `slotSelect`, `prepareFormat`,
`authenticate`, slate, NAS, playback, record, configuration and notification
operations. `command()` and `multilineCommand()` remain available for new
firmware-specific parameters.

## Web Presenter and Streaming Encoder

`WebPresenterConnection` covers the documented Streaming Encoder Ethernet
protocol blocks, including identity, version, network, UI, stream settings,
stream XML, stream state, audio settings and shutdown. Status request helpers
return the requested status block, while update helpers return the device ACK.

```dart
final presenter = await WebPresenterConnection.connect('192.168.10.60');
final identity = await presenter.identity();
await presenter.startStream();
print(identity.values['Model']);
await presenter.close();
```

Use `StreamingXmlDocument` to build custom platform XML for Ethernet or REST
uploads:

```dart
final xml = StreamingXmlDocument(services: [
  StreamingService(
    name: 'My Streaming Service',
    customizableUrl: true,
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
  ),
]).toXml();
```

## REST API

`HyperDeckRestClient` accepts the REST API base URL and exposes generic `get`,
`put`, `post`, `delete`, and `request` methods for every documented endpoint,
plus named operations for transports, system, media, NAS, timelines, clips,
audio and monitoring. `connectEvents()` exposes the notification WebSocket;
use `subscribe()` and `unsubscribe()` on the returned socket.

```dart
final api = HyperDeckRestClient(Uri.parse('http://192.168.10.50/'));
await api.record('Interview_001');
await api.put('/transports/0/playback', {'speed': 1.0, 'loop': false});
final clips = await api.get('/clips');
await api.close();
```

`WebPresenterRestClient` normalizes device URLs to `/control/api/v1/`, exposes
all documented Streaming Encoder REST endpoints and provides `connectEvents()`
for the REST notification WebSocket.

An executable version is also available in [`example/main.dart`](example/main.dart).
It supports device and transport inspection, plus explicit `record` and `stop`
commands:

```sh

dart run example/main.dart 192.168.10.50
dart run example/main.dart 192.168.10.50 --port 9993 info
dart run example/main.dart 192.168.10.50 record
dart run example/main.dart 192.168.10.50 stop
```

## License

BlackMagic Design is released under the
[project license](https://github.com/SamsonChris71/blackmagicdesign/blob/master/LICENSE).

## About me

I'm Samson Christopher from India.
I like building new stuff.
