/// ATEM state management.
library atem_state;

import 'dart:collection';
import '../field/atem_fields.dart';

/// ATEM switcher state.
class AtemState {
  AtemState();

  // Video state
  final Map<int, int> _programInputs = {}; // meIndex -> source
  final Map<int, int> _previewInputs = {}; // meIndex -> source
  VideoMode _videoMode = VideoMode.unknown;
  bool _autoVideoModeEnabled = false;
  bool _autoVideoModeDetected = false;

  // Transition state
  final Map<int, TransitionState> _transitions = {};

  // Keyer state
  final Map<int, Map<int, KeyerState>> _keyers =
      {}; // meIndex -> keyerIndex -> state

  // Aux outputs
  final Map<int, int> _auxSources = {};

  // Media players
  final Map<int, MediaPlayerState> _mediaPlayers = {};

  // SuperSource
  final Map<int, SuperSourceState> _superSources = {};

  // Multiviewers
  final Map<int, MultiviewerState> _multiviewers = {};

  // Audio
  final Map<int, AudioStripState> _audioStrips = {};
  final Map<int, AudioMasterState> _audioMasters = {};

  // Fairlight
  final Map<String, FairlightStripState> _fairlightStrips = {};
  final Map<int, FairlightMasterState> _fairlightMasters = {};

  // Macros
  final Map<int, MacroProperties> _macros = {};

  // Recording/Streaming
  RecordingState _recordingState = RecordingState();
  StreamingState _streamingState = StreamingState();

  // Device info
  ProductModel _productModel = ProductModel.unknown;
  String _productName = '';
  String _firmwareVersion = '';
  Topology? _topology;

  // Connection state
  bool _connected = false;

  // Getters
  Map<int, int> get programInputs => UnmodifiableMapView(_programInputs);
  Map<int, int> get previewInputs => UnmodifiableMapView(_previewInputs);
  VideoMode get videoMode => _videoMode;
  bool get autoVideoModeEnabled => _autoVideoModeEnabled;
  bool get autoVideoModeDetected => _autoVideoModeDetected;
  Map<int, TransitionState> get transitions =>
      UnmodifiableMapView(_transitions);
  Map<int, Map<int, KeyerState>> get keyers => UnmodifiableMapView(_keyers);
  Map<int, int> get auxSources => UnmodifiableMapView(_auxSources);
  Map<int, MediaPlayerState> get mediaPlayers =>
      UnmodifiableMapView(_mediaPlayers);
  Map<int, SuperSourceState> get superSources =>
      UnmodifiableMapView(_superSources);
  Map<int, MultiviewerState> get multiviewers =>
      UnmodifiableMapView(_multiviewers);
  Map<int, AudioStripState> get audioStrips =>
      UnmodifiableMapView(_audioStrips);
  Map<int, AudioMasterState> get audioMasters =>
      UnmodifiableMapView(_audioMasters);
  Map<String, FairlightStripState> get fairlightStrips =>
      UnmodifiableMapView(_fairlightStrips);
  Map<int, FairlightMasterState> get fairlightMasters =>
      UnmodifiableMapView(_fairlightMasters);
  Map<int, MacroProperties> get macros => UnmodifiableMapView(_macros);
  RecordingState get recordingState => _recordingState;
  StreamingState get streamingState => _streamingState;
  ProductModel get productModel => _productModel;
  String get productName => _productName;
  String get firmwareVersion => _firmwareVersion;
  Topology? get topology => _topology;
  bool get isConnected => _connected;

  // State setters (called by connection)
  void setProgramInput(int meIndex, int source) {
    _programInputs[meIndex] = source;
  }

  void setPreviewInput(int meIndex, int source) {
    _previewInputs[meIndex] = source;
  }

  void setVideoMode(VideoMode mode) {
    _videoMode = mode;
  }

  void setAutoVideoMode(bool enabled, bool detected) {
    _autoVideoModeEnabled = enabled;
    _autoVideoModeDetected = detected;
  }

  void updateTransition(int meIndex, TransitionState state) {
    _transitions[meIndex] = state;
  }

  void updateKeyer(int meIndex, int keyerIndex, KeyerState state) {
    _keyers.putIfAbsent(meIndex, () => {})[keyerIndex] = state;
  }

  void setAuxSource(int auxIndex, int source) {
    _auxSources[auxIndex] = source;
  }

  void updateMediaPlayer(int index, MediaPlayerState state) {
    _mediaPlayers[index] = state;
  }

  void updateSuperSource(int index, SuperSourceState state) {
    _superSources[index] = state;
  }

  void updateMultiviewer(int index, MultiviewerState state) {
    _multiviewers[index] = state;
  }

  void updateAudioStrip(int index, AudioStripState state) {
    _audioStrips[index] = state;
  }

  void updateAudioMaster(int index, AudioMasterState state) {
    _audioMasters[index] = state;
  }

  void updateFairlightStrip(String stripId, FairlightStripState state) {
    _fairlightStrips[stripId] = state;
  }

  void updateFairlightMaster(int index, FairlightMasterState state) {
    _fairlightMasters[index] = state;
  }

  void updateMacro(int index, MacroProperties macro) {
    if (macro.used) {
      _macros[index] = macro;
    } else {
      _macros.remove(index);
    }
  }

  void updateRecordingState(RecordingState state) {
    _recordingState = state;
  }

  void updateStreamingState(StreamingState state) {
    _streamingState = state;
  }

  void setProductInfo(ProductModel model, String name, String version) {
    _productModel = model;
    _productName = name;
    _firmwareVersion = version;
  }

  void setTopology(Topology topology) {
    _topology = topology;
  }

  void setConnected(bool connected) {
    _connected = connected;
  }
}

/// Transition state.
class TransitionState {
  TransitionState({
    this.position = 0,
    this.preview = false,
    this.type = TransitionType.mix,
    this.style = TransitionStyle.mix,
    this.rate = 50,
    this.nextTransition = 0,
  });

  final int position; // 0-65535
  final bool preview;
  final TransitionType type;
  final TransitionStyle style;
  final int rate;
  final int nextTransition;

  double get positionNormalized => position / 65535.0;

  bool get inTransition => position > 0 && position < 65535;

  TransitionState copyWith({
    int? position,
    bool? preview,
    TransitionType? type,
    TransitionStyle? style,
    int? rate,
    int? nextTransition,
  }) {
    return TransitionState(
      position: position ?? this.position,
      preview: preview ?? this.preview,
      type: type ?? this.type,
      style: style ?? this.style,
      rate: rate ?? this.rate,
      nextTransition: nextTransition ?? this.nextTransition,
    );
  }
}

/// Keyer state.
class KeyerState {
  KeyerState({
    this.keyType = KeyType.off,
    this.enabled = false,
    this.flyEnabled = false,
    this.fillSource = 0,
    this.keySource = 0,
    this.maskEnabled = false,
    this.maskTop = 0,
    this.maskBottom = 0,
    this.maskLeft = 0,
    this.maskRight = 0,
    // DVE properties
    this.dveSizeX = 10000,
    this.dveSizeY = 10000,
    this.dvePosX = 0,
    this.dvePosY = 0,
    this.dveRotation = 0,
    this.dveBorderEnabled = false,
    this.dveBorderOuterWidth = 0,
    this.dveBorderInnerWidth = 0,
    this.dveBorderOuterSoftness = 0,
    this.dveBorderInnerSoftness = 0,
    this.dveBorderBevelSoftness = 0,
    this.dveBorderBevelPosition = 0,
    this.dveBorderOpacity = 0,
    this.dveBorderHue = 0,
    this.dveBorderSaturation = 0,
    this.dveBorderLuma = 0,
    this.dveLightAngle = 0,
    this.dveLightAltitude = 0,
    // Luma key
    this.lumaPremultiplied = false,
    this.lumaClip = 0,
    this.lumaGain = 1000,
    this.lumaInverted = false,
    // Chroma key
    this.chromaForeground = 500,
    this.chromaBackground = 500,
    this.chromaKeyEdge = 500,
    this.chromaSpill = 0,
    this.chromaFlare = 0,
    this.chromaBrightness = 0,
    this.chromaContrast = 0,
    this.chromaSaturation = 1000,
    this.chromaRed = 0,
    this.chromaGreen = 0,
    this.chromaBlue = 0,
    // Pattern
    this.patternStyle = 0,
    this.patternSize = 100,
    this.patternSymmetry = 100,
    this.patternSoftness = 0,
    this.patternInverted = false,
  });

  final KeyType keyType;
  final bool enabled;
  final bool flyEnabled;
  final int fillSource;
  final int keySource;
  final bool maskEnabled;
  final int maskTop;
  final int maskBottom;
  final int maskLeft;
  final int maskRight;

  // DVE
  final int dveSizeX;
  final int dveSizeY;
  final int dvePosX;
  final int dvePosY;
  final int dveRotation;
  final bool dveBorderEnabled;
  final int dveBorderOuterWidth;
  final int dveBorderInnerWidth;
  final int dveBorderOuterSoftness;
  final int dveBorderInnerSoftness;
  final int dveBorderBevelSoftness;
  final int dveBorderBevelPosition;
  final int dveBorderOpacity;
  final int dveBorderHue;
  final int dveBorderSaturation;
  final int dveBorderLuma;
  final int dveLightAngle;
  final int dveLightAltitude;

  // Luma
  final bool lumaPremultiplied;
  final int lumaClip;
  final int lumaGain;
  final bool lumaInverted;

  // Chroma
  final int chromaForeground;
  final int chromaBackground;
  final int chromaKeyEdge;
  final int chromaSpill;
  final int chromaFlare;
  final int chromaBrightness;
  final int chromaContrast;
  final int chromaSaturation;
  final int chromaRed;
  final int chromaGreen;
  final int chromaBlue;

  // Pattern
  final int patternStyle;
  final int patternSize;
  final int patternSymmetry;
  final int patternSoftness;
  final bool patternInverted;

  bool get onAir => enabled;
  bool get isDve => keyType == KeyType.dve;
  bool get isLuma => keyType == KeyType.luma;
  bool get isChroma => keyType == KeyType.chroma;
  bool get isPattern => keyType == KeyType.pattern;

  KeyerState copyWith() => this; // Simplified
}

/// Media player state.
class MediaPlayerState {
  MediaPlayerState({
    this.index = 0,
    this.clipIndex = 0,
    this.playing = false,
    this.atStart = false,
    this.loop = false,
    this.clipName = '',
    this.frames = 0,
    this.frameRate = 0,
    this.width = 0,
    this.height = 0,
    this.source = 0,
    this.audioSource = 0,
    this.audioGain = 0,
    this.audioBalance = 0,
    this.audioMute = false,
  });

  final int index;
  final int clipIndex;
  final bool playing;
  final bool atStart;
  final bool loop;
  final String clipName;
  final int frames;
  final int frameRate;
  final int width;
  final int height;
  final int source;
  final int audioSource;
  final int audioGain;
  final int audioBalance;
  final bool audioMute;
}

/// SuperSource state.
class SuperSourceState {
  SuperSourceState({
    this.index = 0,
    this.fillSource = 0,
    this.keySource = 0,
    this.layer = 0,
    this.premultiplied = false,
    this.clip = 0,
    this.gain = 1000,
    this.inverted = false,
    this.boxes = const [],
  });

  final int index;
  final int fillSource;
  final int keySource;
  final int layer;
  final bool premultiplied;
  final int clip;
  final int gain;
  final bool inverted;
  final List<SuperSourceBox> boxes;
}

/// SuperSource box.
class SuperSourceBox {
  SuperSourceBox({
    this.index = 0,
    this.enabled = false,
    this.source = 0,
    this.x = 0,
    this.y = 0,
    this.size = 1000,
    this.masked = false,
    this.maskTop = 0,
    this.maskBottom = 0,
    this.maskLeft = 0,
    this.maskRight = 0,
  });

  final int index;
  final bool enabled;
  final int source;
  final int x;
  final int y;
  final int size;
  final bool masked;
  final int maskTop;
  final int maskBottom;
  final int maskLeft;
  final int maskRight;
}

/// Multiviewer state.
class MultiviewerState {
  MultiviewerState({
    this.index = 0,
    this.layout = 0,
    this.flip = false,
    this.windows = const {},
  });

  final int index;
  final int layout;
  final bool flip;
  final Map<int, MultiviewerWindow> windows;
}

/// Multiviewer window.
class MultiviewerWindow {
  MultiviewerWindow({
    this.index = 0,
    this.source = 0,
    this.vuSupported = false,
    this.safeAreaSupported = false,
    this.vuEnabled = false,
    this.safeAreaEnabled = false,
  });

  final int index;
  final int source;
  final bool vuSupported;
  final bool safeAreaSupported;
  final bool vuEnabled;
  final bool safeAreaEnabled;
}

/// Audio strip state.
class AudioStripState {
  AudioStripState({
    this.index = 0,
    this.type = FairlightStripType.audioInput,
    this.mixOption = 0,
    this.gain = 0,
    this.balance = 0,
    this.mute = false,
    this.solo = false,
    this.faderGain = 0,
    this.faderMute = false,
  });

  final int index;
  final FairlightStripType type;
  final int mixOption;
  final int gain;
  final int balance;
  final bool mute;
  final bool solo;
  final int faderGain;
  final bool faderMute;
}

/// Audio master state.
class AudioMasterState {
  AudioMasterState({
    this.index = 0,
    this.gain = 0,
    this.balance = 0,
    this.mute = false,
    this.solo = false,
    this.faderGain = 0,
    this.faderMute = false,
  });

  final int index;
  final int gain;
  final int balance;
  final bool mute;
  final bool solo;
  final int faderGain;
  final bool faderMute;
}

/// Fairlight strip state.
class FairlightStripState {
  FairlightStripState({
    this.stripId = '',
    this.index = 0,
    this.subChannel = 0,
    this.type = FairlightStripType.audioInput,
    this.gain = 0.0,
    this.balance = 0.0,
    this.mute = false,
    this.solo = false,
    this.faderGain = 0.0,
    this.faderMute = false,
    this.inputLeft = -60.0,
    this.inputRight = -60.0,
    this.outputLeft = -60.0,
    this.outputRight = -60.0,
    this.faderLeft = -60.0,
    this.faderRight = -60.0,
  });

  final String stripId;
  final int index;
  final int subChannel;
  final FairlightStripType type;
  final double gain;
  final double balance;
  final bool mute;
  final bool solo;
  final double faderGain;
  final bool faderMute;
  final double inputLeft;
  final double inputRight;
  final double outputLeft;
  final double outputRight;
  final double faderLeft;
  final double faderRight;
}

/// Fairlight master state.
class FairlightMasterState {
  FairlightMasterState({
    this.index = 0,
    this.inputLeft = -60.0,
    this.inputRight = -60.0,
    this.outputLeft = -60.0,
    this.outputRight = -60.0,
    this.faderLeft = -60.0,
    this.faderRight = -60.0,
  });

  final int index;
  final double inputLeft;
  final double inputRight;
  final double outputLeft;
  final double outputRight;
  final double faderLeft;
  final double faderRight;
}

/// Macro properties.
class MacroProperties {
  MacroProperties({
    this.index = 0,
    this.used = false,
    this.invalid = false,
    this.name = '',
    this.description = '',
  });

  final int index;
  final bool used;
  final bool invalid;
  final String name;
  final String description;
}

/// Recording state.
class RecordingState {
  RecordingState({
    this.recording = false,
    this.stopping = false,
    this.diskFull = false,
    this.diskError = false,
    this.diskUnformatted = false,
    this.droppedFrames = false,
    this.durationHours = 0,
    this.durationMinutes = 0,
    this.durationSeconds = 0,
    this.durationFrames = 0,
    this.timeAvailable = 0,
  });

  final bool recording;
  final bool stopping;
  final bool diskFull;
  final bool diskError;
  final bool diskUnformatted;
  final bool droppedFrames;
  final int durationHours;
  final int durationMinutes;
  final int durationSeconds;
  final int durationFrames;
  final int timeAvailable;

  String get duration => '${durationHours.toString().padLeft(2, '0')}:'
      '${durationMinutes.toString().padLeft(2, '0')}:'
      '${durationSeconds.toString().padLeft(2, '0')}:'
      '${durationFrames.toString().padLeft(2, '0')}';
}

/// Streaming state.
class StreamingState {
  StreamingState({
    this.state = StreamingStateEnum.idle,
    this.bitrate = 0,
    this.cacheUsed = 0,
    this.serviceName = '',
    this.serviceUrl = '',
    this.minBitrate = 0,
    this.maxBitrate = 0,
  });

  final StreamingStateEnum state;
  final int bitrate;
  final int cacheUsed;
  final String serviceName;
  final String serviceUrl;
  final int minBitrate;
  final int maxBitrate;
}

/// Streaming state enum.
enum StreamingStateEnum {
  unknown(-1),
  idle(0),
  nothing(1),
  connecting(2),
  onAir(4),
  stopping(22);

  final int value;
  const StreamingStateEnum(this.value);

  static StreamingStateEnum fromValue(int value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => StreamingStateEnum.unknown,
    );
  }
}

/// Topology info.
class Topology {
  Topology({
    this.meCount = 0,
    this.keyerCount = 0,
    this.dskCount = 0,
    this.auxCount = 0,
    this.mediaPlayerCount = 0,
    this.superSourceCount = 0,
    this.multiviewerCount = 0,
    this.audioMixerChannels = 0,
  });

  final int meCount;
  final int keyerCount;
  final int dskCount;
  final int auxCount;
  final int mediaPlayerCount;
  final int superSourceCount;
  final int multiviewerCount;
  final int audioMixerChannels;
}
