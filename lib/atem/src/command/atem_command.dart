/// ATEM command encoding and decoding.
///
/// Commands are encoded as an 8-byte record header followed by binary data.
/// Multiple command records can be packed into a single UDP packet.
library atem_command;

import 'dart:typed_data';

/// Packs multiple commands into a single packet payload.
Uint8List packCommands(Iterable<AtemCommand> commands) {
  final buffer = BytesBuilder();
  for (final cmd in commands) {
    buffer.add(cmd.toBytes());
  }
  return buffer.toBytes();
}

/// Unpacks a packet payload into individual commands.
List<AtemCommand> unpackCommands(Uint8List data) {
  final commands = <AtemCommand>[];
  var offset = 0;

  while (offset < data.length) {
    if (offset + 8 > data.length) {
      throw const FormatException('Incomplete ATEM command header');
    }

    final recordLength =
        ByteData.view(data.buffer, data.offsetInBytes + offset, 2).getUint16(0);
    if (recordLength < 8 || offset + recordLength > data.length) {
      throw FormatException('Invalid ATEM command length: $recordLength');
    }

    final code = _bytesToCode(data, offset + 4);
    final cmdData = data.sublist(offset + 8, offset + recordLength);
    commands.add(_AtemCommandImpl(code, cmdData));
    offset += recordLength;
  }

  return commands;
}

/// Converts a 4-character code to bytes.
Uint8List _codeToBytes(String code) {
  if (code.length != 4) {
    throw ArgumentError('Command code must be 4 characters: $code');
  }
  return Uint8List.fromList(code.codeUnits);
}

/// Converts 4 bytes to a command code string.
String _bytesToCode(Uint8List data, int offset) {
  return String.fromCharCodes(data.sublist(offset, offset + 4));
}

/// Common ATEM command codes.
class AtemCommandCode {
  // Connection
  static const String timeRequest = 'TiRq'; // Time request (keepalive)
  static const String timeOfDay = 'SToD'; // Set time of day

  // Video switching
  static const String programInput = 'PrgI'; // Program bus input
  static const String previewInput = 'PrvI'; // Preview bus input

  // Transitions
  static const String transitionPosition = 'TrPs'; // Transition position
  static const String transitionPreview = 'TrPr'; // Transition preview
  static const String transitionSettings = 'TrSS'; // Transition settings
  static const String transitionMix = 'TMxP'; // Mix transition
  static const String transitionDip = 'TDpP'; // Dip transition
  static const String transitionWipe = 'TWpP'; // Wipe transition
  static const String transitionDve = 'TDvP'; // DVE transition
  static const String transitionStinger = 'TStP'; // Stinger transition

  // Upstream keyers
  static const String keyOnAir = 'KeOn'; // Key on air
  static const String keyPropertiesBase = 'KeBP'; // Key properties base
  static const String keyPropertiesLuma = 'KeLm'; // Key properties luma
  static const String keyPropertiesChroma =
      'KACk'; // Key properties advanced chroma
  static const String keyPropertiesChromaPicker =
      'KACC'; // Key properties chroma color picker
  static const String keyPropertiesPattern = 'KePt'; // Key properties pattern
  static const String keyPropertiesDve = 'KeDV'; // Key properties DVE
  static const String keyPropertiesFly = 'KeFS'; // Key properties fly
  static const String keyPropertiesFlyKeyframe =
      'KKFP'; // Key properties fly keyframe

  // Downstream keyers
  static const String dskPropertiesBase = 'DskB'; // DSK properties base
  static const String dskProperties = 'DskP'; // DSK properties
  static const String dskState = 'DskS'; // DSK state

  // Fade to black
  static const String fadeToBlack = 'FtbP'; // Fade to black properties
  static const String fadeToBlackState = 'FtbS'; // Fade to black state

  // Color generators
  static const String colorGenerator = 'ColV'; // Color generator

  // Aux outputs
  static const String auxSource = 'AuxS'; // Aux output source

  // Media players
  static const String mediaPlayerFileInfo = 'MPfe'; // Media player file info
  static const String mediaPlayerSelected =
      'MPCE'; // Media player selected clip
  static const String mediaPlayerSpace = 'MPSp'; // Media player space
  static const String mediaPlayerClipSource =
      'MPCS'; // Media player clip source
  static const String mediaPlayerAudioSource =
      'MPAS'; // Media player audio source
  static const String mediaPlayerClipStatus =
      'RCPS'; // Media player clip status

  // Audio mixer
  static const String audioMixerMaster =
      'AMMO'; // Audio mixer master properties
  static const String audioMixerMonitor =
      'AMmO'; // Audio mixer monitor properties
  static const String audioMixerTally = 'AMTl'; // Audio mixer tally
  static const String audioInput = 'AMIP'; // Audio input properties
  static const String audioInputLevel = 'AMIL'; // Audio input level
  static const String audioMeterLevels = 'AMLv'; // Audio meter levels

  // Fairlight audio
  static const String fairlightStripProperties =
      'FASP'; // Fairlight strip properties
  static const String fairlightMasterProperties =
      'FAMP'; // Fairlight master properties
  static const String fairlightProperties = 'FMPP'; // Fairlight properties
  static const String fairlightHeadphones = 'FMHP'; // Fairlight headphones
  static const String fairlightSolo = 'FAMS'; // Fairlight solo
  static const String fairlightExpander = 'AIXP'; // Fairlight expander
  static const String fairlightCompressor = 'AICP'; // Fairlight compressor
  static const String fairlightLimiter = 'AILP'; // Fairlight limiter
  static const String fairlightMasterCompressor =
      'MOCP'; // Fairlight master compressor
  static const String fairlightMasterLimiter =
      'AMLP'; // Fairlight master limiter
  static const String fairlightTally = 'FMTl'; // Fairlight tally
  static const String fairlightMeterLevels = 'FMLv'; // Fairlight meter levels
  static const String fairlightMasterLevels = 'FDLv'; // Fairlight master levels
  static const String fairlightAudioInput = 'FAIP'; // Fairlight audio input
  static const String fairlightStripDelete = 'FASD'; // Fairlight strip delete

  // Talkback
  static const String talkbackMixerProperties =
      'ATMP'; // Talkback mixer properties
  static const String talkbackMixerInput =
      'TMIP'; // Talkback mixer input properties

  // Mix minus
  static const String mixMinusOutput = 'MMOP'; // Mix minus output properties

  // Tally
  static const String tallyConfig = '_TlC'; // Tally config
  static const String tallyIndex = 'TlIn'; // Tally index
  static const String tallySource = 'TlSr'; // Tally source

  // Camera control
  static const String cameraControlSettings = 'CCst'; // Camera control settings
  static const String cameraControlData = 'CCdP'; // Camera control data packet

  // Multiviewer
  static const String multiviewerProperties = 'MvPr'; // Multiviewer properties
  static const String multiviewerInput = 'MvIn'; // Multiviewer input
  static const String multiviewerVu = 'VuMC'; // Multiviewer VU meter
  static const String multiviewerVuOpacity = 'VuMo'; // Multiviewer VU opacity
  static const String multiviewerSafeArea = 'SaMw'; // Multiviewer safe area
  static const String multiviewerSafeAreaType =
      'StMv'; // Multiviewer safe area type
  static const String multiviewerConfig = '_MvC'; // Multiviewer config

  // SuperSource
  static const String supersourceConfig = '_SSC'; // SuperSource config
  static const String supersourceProperties = 'SSrc'; // SuperSource properties
  static const String supersourceBoxProperties =
      'SSBP'; // SuperSource box properties

  // Macros
  static const String macroProperties = 'MPrp'; // Macro properties
  static const String macroRecord = 'MSRc'; // Macro record
  static const String macroAction = 'MAct'; // Macro action
  static const String macroPlayStatus = 'MRPr'; // Macro play status
  static const String macroRecordStatus = 'MRcS'; // Macro record status
  static const String macroConfig = '_MAC'; // Macro config

  // Recording
  static const String recordingDuration = 'RTMR'; // Recording duration
  static const String recordingDisk = 'RTMD'; // Recording disk
  static const String recordingStatus = 'RTMS'; // Recording status
  static const String recordingSettings = 'RMSu'; // Recording settings

  // Streaming
  static const String streamingService = 'SRSU'; // Streaming service
  static const String streamingAudioBitrate = 'STAB'; // Streaming audio bitrate
  static const String usbAudioFunction = 'UAFn'; // USB audio function
  static const String streamingStatus = 'StRS'; // Streaming status
  static const String streamingTime = 'SRST'; // Streaming time
  static const String streamingStats = 'SRSS'; // Streaming stats
  static const String streamingAuth = 'SAth'; // Streaming authentication

  // Video mode
  static const String videoMode = 'VidM'; // Video mode
  static const String videoModeCapability = '_VMC'; // Video mode capability
  static const String autoInputVideoMode = 'AiVM'; // Auto input video mode

  // Input properties
  static const String inputProperties = 'InPr'; // Input properties

  // Identity and config
  static const String productId = '_pin'; // Product ID
  static const String firmwareVersion = '_ver'; // Firmware version
  static const String topology = '_top'; // Topology
  static const String mixerEffectConfig = '_MeC'; // Mixer effect config
  static const String multiviewerConfig_ =
      '_MvC'; // Multiviewer config (duplicate)
  static const String fairlightAudioConfig = '_FAC'; // Fairlight audio config
  static const String videoModeCapability_ = '_VMC'; // Video mode capability
  static const String multiviewerVideoModeCapability =
      'MvVM'; // Multiviewer video mode capability
  static const String macroConfig_ = '_MAC'; // Macro config
  static const String dveCapabilities = '_DVE'; // DVE capabilities
  static const String powerStatus = 'Powr'; // Power status
  static const String mediaPlayerSlots = '_mpl'; // Media player slots
  static const String supersourceConfig_ = '_SSC'; // SuperSource config

  // Locks and transfers
  static const String lockCommand = 'LOCK'; // Lock command
  static const String partialLock = 'PLCK'; // Partial lock
  static const String lockObtained = 'LKOB'; // Lock obtained
  static const String lockState = 'LKST'; // Lock state
  static const String transferDownloadRequest =
      'FTSU'; // Transfer download request
  static const String transferUploadRequest = 'FTSD'; // Transfer upload request
  static const String transferData = 'FTDa'; // Transfer data
  static const String transferFileData = 'FTFD'; // Transfer file data
  static const String transferAck = 'FTUA'; // Transfer ack
  static const String transferContinue = 'FTCD'; // Transfer continue
  static const String transferError = 'FTDE'; // Transfer error
  static const String transferComplete = 'FTDC'; // Transfer complete

  // Display clock
  static const String displayClockProperties =
      'DCPV'; // Display clock properties
  static const String displayClockSetTime = 'DSTV'; // Display clock set time

  // Fade to black enabled
  static const String fadeToBlackEnabled = 'FEna'; // Fade to black enabled

  // Init complete
  static const String initComplete = 'InCm'; // Init complete

  // HyperDeck (on ATEM with HyperDeck)
  static const String hyperDeckSettings = 'RXMS'; // HyperDeck settings
  static const String hyperDeckStatus = 'RXCP'; // HyperDeck status
  static const String hyperDeckStorage = 'RXSS'; // HyperDeck storage
  static const String hyperDeckClipCount = 'RXCC'; // HyperDeck clip count
}

/// Internal base class for AtemCommand.
abstract class AtemCommand {
  const AtemCommand();

  /// 4-character command code (e.g., 'PrgI', 'PrvI', 'CTlC').
  String get code;

  /// Command payload data.
  Uint8List get data;

  /// Serializes the command to bytes.
  Uint8List toBytes() {
    final codeBytes = _codeToBytes(code);
    final recordLength = 8 + data.length;
    if (recordLength > 0xFFFF) {
      throw ArgumentError('ATEM command is too large: $recordLength bytes');
    }

    // ATEM command records begin with a big-endian 16-bit record length and
    // two reserved bytes, followed by the command code and its payload.
    final result = Uint8List(recordLength);
    final header = ByteData.view(result.buffer);
    header.setUint16(0, recordLength);
    result.setRange(4, 8, codeBytes);
    result.setRange(8, result.length, data);
    return result;
  }

  /// Creates a command from a code and typed data builder.
  factory AtemCommand.from(String code, Uint8List Function() buildData) {
    return _AtemCommandImpl(code, buildData());
  }

  @override
  String toString() => 'AtemCommand($code, ${data.length} bytes)';
}

/// Private implementation of AtemCommand.
class _AtemCommandImpl extends AtemCommand {
  const _AtemCommandImpl(this.code, this.data);

  @override
  final String code;

  @override
  final Uint8List data;
}
