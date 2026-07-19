part of 'atem_fields.dart';

/// Multiviewer properties (MvPr).
class MultiviewerPropertiesField extends AtemField {
  MultiviewerPropertiesField(super.rawData);

  @override
  String get code => AtemFieldCode.multiviewerProperties;

  late final int index = rawData[0];
  late final int layout = rawData[1];
  late final bool flip = rawData[2] != 0;
  late final int u1 = rawData[3];

  bool get topLeftSmall => (layout & 0x01) != 0;
  bool get topRightSmall => (layout & 0x02) != 0;
  bool get bottomLeftSmall => (layout & 0x04) != 0;
  bool get bottomRightSmall => (layout & 0x08) != 0;

  @override
  String toString() =>
      'MultiviewerPropertiesField(index: $index, layout: $layout, flip: $flip)';
}

/// Multiviewer input (MvIn).
class MultiviewerInputField extends AtemField {
  MultiviewerInputField(super.rawData);

  @override
  String get code => AtemFieldCode.multiviewerInput;

  late final int index = rawData[0];
  late final int window = rawData[1];
  late final int source = _readUint16(2);
  late final bool vuSupported = rawData[4] != 0;
  late final bool safeAreaSupported = rawData[5] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'MultiviewerInputField(mv: $index, win: $window, src: $source)';
}

/// Multiviewer VU meter (VuMC).
class MultiviewerVuField extends AtemField {
  MultiviewerVuField(super.rawData);

  @override
  String get code => AtemFieldCode.multiviewerVu;

  late final int index = rawData[0];
  late final int window = rawData[1];
  late final bool enabled = rawData[2] != 0;

  @override
  String toString() =>
      'MultiviewerVuField(mv: $index, win: $window, enabled: $enabled)';
}

/// Multiviewer safe area (SaMw).
class MultiviewerSafeAreaField extends AtemField {
  MultiviewerSafeAreaField(super.rawData);

  @override
  String get code => AtemFieldCode.multiviewerSafeArea;

  late final int index = rawData[0];
  late final int window = rawData[1];
  late final bool enabled = rawData[2] != 0;

  @override
  String toString() =>
      'MultiviewerSafeAreaField(mv: $index, win: $window, enabled: $enabled)';
}

/// SuperSource properties (SSrc).
class SuperSourcePropertiesField extends AtemField {
  SuperSourcePropertiesField(super.rawData);

  @override
  String get code => AtemFieldCode.supersourceProperties;

  late final int index = rawData[0];
  late final int fillSource = _readUint16(2);
  late final int keySource = _readUint16(4);
  late final int layer = rawData[6];
  late final bool premultiplied = rawData[7] != 0;
  late final int clip = _readUint16(8);
  late final int gain = _readUint16(10);
  late final bool inverted = rawData[12] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'SuperSourcePropertiesField(index: $index, fill: $fillSource, key: $keySource)';
}

/// SuperSource box properties (SSBP).
class SuperSourceBoxPropertiesField extends AtemField {
  SuperSourceBoxPropertiesField(super.rawData);

  @override
  String get code => AtemFieldCode.supersourceBoxProperties;

  late final int index = rawData[0];
  late final int box = rawData[1];
  late final bool enabled = rawData[2] != 0;
  late final int source = _readUint16(4);
  late final int x = _readInt16(6);
  late final int y = _readInt16(8);
  late final int size = _readUint16(10);
  late final bool masked = rawData[12] != 0;
  late final int maskTop = _readUint16(14);
  late final int maskBottom = _readUint16(16);
  late final int maskLeft = _readUint16(18);
  late final int maskRight = _readUint16(20);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];
  int _readInt16(int offset) =>
      ((rawData[offset] << 8) | rawData[offset + 1]) & 0xFFFF;

  @override
  String toString() =>
      'SuperSourceBoxPropertiesField(index: $index, box: $box, '
      'enabled: $enabled, source: $source, x: $x, y: $y, size: $size)';
}

/// Macro properties (MPrp).
class MacroPropertiesField extends AtemField {
  MacroPropertiesField(super.rawData);

  @override
  String get code => AtemFieldCode.macroProperties;

  late final int index = _readUint16(0);
  late final bool used = rawData[2] != 0;
  late final bool invalid = rawData[3] != 0;
  late final int nameLen = _readUint16(4);
  late final int descLen = _readUint16(6);
  late final String name = _readString(8, nameLen);
  late final String description = _readString(8 + nameLen, descLen);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  String _readString(int offset, int length) {
    return String.fromCharCodes(rawData.sublist(offset, offset + length));
  }

  @override
  String toString() =>
      'MacroPropertiesField(index: $index, used: $used, name: $name)';
}

/// Macro record status (MRcS).
class MacroRecordStatusField extends AtemField {
  MacroRecordStatusField(super.rawData);

  @override
  String get code => AtemFieldCode.macroRecordStatus;

  late final bool recording = rawData[0] != 0;
  late final int index = _readUint16(2);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'MacroRecordStatusField(recording: $recording, index: $index)';
}

/// Macro play status (MRPr).
class MacroPlayStatusField extends AtemField {
  MacroPlayStatusField(super.rawData);

  @override
  String get code => AtemFieldCode.macroPlayStatus;

  late final int index = _readUint16(0);
  late final bool playing = rawData[2] != 0;
  late final bool atEnd = rawData[3] != 0;
  late final bool loop = rawData[4] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'MacroPlayStatusField(index: $index, playing: $playing, atEnd: $atEnd)';
}

/// Camera control settings (CCst).
class CameraControlSettingsField extends AtemField {
  CameraControlSettingsField(super.rawData);

  @override
  String get code => AtemFieldCode.cameraControlSettings;

  late final int index = rawData[0];
  late final int controlId = _readUint16(1);
  late final bool enabled = rawData[3] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'CameraControlSettingsField(index: $index, controlId: $controlId)';
}

/// Camera control data packet (CCdP).
class CameraControlDataPacketField extends AtemField {
  CameraControlDataPacketField(super.rawData);

  @override
  String get code => AtemFieldCode.cameraControlData;

  late final int destination = rawData[0];
  late final int category = rawData[1];
  late final int parameter = rawData[2];
  late final int dataType = rawData[3];
  late final List<int> data = rawData.sublist(16);

  @override
  String toString() =>
      'CameraControlDataPacketField(dest: $destination, cat: $category, '
      'param: $parameter, type: $dataType)';
}

/// Recording duration (RTMR).
class RecordingDurationField extends AtemField {
  RecordingDurationField(super.rawData);

  @override
  String get code => AtemFieldCode.recordingDuration;

  late final int hours = rawData[0];
  late final int minutes = rawData[1];
  late final int seconds = rawData[2];
  late final int frames = rawData[3];
  late final bool droppedFrames = rawData[4] != 0;

  String get timecode => '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}:'
      '${frames.toString().padLeft(2, '0')}';

  @override
  String toString() =>
      'RecordingDurationField(timecode: $timecode, dropped: $droppedFrames)';
}

/// Recording disk (RTMD).
class RecordingDiskField extends AtemField {
  RecordingDiskField(super.rawData);

  @override
  String get code => AtemFieldCode.recordingDisk;

  late final int index = _readUint32(0);
  late final int timeAvailable = _readInt32(4);
  late final int status = _readUint16(8);
  late final String volumeName = _readString(10, 64);

  int _readUint32(int offset) =>
      (rawData[offset] << 24) |
      (rawData[offset + 1] << 16) |
      (rawData[offset + 2] << 8) |
      rawData[offset + 3];
  int _readInt32(int offset) =>
      ((rawData[offset] << 24) |
          (rawData[offset + 1] << 16) |
          (rawData[offset + 2] << 8) |
          rawData[offset + 3]) &
      0xFFFFFFFF;
  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  String _readString(int offset, int length) {
    final end = rawData.sublist(offset, offset + length).indexOf(0);
    final actualEnd = end >= 0 ? offset + end : offset + length;
    return String.fromCharCodes(rawData.sublist(offset, actualEnd));
  }

  bool get isAttached => (status & 0x01) != 0;
  bool get isReady => (status & 0x04) != 0;
  bool get isRecording => (status & 0x08) != 0;
  bool get isDeleted => (status & 0x20) != 0;

  @override
  String toString() => 'RecordingDiskField(index: $index, name: $volumeName, '
      'attached: $isAttached, ready: $isReady, recording: $isRecording)';
}

/// Recording settings (RMSu).
class RecordingSettingsField extends AtemField {
  RecordingSettingsField(super.rawData);

  @override
  String get code => AtemFieldCode.recordingSettings;

  late final String filename = _readString(0, 128);
  late final int disk1 = _readInt32(128);
  late final int disk2 = _readInt32(132);
  late final bool recordInCameras = rawData[136] != 0;

  int _readInt32(int offset) =>
      ((rawData[offset] << 24) |
          (rawData[offset + 1] << 16) |
          (rawData[offset + 2] << 8) |
          rawData[offset + 3]) &
      0xFFFFFFFF;

  String _readString(int offset, int length) {
    final end = rawData.sublist(offset, offset + length).indexOf(0);
    final actualEnd = end >= 0 ? offset + end : offset + length;
    return String.fromCharCodes(rawData.sublist(offset, actualEnd));
  }

  @override
  String toString() =>
      'RecordingSettingsField(filename: $filename, disk1: $disk1, disk2: $disk2)';
}

/// Streaming service (SRSU).
class StreamingServiceField extends AtemField {
  StreamingServiceField(super.rawData);

  @override
  String get code => AtemFieldCode.streamingService;

  late final String name = _readString(0, 64);
  late final String url = _readString(64, 512);
  late final String key = _readString(576, 512);
  late final int minBitrate = _readUint32(1088);
  late final int maxBitrate = _readUint32(1092);

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
  String toString() =>
      'StreamingServiceField(name: $name, min: $minBitrate, max: $maxBitrate)';
}

/// Streaming status (StRS).
class StreamingStatusField extends AtemField {
  StreamingStatusField(super.rawData);

  @override
  String get code => AtemFieldCode.streamingStatus;

  late final int status = _readInt16(0);

  int _readInt16(int offset) =>
      ((rawData[offset] << 8) | rawData[offset + 1]) & 0xFFFF;

  StreamingState get state => StreamingState.fromValue(status);

  @override
  String toString() => 'StreamingStatusField(state: $state, raw: $status)';
}

/// Streaming state enum.
enum StreamingState {
  unknown(-1),
  idle(0),
  nothing(1),
  connecting(2),
  onAir(4),
  stopping(22);

  final int value;
  const StreamingState(this.value);

  static StreamingState fromValue(int value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => StreamingState.unknown,
    );
  }
}

/// Streaming stats (SRSS).
class StreamingStatsField extends AtemField {
  StreamingStatsField(super.rawData);

  @override
  String get code => AtemFieldCode.streamingStats;

  late final int bitrate = _readUint32(0);
  late final int cacheUsed = _readUint16(4);

  int _readUint32(int offset) =>
      (rawData[offset] << 24) |
      (rawData[offset + 1] << 16) |
      (rawData[offset + 2] << 8) |
      rawData[offset + 3];
  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'StreamingStatsField(bitrate: $bitrate, cache: $cacheUsed)';
}

/// Recording status (RTMS).
class RecordingStatusField extends AtemField {
  RecordingStatusField(super.rawData);

  @override
  String get code => AtemFieldCode.recordingStatus;

  late final int status = _readUint16(0);
  late final int timeAvailable = _readInt32(4);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];
  int _readInt32(int offset) =>
      ((rawData[offset] << 24) |
          (rawData[offset + 1] << 16) |
          (rawData[offset + 2] << 8) |
          rawData[offset + 3]) &
      0xFFFFFFFF;

  bool get isRecording => (status & 0x01) != 0;
  bool get isStopping => (status & 0x80) != 0;
  bool get diskFull => (status & 0x04) != 0;
  bool get diskError => (status & 0x08) != 0;
  bool get diskUnformatted => (status & 0x10) != 0;
  bool get hasDropped => (status & 0x20) != 0;

  @override
  String toString() =>
      'RecordingStatusField(status: $status, timeAvailable: $timeAvailable)';
}

/// Streaming audio bitrate (STAB).
class StreamingAudioBitrateField extends AtemField {
  StreamingAudioBitrateField(super.rawData);

  @override
  String get code => AtemFieldCode.streamingAudioBitrate;

  late final int min = _readUint32(0);
  late final int max = _readUint32(4);

  int _readUint32(int offset) =>
      (rawData[offset] << 24) |
      (rawData[offset + 1] << 16) |
      (rawData[offset + 2] << 8) |
      rawData[offset + 3];

  @override
  String toString() => 'StreamingAudioBitrateField(min: $min, max: $max)';
}

/// Camera control data packet (CCdP).
class CameraControlDataField extends AtemField {
  CameraControlDataField(super.rawData);

  @override
  String get code => AtemFieldCode.cameraControlData;

  late final int destination = rawData[0];
  late final int category = rawData[1];
  late final int parameter = rawData[2];
  late final int dataType = rawData[3];
  late final List<int> data = rawData.sublist(16);

  @override
  String toString() =>
      'CameraControlDataField(dest: $destination, cat: $category, '
      'param: $parameter, type: $dataType)';
}

/// USB audio function (UAFn).
class UsbAudioFunctionField extends AtemField {
  UsbAudioFunctionField(super.rawData);

  @override
  String get code => AtemFieldCode.usbAudioFunction;

  late final int function = _readUint16(0);
  late final int u1 = _readUint16(2);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  UsbAudioMode get mode {
    return UsbAudioMode.values.firstWhere(
      (e) => e.value == function,
      orElse: () => UsbAudioMode.webcam,
    );
  }

  @override
  String toString() => 'UsbAudioFunctionField(mode: $mode)';
}

/// USB audio mode enum.
enum UsbAudioMode {
  webcam(1),
  digitalAudio(2);

  final int value;
  const UsbAudioMode(this.value);
}

/// Auto input video mode (AiVM).
class AutoInputVideoModeField extends AtemField {
  AutoInputVideoModeField(super.rawData);

  @override
  String get code => AtemFieldCode.autoInputVideoMode;

  late final bool enabled = rawData[0] != 0;
  late final bool detected = rawData[1] != 0;

  @override
  String toString() =>
      'AutoInputVideoModeField(enabled: $enabled, detected: $detected)';
}

/// Fade to black enabled (FEna).
class FadeToBlackEnabledField extends AtemField {
  FadeToBlackEnabledField(super.rawData);

  @override
  String get code => AtemFieldCode.fadeToBlackEnabled;

  late final int meIndex = rawData[0];
  late final bool enabled = rawData[1] != 0;

  @override
  String toString() =>
      'FadeToBlackEnabledField(me: $meIndex, enabled: $enabled)';
}
