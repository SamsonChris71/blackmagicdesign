import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'hyperdeck_commands.dart';

export 'hyperdeck_commands.dart';
export 'hyperdeck_rest.dart';

/// A parsed Ethernet protocol response. Responses with status 500-599 are
/// unsolicited device notifications.
class HyperDeckResponse {
  HyperDeckResponse(this.code, this.message, this.values, this.raw);

  final int code;
  final String message;
  final Map<String, String> values;
  final String raw;
  bool get isSuccess => code >= 200 && code < 300;
  bool get isNotification => code >= 500 && code < 600;
}

/// Error returned by a HyperDeck command (protocol status 100-199).
class HyperDeckProtocolException implements Exception {
  HyperDeckProtocolException(this.response);
  final HyperDeckResponse response;
  @override
  String toString() =>
      'HyperDeck command failed (${response.code}): ${response.message}';
}

/// Connection-oriented client for the complete HyperDeck Ethernet protocol.
class HyperDeckConnection {
  HyperDeckConnection._(this.socket) {
    _subscription = socket.listen(_onData, onError: _onError, onDone: _onDone);
  }

  final Socket socket;
  final StreamController<HyperDeckResponse> _responses =
      StreamController.broadcast();
  final StreamController<HyperDeckResponse> _notifications =
      StreamController.broadcast();
  final List<Completer<HyperDeckResponse>> _pending =
      <Completer<HyperDeckResponse>>[];
  final StringBuffer _buffer = StringBuffer();
  late final StreamSubscription<List<int>> _subscription;
  bool _closed = false;

  /// Device messages that arrive without a matching command response.
  Stream<HyperDeckResponse> get notifications => _notifications.stream;

  /// All complete messages received from the device.
  Stream<HyperDeckResponse> get responses => _responses.stream;
  bool get isConnected => !_closed;

  static Future<HyperDeckConnection> connect(String host,
      {int port = 9993, Duration? timeout}) async {
    final future = Socket.connect(host, port);
    return HyperDeckConnection._(
        timeout == null ? await future : await future.timeout(timeout));
  }

  /// Sends any single-line protocol command and waits for its response.
  Future<HyperDeckResponse> command(String name,
          [Map<String, Object?> parameters = const {}]) =>
      send(HyperDeckCommand.single(name, parameters));

  /// Sends any multi-line protocol command and waits for its response.
  Future<HyperDeckResponse> multilineCommand(
          String name, Map<String, Object?> parameters) =>
      send(HyperDeckCommand.multiline(name, parameters));

  // Named operations for the complete Ethernet protocol. Map arguments use
  // the parameter names from Blackmagic's protocol document verbatim.
  Future<HyperDeckResponse> help() => send(HyperDeckCommand.help);
  Future<HyperDeckResponse> shortHelp() => send(HyperDeckCommand.shortHelp);
  Future<HyperDeckResponse> supportedCommands() =>
      send(HyperDeckCommand.commands);
  Future<HyperDeckResponse> deviceInfo() => send(HyperDeckCommand.deviceInfo);
  Future<HyperDeckResponse> diskList(
          [Map<String, Object?> parameters = const {}]) =>
      command('disk list', parameters);
  Future<HyperDeckResponse> quit() => send(HyperDeckCommand.quit);
  Future<HyperDeckResponse> ping() => send(HyperDeckCommand.ping);
  Future<HyperDeckResponse> preview(bool enabled) =>
      command('preview', {'enable': enabled});
  Future<HyperDeckResponse> play(
          [Map<String, Object?> parameters = const {}]) =>
      command('play', parameters);
  Future<HyperDeckResponse> playRange() => send(HyperDeckCommand.playRange);
  Future<HyperDeckResponse> setPlayRange(Map<String, Object?> parameters) =>
      command('playrange set', parameters);
  Future<HyperDeckResponse> clearPlayRange() =>
      send(HyperDeckCommand.clearPlayRange);
  Future<HyperDeckResponse> playOnStartup(
          [Map<String, Object?> parameters = const {}]) =>
      command('play on startup', parameters);
  Future<HyperDeckResponse> playOption(
          [Map<String, Object?> parameters = const {}]) =>
      command('play option', parameters);
  Future<HyperDeckResponse> record(
          [Map<String, Object?> parameters = const {}]) =>
      command('record', parameters);
  Future<HyperDeckResponse> recordSpill() =>
      send(HyperDeckCommand.recordSpill);
  Future<HyperDeckResponse> recordSpillToSlot(int slotId) =>
      command('record', {'spill': 'slot id: $slotId'});
  Future<HyperDeckResponse> spillOrder() => send(HyperDeckCommand.spillOrder);
  Future<HyperDeckResponse> stop() => send(HyperDeckCommand.stop);
  Future<HyperDeckResponse> clipsCount() => send(HyperDeckCommand.clipsCount);
  Future<HyperDeckResponse> clipsGet(
          [Map<String, Object?> parameters = const {}]) =>
      command('clips get', parameters);
  Future<HyperDeckResponse> clipsAdd(Map<String, Object?> parameters) =>
      command('clips add', parameters);
  Future<HyperDeckResponse> clipsRemove(int clipId) =>
      command('clips remove', {'clip id': clipId});
  Future<HyperDeckResponse> clipsClear() => send(HyperDeckCommand.clipsClear);
  Future<HyperDeckResponse> clipsRebuild() =>
      send(HyperDeckCommand.clipsRebuild);
  Future<HyperDeckResponse> clipInfo(
          [Map<String, Object?> parameters = const {}]) =>
      command('clip info', parameters);
  Future<HyperDeckResponse> transportInfo() =>
      send(HyperDeckCommand.transportInfo);
  Future<HyperDeckResponse> slotInfo(
          [Map<String, Object?> parameters = const {}]) =>
      command('slot info', parameters);
  Future<HyperDeckResponse> slotSelect(Map<String, Object?> parameters) =>
      command('slot select', parameters);
  Future<HyperDeckResponse> slotUnblock(
          [Map<String, Object?> parameters = const {}]) =>
      command('slot unblock', parameters);
  Future<HyperDeckResponse> externalDriveList() =>
      send(HyperDeckCommand.externalDriveList);
  Future<HyperDeckResponse> externalDriveSelect(String device) =>
      command('external drive select', {'device': device});
  Future<HyperDeckResponse> externalDriveSelected() =>
      send(HyperDeckCommand.externalDriveSelected);
  Future<HyperDeckResponse> cacheInfo() => send(HyperDeckCommand.cacheInfo);
  Future<HyperDeckResponse> dynamicRange(
          [Map<String, Object?> parameters = const {}]) =>
      command('dynamic range', parameters);
  Future<HyperDeckResponse> notificationSettings(
          [Map<String, Object?> parameters = const {}]) =>
      command('notify', parameters);
  Future<HyperDeckResponse> goTo(Map<String, Object?> position) =>
      command('goto', position);
  Future<HyperDeckResponse> jog(String timecode) =>
      command('jog', {'timecode': timecode});
  Future<HyperDeckResponse> shuttle(int speed) =>
      command('shuttle', {'speed': speed});
  Future<HyperDeckResponse> remote(
          [Map<String, Object?> parameters = const {}]) =>
      command('remote', parameters);
  Future<HyperDeckResponse> configuration(
          [Map<String, Object?> parameters = const {}]) =>
      command('configuration', parameters);
  Future<HyperDeckResponse> uptime() => send(HyperDeckCommand.uptime);
  Future<HyperDeckResponse> prepareFormat(Map<String, Object?> parameters) =>
      command('format', parameters);
  Future<HyperDeckResponse> confirmFormat(String token) =>
      command('format', {'confirm': token});
  Future<HyperDeckResponse> identify(bool enabled) =>
      command('identify', {'enable': enabled});
  Future<HyperDeckResponse> watchdog(int seconds) =>
      command('watchdog', {'period': seconds});
  Future<HyperDeckResponse> reboot() => send('reboot\n');
  Future<HyperDeckResponse> slateClips() => send(HyperDeckCommand.slateClips);
  Future<HyperDeckResponse> setSlateClips(Map<String, Object?> values) =>
      multilineCommand('slate clips', values);
  Future<HyperDeckResponse> slateProject() =>
      send(HyperDeckCommand.slateProject);
  Future<HyperDeckResponse> setSlateProject(Map<String, Object?> values) =>
      multilineCommand('slate project', values);
  Future<HyperDeckResponse> slateLens() => send(HyperDeckCommand.slateLens);
  Future<HyperDeckResponse> setSlateLens(Map<String, Object?> values) =>
      multilineCommand('slate lens', values);
  Future<HyperDeckResponse> nasList() => send(HyperDeckCommand.nasList);
  Future<HyperDeckResponse> nasDiscovered() =>
      send(HyperDeckCommand.nasDiscovered);
  Future<HyperDeckResponse> nasSelected() => send(HyperDeckCommand.nasSelected);
  Future<HyperDeckResponse> nasDeselect() => send(HyperDeckCommand.nasDeselect);
  Future<HyperDeckResponse> nasAdd(Map<String, Object?> values) =>
      multilineCommand('nas add', values);
  Future<HyperDeckResponse> nasRemove(String url) =>
      multilineCommand('nas remove', {'url': url});
  Future<HyperDeckResponse> nasSelect(String url) =>
      multilineCommand('nas select', {'url': url});
  Future<HyperDeckResponse> authenticate(Map<String, Object?> credentials) =>
      multilineCommand('authenticate', credentials);
  Future<HyperDeckResponse> setConnectionProtocolVersion(int version) =>
      command('connection protocol', {'response version': version});

  /// Sends raw protocol text. The text must contain exactly one command.
  Future<HyperDeckResponse> send(String command) {
    if (_closed) throw StateError('HyperDeck connection is closed.');
    final completer = Completer<HyperDeckResponse>();
    _pending.add(completer);
    socket.write(command.endsWith('\n') ? command : '$command\n');
    return completer.future;
  }

  void _onData(List<int> data) {
    _buffer.write(utf8.decode(data, allowMalformed: true));
    var text = _buffer.toString().replaceAll('\r\n', '\n');
    while (true) {
      final boundary = text.indexOf('\n\n');
      if (boundary < 0) break;
      final raw = text.substring(0, boundary).trim();
      text = text.substring(boundary + 2);
      if (raw.isNotEmpty) _dispatch(_parse(raw));
    }
    // Simple status responses have no blank terminator.
    final simple = RegExp(r'^(\d{3}) ([^\n:]+)\n');
    while (true) {
      final match = simple.firstMatch(text);
      if (match == null || match.start != 0) break;
      _dispatch(_parse(match.group(0)!.trim()));
      text = text.substring(match.end);
    }
    _buffer
      ..clear()
      ..write(text);
  }

  HyperDeckResponse _parse(String raw) {
    final lines = raw.split('\n');
    final head = RegExp(r'^(\d{3})\s*(.*)$').firstMatch(lines.first);
    if (head == null) return HyperDeckResponse(0, lines.first, const {}, raw);
    final values = <String, String>{};
    for (final line in lines.skip(1)) {
      final colon = line.indexOf(':');
      if (colon > 0)
        values[line.substring(0, colon).trim().toLowerCase()] =
            line.substring(colon + 1).trim();
    }
    return HyperDeckResponse(int.parse(head.group(1)!),
        head.group(2)!.replaceFirst(RegExp(r':$'), ''), values, raw);
  }

  void _dispatch(HyperDeckResponse response) {
    _responses.add(response);
    if (response.isNotification || _pending.isEmpty) {
      _notifications.add(response);
      return;
    }
    final pending = _pending.removeAt(0);
    response.isSuccess
        ? pending.complete(response)
        : pending.completeError(HyperDeckProtocolException(response));
  }

  void _onError(Object error, StackTrace stackTrace) =>
      _failPending(error, stackTrace);
  void _onDone() => _failPending(
      StateError('HyperDeck closed the connection.'), StackTrace.current);
  void _failPending(Object error, StackTrace stackTrace) {
    while (_pending.isNotEmpty)
      _pending.removeAt(0).completeError(error, stackTrace);
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
    await socket.close();
    await _responses.close();
    await _notifications.close();
  }
}

/// Backwards-compatible static facade for the original package API.
class HyperDeck {
  static String hyperDeckIP = '';
  static bool status = false;
  static int port = 9993;
  static Socket? socket;
  static String? responseData,
      deviceName,
      deviceStatus,
      speed,
      slotId,
      clipId,
      displayTimecode,
      timecode,
      videoFormat,
      loop,
      timeline,
      inputVideoFormat;
  static HyperDeckConnection? _connection;
  static StreamSubscription<HyperDeckResponse>? _subscription;

  static Future<void> connect() async {
    await close();
    _connection = await HyperDeckConnection.connect(hyperDeckIP, port: port);
    socket = _connection!.socket;
    status = true;
    _subscription = _connection!.responses.listen(_apply);
  }

  static Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    final connection = _connection;
    _connection = null;
    if (connection != null) await connection.close();
    socket = null;
    status = false;
  }

  static void dataHandler(List<int> data) =>
      _apply(_parseForFacade(utf8.decode(data, allowMalformed: true).trim()));
  static void errorHandler(Object error, StackTrace stackTrace) =>
      status = false;
  static void doneHandler() {
    socket = null;
    status = false;
  }

  static Future<HyperDeckResponse> command(String name,
          [Map<String, Object?> parameters = const {}]) =>
      _required.command(name, parameters);
  static Future<HyperDeckResponse> multilineCommand(
          String name, Map<String, Object?> parameters) =>
      _required.multilineCommand(name, parameters);
  static Future<HyperDeckResponse> send(String rawCommand) =>
      _required.send(rawCommand);
  static HyperDeckConnection get _required =>
      _connection ??
      (throw StateError('HyperDeck is not connected. Call connect() first.'));
  static Future<HyperDeckResponse> deviceInfo() => send(cHDDeviceInfo);
  static Future<HyperDeckResponse> info() => send(cHDUpdateInfo);
  static Future<HyperDeckResponse> record([String? name]) =>
      command('record', name == null ? const {} : {'name': name});
  static Future<HyperDeckResponse> stopRecording() => send(cHDStop);
  static Future<HyperDeckResponse> play(
          {int? speed, bool? loop, bool? singleClip, int? clipId}) =>
      command('play', {
        'speed': speed,
        'loop': loop,
        'single clip': singleClip,
        'clip id': clipId
      });
  static Future<HyperDeckResponse> selectSlot(
          {int? slotId, String? device, String? videoFormat}) =>
      command('slot select',
          {'slot id': slotId, 'device': device, 'video format': videoFormat});
  static Future<HyperDeckResponse> goTo(Map<String, Object?> position) =>
      command('goto', position);
  static Future<HyperDeckResponse> configure(Map<String, Object?> settings) =>
      command('configuration', settings);
  static Future<HyperDeckResponse> notify(Map<String, bool> settings) =>
      command('notify', settings);

  static void _apply(HyperDeckResponse response) {
    responseData = response.raw;
    status = true;
    final values = response.values;
    if (response.message.toLowerCase() == 'connection info' ||
        response.message.toLowerCase() == 'device info')
      deviceName = values['model'] ?? values['device name'];
    if (response.message.toLowerCase() == 'transport info') {
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

HyperDeckResponse _parseForFacade(String raw) {
  final lines = raw.replaceAll('\r\n', '\n').split('\n');
  final head = RegExp(r'^(\d{3})\s*(.*)$').firstMatch(lines.first);
  final values = <String, String>{};
  for (final line in lines.skip(1)) {
    final colon = line.indexOf(':');
    if (colon > 0)
      values[line.substring(0, colon).trim().toLowerCase()] =
          line.substring(colon + 1).trim();
  }
  return HyperDeckResponse(head == null ? 0 : int.parse(head.group(1)!),
      head?.group(2)?.replaceFirst(RegExp(r':$'), '') ?? '', values, raw);
}