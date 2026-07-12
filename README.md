# Blackmagic Design

Dart utilities for building remote-control applications for Blackmagic Design
devices. This package currently provides basic Ethernet-protocol support for
HyperDeck devices.

> This is an independent, unofficial package and is not affiliated with
> Blackmagic Design.

## Getting Started

The HyperDeck API communicates through a TCP socket using Blackmagic Design's
Ethernet protocol. Configure the device address, await a connection, and issue
commands. Device and transport responses update the corresponding static
properties on `HyperDeck`.

## Installation

### Dependency
Add the package as a dependency in your pubspec.yaml file.
```yaml
dependencies:
  blackmagicdesign: ^0.1.0
```

### Import
Import the package in your code file.
```dart
import 'package:blackmagicdesign/blackmagicdesign.dart';
```

## HyperDeck example

```dart
import 'package:blackmagicdesign/blackmagicdesign.dart';

Future<void> main() async {
  HyperDeck.hyperDeckIP = '192.168.10.50';
  await HyperDeck.connect();

  HyperDeck.deviceInfo();
  HyperDeck.info();
  HyperDeck.record();

  await HyperDeck.close();
}
```

Calling a command before `connect()` throws a `StateError`. Connection failures
are reported as `SocketException`s from `connect()`.

An executable version is also available in [`example/main.dart`](example/main.dart):

```sh
dart run example/main.dart 192.168.10.50
```

## License

BlackMagic Design is released under [License](https://github.com/SamsonChris71/blackmagicdesign/blob/master/LICENSE).

## About me

I'm Samson Christopher from India.
I like building new stuff.
