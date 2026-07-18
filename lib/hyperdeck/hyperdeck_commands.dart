/// Builders for the line-oriented HyperDeck Ethernet protocol.
///
/// Every command listed in Blackmagic Design's Ethernet Protocol document can
/// be sent with [HyperDeckCommand.single] or [HyperDeckCommand.multiline].
/// The named helpers below cover the commands that do not need parameters.
class HyperDeckCommand {
  HyperDeckCommand._();

  /// Creates a single-line command, for example play: speed: 100.
  static String single(String name,
      [Map<String, Object?> parameters = const {}]) {
    if (parameters.isEmpty) return '$name\n';
    final values = <String>[];
    parameters.forEach((key, value) {
      if (value != null) values.add('$key: ${_value(value)}');
    });
    return values.isEmpty ? '$name\n' : '$name: ${values.join(' ')}\n';
  }

  /// Creates a multi-line command, required by authenticate, slate and NAS
  /// bookmark operations.
  static String multiline(String name, Map<String, Object?> parameters) {
    final buffer = StringBuffer('$name:\n');
    parameters.forEach((key, value) {
      if (value != null) buffer.writeln('$key: ${_value(value)}');
    });
    buffer.writeln();
    return buffer.toString();
  }

  static String _value(Object value) =>
      value is bool ? value.toString() : '$value';

  static const String help = 'help\n';
  static const String shortHelp = '?\n';
  static const String commands = 'commands\n';
  static const String deviceInfo = 'device info\n';
  static const String diskList = 'disk list\n';
  static const String quit = 'quit\n';
  static const String ping = 'ping\n';
  static const String play = 'play\n';
  static const String playRange = 'playrange\n';
  static const String clearPlayRange = 'playrange clear\n';
  static const String playOnStartup = 'play on startup\n';
  static const String playOption = 'play option\n';
  static const String record = 'record\n';
  static const String recordSpill = 'record spill\n';
  static const String spillOrder = 'spill order\n';
  static const String stop = 'stop\n';
  static const String clipsCount = 'clips count\n';
  static const String clipsGet = 'clips get\n';
  static const String clipsClear = 'clips clear\n';
  static const String clipsRebuild = 'clips rebuild\n';
  static const String clipInfo = 'clip info\n';
  static const String transportInfo = 'transport info\n';
  static const String slotInfo = 'slot info\n';
  static const String slotUnblock = 'slot unblock\n';
  static const String externalDriveList = 'external drive list\n';
  static const String externalDriveSelected = 'external drive selected\n';
  static const String cacheInfo = 'cache info\n';
  static const String dynamicRange = 'dynamic range\n';
  static const String notify = 'notify\n';
  static const String remote = 'remote\n';
  static const String configuration = 'configuration\n';
  static const String uptime = 'uptime\n';
  static const String slateClips = 'slate clips\n';
  static const String slateProject = 'slate project\n';
  static const String slateLens = 'slate lens\n';
  static const String nasList = 'nas list\n';
  static const String nasDiscovered = 'nas discovered\n';
  static const String nasSelected = 'nas selected\n';
  static const String nasDeselect = 'nas deselect\n';
}

// Backwards-compatible command constants.
const String cHDDeviceInfo = HyperDeckCommand.deviceInfo;
const String cHDRecord = HyperDeckCommand.record;
const String cHDStop = HyperDeckCommand.stop;
const String cHDUpdateInfo = HyperDeckCommand.transportInfo;