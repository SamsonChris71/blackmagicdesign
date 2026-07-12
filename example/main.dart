import 'package:blackmagicdesign/blackmagicdesign.dart';

/// Connects to a HyperDeck when invoked with its IP address.
///
/// For example:
///
/// ```sh
/// dart run example/main.dart 192.168.10.50
/// ```
Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('Usage: dart run example/main.dart <hyperdeck-ip-address>');
    return;
  }

  HyperDeck.hyperDeckIP = arguments.first;

  try {
    await HyperDeck.connect();
    HyperDeck.deviceInfo();
    HyperDeck.info();
    print('Connected to ${HyperDeck.hyperDeckIP}.');
  } finally {
    await HyperDeck.close();
  }
}
