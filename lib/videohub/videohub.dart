import 'dart:async';
import 'dart:typed_data';

import 'package:persistent_socket/persistent_socket.dart';

import 'models/device_info.dart';
import 'models/video_input.dart';
import 'models/video_output.dart';
import 'models/video_route.dart';
import 'models/videohub_data.dart';
import 'parsers.dart';

export 'models/device_info.dart';
export 'models/video_input.dart';
export 'models/video_output.dart';
export 'models/video_route.dart';
export 'models/videohub_data.dart';

/// Videohub control class
class Videohub {
  /// Creates an instance of Videhub to control a single videohub device
  Videohub(
    this.ipAddress, {
    this.port = 9990,
  }) : _socket = PersistentSocket(ipAddress, port) {
    _streamController = StreamController(
      onListen: _onListen,
      onPause: () => _socketSub?.pause(),
      onCancel: _onDone,
      onResume: () => _socketSub?.resume(),
    );
  }

  /// IP address of the videohub to connect to
  final String ipAddress;

  /// Port to connect via telnet
  final int port;

  /// Device info
  VideohubDeviceInfo _deviceInfo = VideohubDeviceInfo();

  /// List of available video inputs
  final Map<int, VideoInput> _inputs = {};

  /// List of available video outputs
  final Map<int, VideoOutput> _outputs = {};

  /// Is Take Mode enabled?
  bool _takeMode = true;

  /// Socket connected to the videohub
  final PersistentSocket _socket;

  /// Subscription to incoming data from the socket
  StreamSubscription<Uint8List>? _socketSub;

  late StreamController<VideohubData> _streamController;

  /// Stream of incoming VideohubData from the device
  ///
  /// Listening to this stream will initiate the connection to
  /// the videohub
  Stream<VideohubData> get stream => _streamController.stream;

  /// Applies the supplied [VideoRoute] to the routing matrix
  Future<void> takeRoute(VideoRoute route) async =>
      await takeRouteByIndex(route.input.index, route.output.index);

  /// Establishes a route from an input to an output by index
  Future<void> takeRouteByIndex(int inputIndex, int outputIndex) async =>
      await _socket.sendString(
        'VIDEO OUTPUT ROUTING:\n$outputIndex $inputIndex\n\n',
        reconnect: true,
      );

  /// Initiate connection and begin listening for incoming data
  Future<void> _onListen() async {
    _socketSub = _socket.stream.listen(
      _onData,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: false,
    );
  }

  void _onData(Uint8List data) {
    final responseData = String.fromCharCodes(data).trim();
    final sections = responseData.split('\n\n');

    for (final section in sections) {
      final endOfName = section.indexOf(':');
      if (endOfName < 1) break;

      final sectionName = section.substring(0, endOfName);

      switch (sectionName) {
        case 'PROTOCOL PREAMBLE':
          _deviceInfo = _deviceInfo.copyWith(
            protocolVersion: responseData.split('\n').last.parseValue,
          );
          break;
        case 'VIDEOHUB DEVICE':
          _deviceInfo = parseDeviceInfo(section, deviceInfo: _deviceInfo);
          break;
        case 'INPUT LABELS':
          _inputs.addAll(parseInputLabels(section, _inputs));
          break;
        case 'OUTPUT LABELS':
          _outputs.addAll(parseOutputLabels(section, _outputs));
          break;
        case 'VIDEO OUTPUT LOCKS':
          _outputs.addAll(updateOutputLocks(section, _outputs));
          break;
        case 'VIDEO OUTPUT ROUTING':
          _outputs.addAll(updateOutputRouting(section, _outputs));
          break;
        case 'CONFIGURATION':
          _takeMode = section.split('\n').last.parseValue == 'true';
          break;
        default:
          break;
      }
    }
    if (_deviceInfo.devicePresent) {
      _streamController.add(VideohubData(
        deviceInfo: _deviceInfo,
        inputMap: _inputs,
        outputMap: _outputs,
        takeMode: _takeMode,
      ));
    }
  }

  void _onError(error, StackTrace trace) =>
      _streamController.addError(error, trace);

  Future<void> _onDone() async {
    await _socketSub?.cancel();
    _socket.close();
    await _streamController.close();
  }

  /// Disconnects from the videohub
  Future<void> disconnect() async => _socket.close();
}
