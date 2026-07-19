part of 'atem_fields.dart';

/// Audio mixer master properties (AMMO).
class AudioMixerMasterField extends AtemField {
  AudioMixerMasterField(super.rawData);

  @override
  String get code => AtemFieldCode.audioMixerMaster;

  late final int index = _readUint16(0);
  late final int mixOption = rawData[2];
  late final int gain = _readInt16(3);
  late final int balance = _readInt16(5);
  late final bool mute = rawData[7] != 0;
  late final bool solo = rawData[8] != 0;
  late final bool talkback = rawData[9] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];
  int _readInt16(int offset) =>
      ((rawData[offset] << 8) | rawData[offset + 1]) & 0xFFFF;

  @override
  String toString() =>
      'AudioMixerMasterField(index: $index, gain: $gain, balance: $balance, mute: $mute)';
}

/// Audio mixer monitor properties (AMmO).
class AudioMixerMonitorField extends AtemField {
  AudioMixerMonitorField(super.rawData);

  @override
  String get code => AtemFieldCode.audioMixerMonitor;

  late final int index = _readUint16(0);
  late final int gain = _readInt16(2);
  late final int dim = _readInt16(4);
  late final bool mute = rawData[6] != 0;
  late final bool solo = rawData[7] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];
  int _readInt16(int offset) =>
      ((rawData[offset] << 8) | rawData[offset + 1]) & 0xFFFF;

  @override
  String toString() =>
      'AudioMixerMonitorField(index: $index, gain: $gain, dim: $dim)';
}

/// Audio meter levels (AMLv).
class AudioMeterLevelsField extends AtemField {
  AudioMeterLevelsField(super.rawData);

  @override
  String get code => AtemFieldCode.audioMeterLevels;

  late final int channelCount = _readUint16(0);
  late final List<AudioLevel> master = _readLevels(2, 2);
  late final List<AudioLevel> monitor = _readLevels(10, 2);
  late final Map<int, AudioLevel> inputs = {};

  // Parse input levels
  late final int levelOffset = 18;
  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  List<AudioLevel> _readLevels(int offset, int count) {
    final levels = <AudioLevel>[];
    for (int i = 0; i < count; i++) {
      final left = _readUint32(offset + i * 8);
      final right = _readUint32(offset + i * 8 + 4);
      final leftPeak = _readUint32(offset + i * 8 + 8);
      final rightPeak = _readUint32(offset + i * 8 + 12);
      levels.add(AudioLevel(
        left: _levelToDb(left),
        right: _levelToDb(right),
        leftPeak: _levelToDb(leftPeak),
        rightPeak: _levelToDb(rightPeak),
      ));
    }
    return levels;
  }

  int _readUint32(int offset) =>
      (rawData[offset] << 24) |
      (rawData[offset + 1] << 16) |
      (rawData[offset + 2] << 8) |
      rawData[offset + 3];

  double _levelToDb(int value) {
    if (value == 0) return -60.0;
    final ratio = value / (128.0 * 65536.0);
    return 20 * (log(ratio) / log(10));
  }

  @override
  String toString() => 'AudioMeterLevelsField(channels: $channelCount)';
}

/// Audio level data.
class AudioLevel {
  const AudioLevel({
    required this.left,
    required this.right,
    required this.leftPeak,
    required this.rightPeak,
  });

  final double left;
  final double right;
  final double leftPeak;
  final double rightPeak;
}

/// Fairlight strip properties (FASP).
class FairlightStripPropertiesField extends AtemField {
  FairlightStripPropertiesField(super.rawData);

  @override
  String get code => AtemFieldCode.fairlightStripProperties;

  late final int stripId = _readUint16(0);
  late final int type = rawData[2];
  late final int mixOption = rawData[3];
  late final int gain = _readInt16(4);
  late final int balance = _readInt16(6);
  late final bool mute = rawData[8] != 0;
  late final bool solo = rawData[9] != 0;
  late final int faderGain = _readInt16(10);
  late final bool faderMute = rawData[12] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];
  int _readInt16(int offset) =>
      ((rawData[offset] << 8) | rawData[offset + 1]) & 0xFFFF;

  FairlightStripType get stripType {
    return FairlightStripType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => FairlightStripType.audioInput,
    );
  }

  @override
  String toString() =>
      'FairlightStripPropertiesField(id: $stripId, type: $stripType, gain: $gain)';
}

/// Fairlight strip type enum.
enum FairlightStripType {
  audioInput(0),
  audioOutput(1),
  audioBus(2),
  audioMaster(3),
  videoInput(4),
  videoOutput(5);

  final int value;
  const FairlightStripType(this.value);
}

/// Fairlight master properties (FAMP).
class FairlightMasterPropertiesField extends AtemField {
  FairlightMasterPropertiesField(super.rawData);

  @override
  String get code => AtemFieldCode.fairlightMasterProperties;

  late final int index = _readUint16(0);
  late final int gain = _readInt16(2);
  late final int balance = _readInt16(4);
  late final bool mute = rawData[6] != 0;
  late final bool solo = rawData[7] != 0;
  late final int faderGain = _readInt16(8);
  late final bool faderMute = rawData[10] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];
  int _readInt16(int offset) =>
      ((rawData[offset] << 8) | rawData[offset + 1]) & 0xFFFF;

  @override
  String toString() =>
      'FairlightMasterPropertiesField(index: $index, gain: $gain)';
}

/// Fairlight properties (FMPP).
class FairlightPropertiesField extends AtemField {
  FairlightPropertiesField(super.rawData);

  @override
  String get code => AtemFieldCode.fairlightProperties;

  late final int sampleRate = _readUint32(0);
  late final int frameRate = _readUint32(4);
  late final int bitDepth = rawData[8];
  late final int channels = rawData[9];

  int _readUint32(int offset) =>
      (rawData[offset] << 24) |
      (rawData[offset + 1] << 16) |
      (rawData[offset + 2] << 8) |
      rawData[offset + 3];

  @override
  String toString() =>
      'FairlightPropertiesField(sampleRate: $sampleRate, channels: $channels)';
}

/// Fairlight meter levels (FMLv).
class FairlightMeterLevelsField extends AtemField {
  FairlightMeterLevelsField(super.rawData);

  @override
  String get code => AtemFieldCode.fairlightMeterLevels;

  late final int source = _readUint16(8);
  late final int subChannel = rawData[10];
  late final double inputLeft = _readLevel(12);
  late final double inputRight = _readLevel(14);
  late final double inputPeakLeft = _readLevel(16);
  late final double inputPeakRight = _readLevel(18);
  late final double expanderGr = _readLevel(20);
  late final double compressorGr = _readLevel(22);
  late final double limiterGr = _readLevel(24);
  late final double outputLeft = _readLevel(26);
  late final double outputRight = _readLevel(28);
  late final double outputPeakLeft = _readLevel(30);
  late final double outputPeakRight = _readLevel(32);
  late final double faderLeft = _readLevel(34);
  late final double faderRight = _readLevel(36);
  late final double faderPeakLeft = _readLevel(38);
  late final double faderPeakRight = _readLevel(40);

  String get stripId => subChannel == 255 ? '$source.$subChannel' : '$source.0';

  int _readInt16(int offset) =>
      ((rawData[offset] << 8) | rawData[offset + 1]) & 0xFFFF;
  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  double _readLevel(int offset) {
    final value = _readInt16(offset);
    if (value == 0) return 0.0;
    return (value + 10000) / 10000.0;
  }

  @override
  String toString() => 'FairlightMeterLevelsField(strip: $stripId)';
}

/// Fairlight master levels (FDLv).
class FairlightMasterLevelsField extends AtemField {
  FairlightMasterLevelsField(super.rawData);

  @override
  String get code => AtemFieldCode.fairlightMasterLevels;

  late final double inputLeft = _readLevel(0);
  late final double inputRight = _readLevel(2);
  late final double inputPeakLeft = _readLevel(4);
  late final double inputPeakRight = _readLevel(6);
  late final double compressorGr = _readLevel(8);
  late final double limiterGr = _readLevel(10);
  late final double outputLeft = _readLevel(12);
  late final double outputRight = _readLevel(14);
  late final double outputPeakLeft = _readLevel(16);
  late final double outputPeakRight = _readLevel(18);
  late final double faderLeft = _readLevel(20);
  late final double faderRight = _readLevel(22);
  late final double faderPeakLeft = _readLevel(24);
  late final double faderPeakRight = _readLevel(26);

  int _readInt16(int offset) =>
      ((rawData[offset] << 8) | rawData[offset + 1]) & 0xFFFF;

  double _readLevel(int offset) {
    final value = _readInt16(offset);
    if (value == 0) return 0.0;
    return (value + 10000) / 10000.0;
  }

  @override
  String toString() => 'FairlightMasterLevelsField()';
}

/// Media player file info (MPfe).
class MediaPlayerFileInfoField extends AtemField {
  MediaPlayerFileInfoField(super.rawData);

  @override
  String get code => AtemFieldCode.mediaplayerFileInfo;

  late final int index = _readUint16(2);
  late final int frames = _readUint32(4);
  late final int frameRate = _readUint32(8);
  late final int width = _readUint16(12);
  late final int height = _readUint16(14);
  late final int format = _readUint16(16);
  late final int loop = _readUint16(18);
  late final String name = _readString(20, 64);
  late final String formatString = _readString(84, 32);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];
  int _readUint32(int offset) =>
      (rawData[offset] << 24) |
      (rawData[offset + 1] << 16) |
      (rawData[offset + 2] << 8) |
      rawData[offset + 3];

  String _readString(int offset, int length) {
    final end = rawData.sublist(offset, offset + length).indexOf(0);
    final actualEnd = end >= 0 ? offset + end : offset + length;
    return String.fromCharCodes(rawData.sublist(offset, actualEnd));
  }

  @override
  String toString() => 'MediaPlayerFileInfoField(index: $index, name: $name)';
}

/// Media player selected clip (MPCE).
class MediaPlayerSelectedField extends AtemField {
  MediaPlayerSelectedField(super.rawData);

  @override
  String get code => AtemFieldCode.mediaplayerSelected;

  late final int index = rawData[0];
  late final int clipIndex = _readUint16(1);
  late final bool playing = rawData[3] != 0;
  late final bool atStart = rawData[4] != 0;
  late final bool loop = rawData[5] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'MediaPlayerSelectedField(index: $index, clip: $clipIndex, playing: $playing)';
}

/// Media player clip source (MPCS).
class MediaPlayerClipSourceField extends AtemField {
  MediaPlayerClipSourceField(super.rawData);

  @override
  String get code => AtemFieldCode.mediaplayerClipSource;

  late final int index = rawData[0];
  late final int source = _readUint16(1);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'MediaPlayerClipSourceField(index: $index, source: $source)';
}

/// Media player audio source (MPAS).
class MediaPlayerAudioSourceField extends AtemField {
  MediaPlayerAudioSourceField(super.rawData);

  @override
  String get code => AtemFieldCode.mediaplayerAudioSource;

  late final int index = rawData[0];
  late final int source = _readUint16(1);
  late final int gain = _readInt16(3);
  late final int balance = _readInt16(5);
  late final bool mute = rawData[7] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];
  int _readInt16(int offset) =>
      ((rawData[offset] << 8) | rawData[offset + 1]) & 0xFFFF;

  @override
  String toString() =>
      'MediaPlayerAudioSourceField(index: $index, source: $source)';
}

/// Media player clip status (RCPS).
class MediaPlayerClipStatusField extends AtemField {
  MediaPlayerClipStatusField(super.rawData);

  @override
  String get code => AtemFieldCode.mediaplayerClipStatus;

  late final int index = rawData[0];
  late final int status = rawData[1];
  late final int frames = _readUint32(2);
  late final int frameRate = _readUint32(6);

  int _readUint32(int offset) =>
      (rawData[offset] << 24) |
      (rawData[offset + 1] << 16) |
      (rawData[offset + 2] << 8) |
      rawData[offset + 3];

  @override
  String toString() =>
      'MediaPlayerClipStatusField(index: $index, status: $status)';
}
