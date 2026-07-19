part of 'atem_fields.dart';

/// Base class for all ATEM state fields.
abstract class AtemField {
  AtemField(this.rawData);

  /// Raw field data.
  final Uint8List rawData;

  /// The 4-character field code.
  String get code;

  @override
  String toString() => '$runtimeType($code)';
}

/// Unknown field fallback.
class UnknownField extends AtemField {
  UnknownField(this.fieldCode, super.rawData);

  final String fieldCode;

  @override
  String get code => fieldCode;

  @override
  String toString() => 'UnknownField($fieldCode, ${rawData.length} bytes)';
}

/// ATEM field codes.
class AtemFieldCode {
  // Identity and config
  static const String productId = '_pin';
  static const String firmwareVersion = '_ver';
  static const String topology = '_top';
  static const String mixerEffectConfig = '_MeC';
  static const String multiviewerConfig = '_MvC';
  static const String fairlightAudioConfig = '_FAC';
  static const String videoModeCapability = '_VMC';
  static const String macroConfig = '_MAC';
  static const String dveCapabilities = '_DVE';
  static const String powerStatus = 'Powr';
  static const String mediaPlayerSlots = '_mpl';
  static const String supersourceConfig = '_SSC';

  // Video
  static const String videoMode = 'VidM';
  static const String inputProperties = 'InPr';
  static const String programInput = 'PrgI';
  static const String previewInput = 'PrvI';

  // Transitions
  static const String transitionSettings = 'TrSS';
  static const String transitionPreview = 'TrPr';
  static const String transitionPosition = 'TrPs';
  static const String transitionMix = 'TMxP';
  static const String transitionDip = 'TDpP';
  static const String transitionWipe = 'TWpP';
  static const String transitionDve = 'TDvP';
  static const String transitionStinger = 'TStP';

  // Upstream keyers
  static const String keyOnAir = 'KeOn';
  static const String keyPropertiesBase = 'KeBP';
  static const String keyPropertiesLuma = 'KeLm';
  static const String keyPropertiesChroma = 'KACk';
  static const String keyPropertiesChromaPicker = 'KACC';
  static const String keyPropertiesPattern = 'KePt';
  static const String keyPropertiesDve = 'KeDV';
  static const String keyPropertiesFly = 'KeFS';
  static const String keyPropertiesFlyKeyframe = 'KKFP';

  // Downstream keyers
  static const String dskPropertiesBase = 'DskB';
  static const String dskProperties = 'DskP';
  static const String dskState = 'DskS';

  // Fade to black
  static const String fadeToBlack = 'FtbP';
  static const String fadeToBlackState = 'FtbS';
  static const String fadeToBlackEnabled = 'FEna';

  // Color generators
  static const String colorGenerator = 'ColV';

  // Aux outputs
  static const String auxSource = 'AuxS';

  // Media players
  static const String mediaplayerFileInfo = 'MPfe';
  static const String mediaplayerSelected = 'MPCE';
  static const String mediaplayerSpace = 'MPSp';
  static const String mediaplayerClipSource = 'MPCS';
  static const String mediaplayerAudioSource = 'MPAS';
  static const String mediaplayerClipStatus = 'RCPS';

  // Audio
  static const String audioMixerMaster = 'AMMO';
  static const String audioMixerMonitor = 'AMmO';
  static const String audioMixerTally = 'AMTl';
  static const String audioInput = 'AMIP';
  static const String audioMeterLevels = 'AMLv';

  // Fairlight
  static const String fairlightStripProperties = 'FASP';
  static const String fairlightMasterProperties = 'FAMP';
  static const String fairlightProperties = 'FMPP';
  static const String fairlightHeadphones = 'FMHP';
  static const String fairlightSolo = 'FAMS';
  static const String fairlightExpander = 'AIXP';
  static const String fairlightCompressor = 'AICP';
  static const String fairlightLimiter = 'AILP';
  static const String fairlightMasterCompressor = 'MOCP';
  static const String fairlightMasterLimiter = 'AMLP';
  static const String talkbackMixerProperties = 'ATMP';
  static const String talkbackMixerInput = 'TMIP';
  static const String mixMinusOutput = 'MMOP';
  static const String fairlightTally = 'FMTl';
  static const String fairlightMeterLevels = 'FMLv';
  static const String fairlightMasterLevels = 'FDLv';
  static const String fairlightAudioInput = 'FAIP';
  static const String fairlightStripDelete = 'FASD';

  // Tally
  static const String tallyConfig = '_TlC';
  static const String tallyIndex = 'TlIn';
  static const String tallySource = 'TlSr';

  // Camera control
  static const String cameraControlSettings = 'CCst';
  static const String cameraControlData = 'CCdP';

  // Time
  static const String time = 'Time';
  static const String timeConfig = 'TCCc';
  static const String timecodeLock = 'TcLk';

  // Multiviewer
  static const String multiviewerProperties = 'MvPr';
  static const String multiviewerInput = 'MvIn';
  static const String multiviewerVu = 'VuMC';
  static const String multiviewerVuOpacity = 'VuMo';
  static const String multiviewerSafeArea = 'SaMw';
  static const String multiviewerSafeAreaType = 'StMv';
  static const String multiviewerVideoModeCapability = 'MvVM';

  // SuperSource
  static const String supersourceProperties = 'SSrc';
  static const String supersourceBoxProperties = 'SSBP';

  // Macros
  static const String macroProperties = 'MPrp';
  static const String macroRecord = 'MSRc';
  static const String macroAction = 'MAct';
  static const String macroPlayStatus = 'MRPr';
  static const String macroRecordStatus = 'MRcS';

  // Recording
  static const String recordingDuration = 'RTMR';
  static const String recordingDisk = 'RTMD';
  static const String recordingStatus = 'RTMS';
  static const String recordingSettings = 'RMSu';

  // Streaming
  static const String streamingService = 'SRSU';
  static const String streamingAudioBitrate = 'STAB';
  static const String usbAudioFunction = 'UAFn';
  static const String streamingStatus = 'StRS';
  static const String streamingTime = 'SRST';
  static const String streamingStats = 'SRSS';
  static const String streamingAuth = 'SAth';

  // Auto video mode
  static const String autoInputVideoMode = 'AiVM';

  // Locks and transfers
  static const String lockCommand = 'LOCK';
  static const String partialLock = 'PLCK';
  static const String lockObtained = 'LKOB';
  static const String lockState = 'LKST';
  static const String transferDownloadRequest = 'FTSU';
  static const String transferUploadRequest = 'FTSD';
  static const String transferData = 'FTDa';
  static const String transferFileData = 'FTFD';
  static const String transferAck = 'FTUA';
  static const String transferContinue = 'FTCD';
  static const String transferError = 'FTDE';
  static const String transferComplete = 'FTDC';

  // Display clock
  static const String displayClockProperties = 'DCPV';
  static const String displayClockSetTime = 'DSTV';

  // Init
  static const String initComplete = 'InCm';
}
