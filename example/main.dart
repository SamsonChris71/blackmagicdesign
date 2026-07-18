import 'dart:io';

import 'package:blackmagicdesign/blackmagicdesign.dart';

/// Demonstrates common HyperDeck operations.
///
/// Examples:
///
/// ```sh
/// dart run example/main.dart 192.168.10.50
/// dart run example/main.dart 192.168.10.50 --port 9993 info
/// dart run example/main.dart 192.168.10.50 record
/// dart run example/main.dart 192.168.10.50 stop
/// ```
///
/// The default and info commands only request device and transport details.
/// record and stop control the HyperDeck and should be used with care.
Future<void> main(List<String> arguments) async {
  final configuration = _parseArguments(arguments);
  if (configuration == null) {
    exitCode = 64;
    return;
  }

  HyperDeck.hyperDeckIP = configuration.host;
  HyperDeck.port = configuration.port;

  try {
    await HyperDeck.connect();
    print('Connected to ${HyperDeck.hyperDeckIP}:${HyperDeck.port}.');

    switch (configuration.command) {
      case _Command.info:
        await _showDeviceInfo();
        break;
      case _Command.record:
        await HyperDeck.record();
        print('Recording started.');
        break;
      case _Command.stop:
        await HyperDeck.stopRecording();
        print('Playback or recording stopped.');
        break;
    }
  } on SocketException catch (error) {
    stderr.writeln(
        'Could not connect to ${configuration.host}:${configuration.port}.');
    stderr.writeln(error.message);
    exitCode = 1;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } finally {
    await HyperDeck.close();
  }
}

Future<void> _showDeviceInfo() async {
  final device = await HyperDeck.deviceInfo();
  print(
      'Device: ${device.values['model'] ?? device.values['name'] ?? 'unknown'}');

  final transport = await HyperDeck.info();
  print('Status: ${transport.values['status'] ?? 'unknown'}');
  print('Timecode: ${transport.values['timecode'] ?? 'unknown'}');
  print('Clip ID: ${transport.values['clip id'] ?? 'unknown'}');
}

_Configuration? _parseArguments(List<String> arguments) {
  if (arguments.isEmpty || arguments.contains('--help')) {
    _printUsage();
    return null;
  }

  final host = arguments.first;
  var port = 9993;
  var command = _Command.info;

  for (var index = 1; index < arguments.length; index++) {
    final argument = arguments[index];
    if (argument == '--port') {
      if (++index >= arguments.length) {
        stderr.writeln('Missing value for --port.');
        _printUsage();
        return null;
      }
      port = int.tryParse(arguments[index]) ?? -1;
      if (port < 1 || port > 65535) {
        stderr.writeln('Port must be an integer between 1 and 65535.');
        return null;
      }
      continue;
    }

    final parsedCommand = _commandFromArgument(argument);
    if (parsedCommand == null) {
      stderr.writeln('Unknown command: $argument');
      _printUsage();
      return null;
    }
    command = parsedCommand;
  }

  return _Configuration(host: host, port: port, command: command);
}

void _printUsage() {
  print('Usage: dart run example/main.dart <host> [--port <port>] [command]');
  print('Commands: info (default), record, stop');
}

class _Configuration {
  const _Configuration({
    required this.host,
    required this.port,
    required this.command,
  });

  final String host;
  final int port;
  final _Command command;
}

enum _Command { info, record, stop }

_Command? _commandFromArgument(String value) {
  switch (value) {
    case 'info':
      return _Command.info;
    case 'record':
      return _Command.record;
    case 'stop':
      return _Command.stop;
  }
  return null;
}
