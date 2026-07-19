import 'dart:io';

import 'package:blackmagicdesign/atem/atem.dart';
import 'package:blackmagicdesign/atem/src/connection/atem_connection.dart';

/// Demonstrates common ATEM switcher operations.
///
/// Examples:
///
/// ```sh
/// dart run example/atem.dart 192.168.10.50
/// dart run example/atem.dart 192.168.10.50 --port 9910 info
/// dart run example/atem.dart 192.168.10.50 program 1
/// dart run example/atem.dart 192.168.10.50 preview 2
/// dart run example/atem.dart 192.168.10.50 cut
/// dart run example/atem.dart 192.168.10.50 auto
/// dart run example/atem.dart 192.168.10.50 keyon 0
/// dart run example/atem.dart 192.168.10.50 keyoff 0
/// dart run example/atem.dart 192.168.10.50 ftb
/// dart run example/atem.dart 192.168.10.50 aux 0 1
/// ```
///
/// Commands:
/// - info: Request device info and show current state
/// - program [source]: Set program bus input (default source 1)
/// - preview [source]: Set preview bus input (default source 2)
/// - cut: Perform cut transition on ME 0
/// - auto: Perform auto transition on ME 0
/// - keyon [keyer]: Turn keyer on air (default keyer 0)
/// - keyoff [keyer]: Take keyer off air (default keyer 0)
/// - ftb: Fade to black on ME 0
/// - aux [aux] [source]: Set aux output source
/// - color [index] [hue] [sat] [lum]: Set color generator
Future<void> main(List<String> arguments) async {
  final configuration = _parseArguments(arguments);
  if (configuration == null) {
    exitCode = 64;
    return;
  }

  final connection = AtemConnection(
    config: AtemConnectionConfig(
      host: configuration.host,
      port: configuration.port,
    ),
  );

  try {
    await connection.connect();
    // Wait for handshake to complete
    await connection.events
        .where((e) => e is AtemConnected)
        .first
        .timeout(const Duration(seconds: 5));
    print('Connected to ${configuration.host}:${configuration.port}');

    // Execute command immediately after connection - no need to wait for full state dump
    switch (configuration.command) {
      case _AtemCommand.info:
        await _showDeviceInfo(connection);
        break;
      case _AtemCommand.program:
        await connection.setProgramInput(
            configuration.meIndex, configuration.source);
        print(
            'Program ME${configuration.meIndex} set to source ${configuration.source}');
        break;
      case _AtemCommand.preview:
        await connection.setPreviewInput(
            configuration.meIndex, configuration.source);
        print(
            'Preview ME${configuration.meIndex} set to source ${configuration.source}');
        break;
      case _AtemCommand.cut:
        await connection.cut(configuration.meIndex);
        print('Cut executed on ME${configuration.meIndex}');
        break;
      case _AtemCommand.autoTransition:
        await connection.autoTransition(configuration.meIndex);
        print('Auto transition executed on ME${configuration.meIndex}');
        break;
      case _AtemCommand.keyOn:
        await connection.setKeyOnAir(
            configuration.meIndex, configuration.keyerIndex, true);
        print(
            'Keyer ${configuration.keyerIndex} on air on ME${configuration.meIndex}');
        break;
      case _AtemCommand.keyOff:
        await connection.setKeyOnAir(
            configuration.meIndex, configuration.keyerIndex, false);
        print(
            'Keyer ${configuration.keyerIndex} off air on ME${configuration.meIndex}');
        break;
      case _AtemCommand.fadeToBlack:
        await connection.executeFadeToBlack(configuration.meIndex, true);
        print('Fade to black executed on ME${configuration.meIndex}');
        break;
      case _AtemCommand.aux:
        await connection.setAuxSource(
            configuration.auxIndex, configuration.source);
        print(
            'Aux ${configuration.auxIndex} set to source ${configuration.source}');
        break;
      case _AtemCommand.color:
        await connection.setColorGenerator(
          configuration.colorIndex,
          hue: configuration.hue,
          saturation: configuration.saturation,
          luminance: configuration.luminance,
        );
        print('Color generator ${configuration.colorIndex} set: '
            'hue=${configuration.hue}, sat=${configuration.saturation}, lum=${configuration.luminance}');
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
    await connection.disconnect();
  }
}

Future<void> _showDeviceInfo(AtemConnection connection) async {
  final state = connection.state;
  print('=== ATEM Device Info ===');
  print('Connected: ${state.isConnected}');
  print('Product: ${state.productName} (${state.productModel})');
  print('Firmware: ${state.firmwareVersion}');
  print('Video Mode: ${state.videoMode.nameString}');

  if (state.topology != null) {
    final t = state.topology!;
    print('Topology: ${t.meCount} ME, ${t.keyerCount} Keyers, '
        '${t.dskCount} DSK, ${t.auxCount} Aux, '
        '${t.mediaPlayerCount} Media Players, ${t.superSourceCount} SuperSources');
  }

  print('\n=== Current State ===');
  for (final entry in state.programInputs.entries) {
    print('Program ME${entry.key}: Source ${entry.value}');
  }
  for (final entry in state.previewInputs.entries) {
    print('Preview ME${entry.key}: Source ${entry.value}');
  }
  for (final entry in state.auxSources.entries) {
    print('Aux ${entry.key}: Source ${entry.value}');
  }
  for (final entry in state.transitions.entries) {
    print('Transition ME${entry.key}: ${entry.value.type} '
        '(${entry.value.style}) rate=${entry.value.rate} '
        'pos=${entry.value.positionNormalized.toStringAsFixed(2)}');
  }
  for (final meEntry in state.keyers.entries) {
    for (final keyerEntry in meEntry.value.entries) {
      final k = keyerEntry.value;
      print('Keyer ME${meEntry.key}/${keyerEntry.key}: '
          'type=${k.keyType} enabled=${k.enabled} onAir=${k.onAir} '
          'fill=${k.fillSource} key=${k.keySource}');
    }
  }
}

_Configuration? _parseArguments(List<String> arguments) {
  if (arguments.isEmpty || arguments.contains('--help')) {
    _printUsage();
    return null;
  }

  final host = arguments.first;
  var port = 9910;
  var command = _AtemCommand.info;
  var meIndex = 0;
  var source = 1;
  var keyerIndex = 0;
  var auxIndex = 0;
  var colorIndex = 0;
  int? hue, saturation, luminance;

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
    if (parsedCommand != null) {
      command = parsedCommand;

      // Parse additional arguments for specific commands
      switch (command) {
        case _AtemCommand.program:
        case _AtemCommand.preview:
          if (index + 1 < arguments.length) {
            final nextArg = arguments[index + 1];
            if (!nextArg.startsWith('--') && !_isCommand(nextArg)) {
              meIndex = int.tryParse(nextArg) ?? 0;
              if (index + 2 < arguments.length) {
                source = int.tryParse(arguments[index + 2]) ?? 1;
                index += 2;
              } else {
                index++;
              }
            }
          }
          break;
        case _AtemCommand.keyOn:
        case _AtemCommand.keyOff:
          if (index + 1 < arguments.length) {
            keyerIndex = int.tryParse(arguments[index + 1]) ?? 0;
            index++;
          }
          break;
        case _AtemCommand.aux:
          if (index + 2 < arguments.length) {
            auxIndex = int.tryParse(arguments[index + 1]) ?? 0;
            source = int.tryParse(arguments[index + 2]) ?? 1;
            index += 2;
          }
          break;
        case _AtemCommand.color:
          if (index + 4 < arguments.length) {
            colorIndex = int.tryParse(arguments[index + 1]) ?? 0;
            hue = int.tryParse(arguments[index + 2]);
            saturation = int.tryParse(arguments[index + 3]);
            luminance = int.tryParse(arguments[index + 4]);
            index += 4;
          }
          break;
        default:
          break;
      }
      continue;
    }

    stderr.writeln('Unknown command: $argument');
    _printUsage();
    return null;
  }

  return _Configuration(
    host: host,
    port: port,
    command: command,
    meIndex: meIndex,
    source: source,
    keyerIndex: keyerIndex,
    auxIndex: auxIndex,
    colorIndex: colorIndex,
    hue: hue,
    saturation: saturation,
    luminance: luminance,
  );
}

void _printUsage() {
  print(
      'Usage: dart run example/atem.dart <host> [--port <port>] [command] [args...]');
  print('');
  print('Commands:');
  print(
      '  info                    Show device info and current state (default)');
  print(
      '  program [me] [source]   Set program bus input (default: ME 0, source 1)');
  print(
      '  preview [me] [source]   Set preview bus input (default: ME 0, source 2)');
  print('  cut [me]                Perform cut transition (default: ME 0)');
  print('  auto [me]               Perform auto transition (default: ME 0)');
  print(
      '  keyon [keyer]           Turn keyer on air (default: keyer 0 on ME 0)');
  print(
      '  keyoff [keyer]          Take keyer off air (default: keyer 0 on ME 0)');
  print('  ftb [me]                Fade to black (default: ME 0)');
  print('  aux <aux> <source>      Set aux output source');
  print('  color <idx> <hue> <sat> <lum>  Set color generator');
  print('');
  print('Examples:');
  print('  dart run example/atem.dart 192.168.10.50');
  print('  dart run example/atem.dart 192.168.10.50 info');
  print('  dart run example/atem.dart 192.168.10.50 program 0 1');
  print('  dart run example/atem.dart 192.168.10.50 preview 0 2');
  print('  dart run example/atem.dart 192.168.10.50 cut');
  print('  dart run example/atem.dart 192.168.10.50 auto');
  print('  dart run example/atem.dart 192.168.10.50 keyon 0');
  print('  dart run example/atem.dart 192.168.10.50 aux 0 1');
  print('  dart run example/atem.dart 192.168.10.50 color 0 100 200 300');
}

class _Configuration {
  const _Configuration({
    required this.host,
    required this.port,
    required this.command,
    this.meIndex = 0,
    this.source = 1,
    this.keyerIndex = 0,
    this.auxIndex = 0,
    this.colorIndex = 0,
    this.hue,
    this.saturation,
    this.luminance,
  });

  final String host;
  final int port;
  final _AtemCommand command;
  final int meIndex;
  final int source;
  final int keyerIndex;
  final int auxIndex;
  final int colorIndex;
  final int? hue;
  final int? saturation;
  final int? luminance;
}

enum _AtemCommand {
  info,
  program,
  preview,
  cut,
  autoTransition,
  keyOn,
  keyOff,
  fadeToBlack,
  aux,
  color,
}

_AtemCommand? _commandFromArgument(String value) {
  switch (value) {
    case 'info':
      return _AtemCommand.info;
    case 'program':
    case 'prg':
      return _AtemCommand.program;
    case 'preview':
    case 'prv':
      return _AtemCommand.preview;
    case 'cut':
      return _AtemCommand.cut;
    case 'auto':
      return _AtemCommand.autoTransition;
    case 'keyon':
      return _AtemCommand.keyOn;
    case 'keyoff':
      return _AtemCommand.keyOff;
    case 'ftb':
    case 'fade':
      return _AtemCommand.fadeToBlack;
    case 'aux':
      return _AtemCommand.aux;
    case 'color':
      return _AtemCommand.color;
  }
  return null;
}

bool _isCommand(String value) {
  return _commandFromArgument(value) != null;
}
