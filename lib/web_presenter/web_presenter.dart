import 'dart:async';
import 'dart:convert';
import 'dart:io';

export 'web_presenter_rest.dart';
export 'web_presenter_xml.dart';

/// A status block received from a Blackmagic Streaming Encoder.
class WebPresenterBlock {
  WebPresenterBlock(this.name, this.values, this.raw);
  final String name;
  final Map<String, String> values;
  final String raw;
}

/// Thrown when the device rejects a TCP block request with `NACK`.
class WebPresenterProtocolException implements Exception {
  WebPresenterProtocolException(this.block);
  final WebPresenterBlock block;
  @override
  String toString() => 'Web Presenter rejected ${block.name}.';
}

/// TCP client for every block in the Blackmagic Streaming Ethernet Protocol.
///
/// The protocol calls these devices Streaming Encoders. This client is named
/// for the package's Web Presenter support while remaining compatible with
/// Streaming Encoder HD and 4K units.
class WebPresenterConnection {
  WebPresenterConnection._(this.socket) {
    _subscription = socket.listen(_onData, onError: _onError, onDone: _onDone);
  }

  final Socket socket;
  final Map<String, Map<String, String>> state = <String, Map<String, String>>{};
  final StreamController<WebPresenterBlock> _blocks = StreamController.broadcast();
  final List<Completer<WebPresenterBlock>> _pending = <Completer<WebPresenterBlock>>[];
  final StringBuffer _buffer = StringBuffer();
  late final StreamSubscription<List<int>> _subscription;
  bool _closed = false;

  /// All state blocks, including the initial device dump and later changes.
  Stream<WebPresenterBlock> get updates => _blocks.stream;
  bool get isConnected => !_closed;

  static Future<WebPresenterConnection> connect(String host,
      {int port = 9977, Duration? timeout}) async {
    final connection = Socket.connect(host, port);
    return WebPresenterConnection._(
        timeout == null ? await connection : await connection.timeout(timeout));
  }

  /// Sends a block request or update. Values use manual key names verbatim.
  Future<WebPresenterBlock> sendBlock(String name,
      [Map<String, Object?> values = const {}]) {
    if (_closed) throw StateError('Web Presenter connection is closed.');
    final pending = Completer<WebPresenterBlock>();
    _pending.add(pending);
    final buffer = StringBuffer('${name.toUpperCase()}:\n');
    values.forEach((key, value) {
      if (value != null) buffer.writeln('$key: ${_formatValue(value)}');
    });
    buffer.writeln();
    socket.write(buffer.toString());
    return pending.future;
  }

  /// Requests a complete status dump of a protocol block.
  Future<WebPresenterBlock> requestStatus(String blockName) => sendBlock(blockName);

  // Identity, version, networking and UI blocks.
  Future<WebPresenterBlock> identity() => requestStatus('IDENTITY');
  Future<WebPresenterBlock> setLabel(String label) => sendBlock('IDENTITY', {'Label': label});
  Future<WebPresenterBlock> version() => requestStatus('VERSION');
  Future<WebPresenterBlock> network() => requestStatus('NETWORK');
  Future<WebPresenterBlock> networkInterface(int index) => requestStatus('NETWORK INTERFACE $index');
  Future<WebPresenterBlock> configureNetworkInterface(int index,
          Map<String, Object?> settings) =>
      sendBlock('NETWORK INTERFACE $index', settings);
  Future<WebPresenterBlock> uiSettings() => requestStatus('UI SETTINGS');
  Future<WebPresenterBlock> configureUi(Map<String, Object?> settings) =>
      sendBlock('UI SETTINGS', settings);

  // Streaming blocks.
  Future<WebPresenterBlock> streamSettings() => requestStatus('STREAM SETTINGS');
  Future<WebPresenterBlock> configureStream(Map<String, Object?> settings) =>
      sendBlock('STREAM SETTINGS', settings);
  Future<WebPresenterBlock> streamXml() => requestStatus('STREAM XML');
  Future<WebPresenterBlock> removeStreamXml(String filename) =>
      sendBlock('STREAM XML', {'Action': 'Remove', 'Files': filename});
  Future<WebPresenterBlock> removeAllStreamXml() =>
      sendBlock('STREAM XML', {'Action': 'Remove All'});

  /// Uploads one XML custom-platform file. Blank XML lines are removed because
  /// blank lines terminate Ethernet protocol blocks.
  Future<WebPresenterBlock> uploadStreamXml(String filename, String xml) {
    if (_closed) throw StateError('Web Presenter connection is closed.');
    final pending = Completer<WebPresenterBlock>();
    _pending.add(pending);
    final compactXml = xml.split(RegExp(r'\r?\n')).where((line) => line.trim().isNotEmpty).join('\n');
    socket.write('STREAM XML $filename:\n$compactXml\n\n');
    return pending.future;
  }

  Future<WebPresenterBlock> streamState() => requestStatus('STREAM STATE');
  Future<WebPresenterBlock> startStream() => sendBlock('STREAM STATE', {'Action': 'Start'});
  Future<WebPresenterBlock> stopStream() => sendBlock('STREAM STATE', {'Action': 'Stop'});
  Future<WebPresenterBlock> audioSettings() => requestStatus('AUDIO SETTINGS');
  Future<WebPresenterBlock> configureAudio(Map<String, Object?> settings) =>
      sendBlock('AUDIO SETTINGS', settings);
  Future<WebPresenterBlock> reboot() => sendBlock('SHUTDOWN', {'Action': 'Reboot'});
  Future<WebPresenterBlock> factoryReset() =>
      sendBlock('SHUTDOWN', {'Action': 'Factory Reset'});

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
    _buffer..clear()..write(text);
  }

  WebPresenterBlock _parse(String raw) {
    final lines = raw.split('\n');
    final name = lines.first.replaceFirst(RegExp(r':$'), '').trim();
    final values = <String, String>{};
    for (final line in lines.skip(1)) {
      final separator = line.indexOf(':');
      if (separator > 0) values[line.substring(0, separator).trim()] = line.substring(separator + 1).trim();
    }
    return WebPresenterBlock(name, values, raw);
  }

  void _dispatch(WebPresenterBlock block) {
    final normalized = block.name.toUpperCase();
    if (normalized == 'ACK' || normalized == 'NACK') {
      if (_pending.isNotEmpty) {
        final pending = _pending.removeAt(0);
        normalized == 'ACK' ? pending.complete(block) : pending.completeError(WebPresenterProtocolException(block));
      }
      return;
    }
    state.putIfAbsent(normalized, () => <String, String>{}).addAll(block.values);
    _blocks.add(block);
  }

  void _onError(Object error, StackTrace stackTrace) => _failPending(error, stackTrace);
  void _onDone() => _failPending(StateError('Web Presenter closed the connection.'), StackTrace.current);
  void _failPending(Object error, StackTrace stackTrace) {
    while (_pending.isNotEmpty) _pending.removeAt(0).completeError(error, stackTrace);
  }
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
    await socket.close();
    await _blocks.close();
  }

  static String _formatValue(Object value) {
    if (value is Iterable) {
      return value.map((item) => '$item'.replaceAll('\\', '\\\\').replaceAll(',', '\\,')).join(', ');
    }
    return '$value';
  }
}
