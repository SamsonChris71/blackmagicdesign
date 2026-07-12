import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'hyperdeck_commands.dart';

/// Controls a Blackmagic Design HyperDeck through its Ethernet protocol.
///
/// Configure [hyperDeckIP] and optionally [port], then await [connect] before
/// issuing commands such as [record], [stopRecording], [deviceInfo], or [info].
class HyperDeck {
  /// Address or host name of the HyperDeck device.
  static String hyperDeckIP = '';

  /// Whether a socket connection is currently active.
  static bool status = false;

  /// TCP port used by the HyperDeck Ethernet protocol.
  static int port = 9993;

  /// The active device socket, or `null` before connecting and after closing.
  static Socket? socket;

  /// The most recent complete response received from the device.
  static String? responseData;

  /// Name reported by the connected device.
  static String? deviceName;

  /// Current transport state reported by the device.
  static String? deviceStatus;

  /// Current playback speed reported by the device.
  static String? speed;

  /// Active storage slot identifier.
  static String? slotId;

  /// Current clip identifier.
  static String? clipId;

  /// Current display timecode.
  static String? displayTimecode;

  /// Current timecode.
  static String? timecode;

  /// Current video format.
  static String? videoFormat;

  /// Whether loop playback is enabled.
  static String? loop;

  /// Current timeline state.
  static String? timeline;

  /// Input video format reported by the device.
  static String? inputVideoFormat;

  static StreamSubscription<List<int>>? _subscription;

  /// Opens a connection to the configured HyperDeck.
  ///
  /// Throws a [SocketException] when the device cannot be reached.
  static Future<void> connect() async {
    await close();
    final connectedSocket = await Socket.connect(hyperDeckIP, port);
    socket = connectedSocket;
    status = true;
    _subscription = connectedSocket.listen(
      dataHandler,
      onError: errorHandler,
      onDone: doneHandler,
      cancelOnError: false,
    );
  }

  /// Closes the active connection, if one exists.
  static Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    socket?.destroy();
    socket = null;
    status = false;
  }

  /// Processes bytes received from the HyperDeck.
  static void dataHandler(List<int> data) {
    responseData = utf8.decode(data, allowMalformed: true).trim();
    status = true;
    _parseResponse(responseData!);
  }

  /// Handles socket errors by marking the connection inactive.
  static void errorHandler(Object error, StackTrace stackTrace) {
    status = false;
  }

  /// Handles normal socket closure.
  static void doneHandler() {
    socket = null;
    status = false;
  }

  /// Requests device information.
  static void deviceInfo() => _send(cHDDeviceInfo);

  /// Requests the current transport state.
  static void info() => _send(cHDUpdateInfo);

  /// Starts recording.
  static void record() => _send(cHDRecord);

  /// Stops playback or recording.
  static void stopRecording() => _send(cHDStop);

  static void _send(String command) {
    final activeSocket = socket;
    if (activeSocket == null) {
      throw StateError('HyperDeck is not connected. Call connect() first.');
    }
    activeSocket.write(command);
  }

  static void _parseResponse(String response) {
    final values = <String, String>{};
    for (final line in response.split('\n')) {
      final separator = line.indexOf(':');
      if (separator < 0) continue;
      values[line.substring(0, separator).trim().toLowerCase()] =
          line.substring(separator + 1).trim();
    }

    if (response.contains('connection info:')) {
      deviceName = values['model'] ?? values['device name'];
    }
    if (response.contains('transport info:')) {
      deviceStatus = values['status'];
      speed = values['speed'];
      slotId = values['slot id'];
      clipId = values['clip id'];
      displayTimecode = values['display timecode'];
      timecode = values['timecode'];
      videoFormat = values['video format'];
      loop = values['loop'];
      timeline = values['timeline'];
      inputVideoFormat = values['input video format'];
    }
  }
}
