/// Builders for the Blackmagic Streaming XML file format.
///
/// The generated XML can be uploaded with WebPresenterConnection.uploadStreamXml
/// or WebPresenterRestClient.uploadCustomPlatform.
class StreamingXmlDocument {
  StreamingXmlDocument({required List<StreamingService> services})
      : services = List<StreamingService>.unmodifiable(services) {
    if (services.isEmpty) {
      throw ArgumentError.value(services, 'services', 'Must not be empty.');
    }
  }

  final List<StreamingService> services;

  /// Removes blank lines because Streaming Encoder uploads treat blank lines as
  /// protocol block terminators.
  static String compact(String xml) => xml
      .split(RegExp(r'\r?\n'))
      .where((line) => line.trim().isNotEmpty)
      .join('\n');

  String toXml({bool pretty = true}) {
    final writer = _XmlWriter(pretty: pretty);
    writer
      ..line('<?xml version="1.0" encoding="UTF-8"?>')
      ..open('streaming');
    for (final service in services) {
      service._write(writer);
    }
    writer.close('streaming');
    return writer.toString();
  }

  @override
  String toString() => toXml();
}

class StreamingService {
  StreamingService({
    required this.name,
    required List<StreamingProfile> profiles,
    List<StreamingServer> servers = const <StreamingServer>[],
    this.key,
    this.defaultProfile,
    this.credentials,
    this.customizableUrl = false,
  })  : profiles = List<StreamingProfile>.unmodifiable(profiles),
        servers = List<StreamingServer>.unmodifiable(servers) {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Must not be empty.');
    }
    if (profiles.isEmpty) {
      throw ArgumentError.value(profiles, 'profiles', 'Must not be empty.');
    }
    if (!customizableUrl && servers.isEmpty) {
      throw ArgumentError.value(
        servers,
        'servers',
        'Must not be empty unless customizableUrl is true.',
      );
    }
  }

  final String name;
  final String? key;
  final String? defaultProfile;
  final StreamingCredentials? credentials;
  final bool customizableUrl;
  final List<StreamingServer> servers;
  final List<StreamingProfile> profiles;

  void _write(_XmlWriter writer) {
    writer.open(
      'service',
      customizableUrl ? const <String, String>{'customizable-url': 'true'} : null,
    );
    writer.element('name', name);
    if (key != null) writer.element('key', key!);
    if (servers.isNotEmpty) {
      writer.open('servers');
      for (final server in servers) {
        server._write(writer);
      }
      writer.close('servers');
    }
    writer.open(
      'profiles',
      defaultProfile == null
          ? null
          : <String, String>{'default': defaultProfile!},
    );
    for (final profile in profiles) {
      profile._write(writer);
    }
    writer.close('profiles');
    credentials?._write(writer);
    writer.close('service');
  }
}

class StreamingServer {
  StreamingServer({
    required this.name,
    required this.url,
    this.group,
    Map<String, String> srtStreamIdExtensions = const <String, String>{},
  }) : srtStreamIdExtensions =
            Map<String, String>.unmodifiable(srtStreamIdExtensions) {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Must not be empty.');
    }
    if (url.isEmpty) {
      throw ArgumentError.value(url, 'url', 'Must not be empty.');
    }
  }

  final String name;
  final String url;
  final String? group;

  /// Key/value items written under <srt-extensions><stream-id>.
  final Map<String, String> srtStreamIdExtensions;

  void _write(_XmlWriter writer) {
    writer.open(
      'server',
      group == null ? null : <String, String>{'group': group!},
    );
    writer
      ..element('name', name)
      ..element('url', url);
    if (srtStreamIdExtensions.isNotEmpty) {
      writer
        ..open('srt-extensions')
        ..open('stream-id');
      srtStreamIdExtensions.forEach((key, value) {
        writer.empty('item', <String, String>{'key': key, 'value': value});
      });
      writer
        ..close('stream-id')
        ..close('srt-extensions');
    }
    writer.close('server');
  }
}

class StreamingProfile {
  StreamingProfile({
    required this.name,
    required List<StreamingConfig> configs,
  }) : configs = List<StreamingConfig>.unmodifiable(configs) {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Must not be empty.');
    }
    if (configs.isEmpty) {
      throw ArgumentError.value(configs, 'configs', 'Must not be empty.');
    }
  }

  final String name;
  final List<StreamingConfig> configs;

  void _write(_XmlWriter writer) {
    writer.open('profile');
    writer.element('name', name);
    for (final config in configs) {
      config._write(writer);
    }
    writer.close('profile');
  }
}

class StreamingConfig {
  StreamingConfig({
    required this.resolution,
    required this.fps,
    required this.bitrate,
    this.codec = 'H264',
    this.audioBitrate,
  }) {
    if (resolution.isEmpty) {
      throw ArgumentError.value(resolution, 'resolution', 'Must not be empty.');
    }
    if (fps.isEmpty) {
      throw ArgumentError.value(fps, 'fps', 'Must not be empty.');
    }
    if (codec.isEmpty) {
      throw ArgumentError.value(codec, 'codec', 'Must not be empty.');
    }
    if (bitrate <= 0) {
      throw ArgumentError.value(bitrate, 'bitrate', 'Must be positive.');
    }
    if (audioBitrate != null && audioBitrate! <= 0) {
      throw ArgumentError.value(
        audioBitrate,
        'audioBitrate',
        'Must be positive.',
      );
    }
  }

  final String resolution;
  final String fps;
  final String codec;
  final int bitrate;
  final int? audioBitrate;

  void _write(_XmlWriter writer) {
    writer.open('config', <String, String>{
      'resolution': resolution,
      'fps': fps,
      'codec': codec,
    });
    writer.element('bitrate', '$bitrate');
    if (audioBitrate != null) {
      writer.element('audio-bitrate', '$audioBitrate');
    }
    writer.close('config');
  }
}

class StreamingCredentials {
  StreamingCredentials({required this.username, required this.password}) {
    if (username.isEmpty) {
      throw ArgumentError.value(username, 'username', 'Must not be empty.');
    }
    if (password.isEmpty) {
      throw ArgumentError.value(password, 'password', 'Must not be empty.');
    }
  }

  final String username;
  final String password;

  void _write(_XmlWriter writer) {
    writer
      ..open('credentials')
      ..element('username', username)
      ..element('password', password)
      ..close('credentials');
  }
}

class _XmlWriter {
  _XmlWriter({required this.pretty});

  final bool pretty;
  final StringBuffer _buffer = StringBuffer();
  var _indent = 0;

  void line(String text) {
    _writeIndent();
    _buffer.write(text);
    _newline();
  }

  void open(String name, [Map<String, String>? attributes]) {
    _writeIndent();
    _buffer.write('<$name${_attributes(attributes)}>');
    _newline();
    _indent++;
  }

  void close(String name) {
    _indent--;
    _writeIndent();
    _buffer.write('</$name>');
    _newline();
  }

  void element(String name, String value) {
    _writeIndent();
    _buffer.write('<$name>${_escapeText(value)}</$name>');
    _newline();
  }

  void empty(String name, [Map<String, String>? attributes]) {
    _writeIndent();
    _buffer.write('<$name${_attributes(attributes)}/>');
    _newline();
  }

  void _writeIndent() {
    if (!pretty) return;
    for (var index = 0; index < _indent; index++) {
      _buffer.write('  ');
    }
  }

  void _newline() {
    if (pretty) _buffer.writeln();
  }

  @override
  String toString() => _buffer.toString();
}

String _attributes(Map<String, String>? attributes) {
  if (attributes == null || attributes.isEmpty) return '';
  return attributes.entries
      .map((entry) => ' ${entry.key}="${_escapeAttribute(entry.value)}"')
      .join();
}

String _escapeText(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

String _escapeAttribute(String value) => _escapeText(value)
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');