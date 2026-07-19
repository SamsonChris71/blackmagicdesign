part of 'atem_fields.dart';

/// Video mode field (VidM).
class VideoModeField extends AtemField {
  VideoModeField(super.rawData);

  @override
  String get code => AtemFieldCode.videoMode;

  late final int mode = _readUint8(0);

  int _readUint8(int offset) => rawData[offset];

  VideoMode get videoMode {
    return VideoMode.values.firstWhere(
      (e) => e.value == mode,
      orElse: () => VideoMode.unknown,
    );
  }

  @override
  String toString() => 'VideoModeField(mode: $videoMode)';
}

/// Video mode enum.
enum VideoMode {
  unknown(0),
  format1080i5994(1),
  format1080i50(2),
  format1080p2398(3),
  format1080p24(4),
  format1080p25(5),
  format1080p2997(6),
  format1080p30(7),
  format1080p50(8),
  format1080p5994(9),
  format1080p60(10),
  format720p50(11),
  format720p5994(12),
  format720p60(13),
  format2160p2398(14),
  format2160p24(15),
  format2160p25(16),
  format2160p2997(17),
  format2160p30(18),
  format2160p50(19),
  format2160p5994(20),
  format2160p60(21),
  format1080p500p2398(22),
  format1000p24(23),
  format1000p25(24),
  format1000p2997(25),
  format1000p30(26),
  format1000p50(27),
  format1000p5994(28),
  format1000p60(29);

  final int value;
  const VideoMode(this.value);

  String get nameString {
    switch (this) {
      case VideoMode.format1080i5994:
        return '1080i59.94';
      case VideoMode.format1080i50:
        return '1080i50';
      case VideoMode.format1080p2398:
        return '1080p23.98';
      case VideoMode.format1080p24:
        return '1080p24';
      case VideoMode.format1080p25:
        return '1080p25';
      case VideoMode.format1080p2997:
        return '1080p29.97';
      case VideoMode.format1080p30:
        return '1080p30';
      case VideoMode.format1080p50:
        return '1080p50';
      case VideoMode.format1080p5994:
        return '1080p59.94';
      case VideoMode.format1080p60:
        return '1080p60';
      case VideoMode.format720p50:
        return '720p50';
      case VideoMode.format720p5994:
        return '720p59.94';
      case VideoMode.format720p60:
        return '720p60';
      case VideoMode.format2160p2398:
        return '2160p23.98';
      case VideoMode.format2160p24:
        return '2160p24';
      case VideoMode.format2160p25:
        return '2160p25';
      case VideoMode.format2160p2997:
        return '2160p29.97';
      case VideoMode.format2160p30:
        return '2160p30';
      case VideoMode.format2160p50:
        return '2160p50';
      case VideoMode.format2160p5994:
        return '2160p59.94';
      case VideoMode.format2160p60:
        return '2160p60';
      default:
        return 'Unknown($value)';
    }
  }
}

/// Program bus input (PrgI).
class ProgramInputField extends AtemField {
  ProgramInputField(super.rawData);

  @override
  String get code => AtemFieldCode.programInput;

  late final int meIndex = rawData[0];
  // Byte 1 is reserved; source is a big-endian 16-bit value at bytes 2-3.
  late final int source = _readUint16(2);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() => 'ProgramInputField(me: $meIndex, source: $source)';
}

/// Preview bus input (PrvI).
class PreviewInputField extends AtemField {
  PreviewInputField(super.rawData);

  @override
  String get code => AtemFieldCode.previewInput;

  late final int meIndex = rawData[0];
  // Byte 1 is reserved; source is a big-endian 16-bit value at bytes 2-3.
  late final int source = _readUint16(2);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() => 'PreviewInputField(me: $meIndex, source: $source)';
}

/// Transition position (TrPs).
class TransitionPositionField extends AtemField {
  TransitionPositionField(super.rawData);

  @override
  String get code => AtemFieldCode.transitionPosition;

  late final int meIndex = rawData[0];
  late final int position = _readUint16(1);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  double get positionNormalized => position / 65535.0;

  @override
  String toString() =>
      'TransitionPositionField(me: $meIndex, position: $position, '
      'normalized: ${positionNormalized.toStringAsFixed(3)})';
}

/// Transition preview (TrPr).
class TransitionPreviewField extends AtemField {
  TransitionPreviewField(super.rawData);

  @override
  String get code => AtemFieldCode.transitionPreview;

  late final int meIndex = rawData[0];
  late final bool preview = rawData[1] != 0;

  @override
  String toString() =>
      'TransitionPreviewField(me: $meIndex, preview: $preview)';
}

/// Transition settings (TrSS).
class TransitionSettingsField extends AtemField {
  TransitionSettingsField(super.rawData);

  @override
  String get code => AtemFieldCode.transitionSettings;

  late final int meIndex = rawData[0];
  late final int transitionType = rawData[1];
  late final int transitionStyle = _readUint16(2);
  late final int rate = _readUint16(4);
  late final int nextTransition = rawData[6];

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  TransitionType get type {
    return TransitionType.values.firstWhere(
      (e) => e.value == transitionType,
      orElse: () => TransitionType.mix,
    );
  }

  TransitionStyle get style {
    return TransitionStyle.values.firstWhere(
      (e) => e.value == transitionStyle,
      orElse: () => TransitionStyle.mix,
    );
  }

  @override
  String toString() =>
      'TransitionSettingsField(me: $meIndex, type: $type, style: $style, '
      'rate: $rate, next: $nextTransition)';
}

/// Transition type enum.
enum TransitionType {
  mix(0),
  dip(1),
  wipe(2),
  dve(3),
  stinger(4);

  final int value;
  const TransitionType(this.value);
}

/// Transition style enum.
enum TransitionStyle {
  mix(0),
  dip(1),
  wipe(2),
  dve(3),
  stinger(4);

  final int value;
  const TransitionStyle(this.value);
}

/// Input properties (InPr).
class InputPropertiesField extends AtemField {
  InputPropertiesField(super.rawData);

  @override
  String get code => AtemFieldCode.inputProperties;

  late final int mask = rawData[0];
  late final int sourceIndex = _readUint16(2);
  late final String longName = _readString(4, 20);
  late final String shortName = _readString(24, 4);
  late final int portType = _readUint16(28);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  String _readString(int offset, int length) {
    final bytes = rawData.sublist(offset, offset + length);
    final end = bytes.indexOf(0);
    return String.fromCharCodes(end >= 0 ? bytes.sublist(0, end) : bytes);
  }

  bool get hasLongName => (mask & 0x01) != 0;
  bool get hasShortName => (mask & 0x02) != 0;
  bool get hasPortType => (mask & 0x04) != 0;

  @override
  String toString() =>
      'InputPropertiesField(index: $sourceIndex, long: "$longName", '
      'short: "$shortName", portType: $portType)';
}

/// Product ID field (_pin).
class ProductIdField extends AtemField {
  ProductIdField(super.rawData);

  @override
  String get code => AtemFieldCode.productId;

  late final String productName = _readString(0);

  String _readString(int offset) {
    final end = rawData.indexOf(0, offset);
    return String.fromCharCodes(
        end >= 0 ? rawData.sublist(offset, end) : rawData.sublist(offset));
  }

  ProductModel get model => ProductModel.fromString(productName);

  @override
  String toString() => 'ProductIdField(name: $productName, model: $model)';
}

/// Product model enum.
enum ProductModel {
  unknown('Unknown'),
  atemMini('ATEM Mini'),
  atemMiniPro('ATEM Mini Pro'),
  atemMiniProIso('ATEM Mini Pro ISO'),
  atemMiniExtreme('ATEM Mini Extreme'),
  atemMiniExtremeIso('ATEM Mini Extreme ISO'),
  atem1M('ATEM 1 M/E'),
  atem2M('ATEM 2 M/E'),
  atem4M('ATEM 4 M/E'),
  atemConstellation8k('ATEM Constellation 8K'),
  atemConstellation4k('ATEM Constellation 4K'),
  atemTelevisionStudio('ATEM Television Studio'),
  atemTelevisionStudio4k('ATEM Television Studio 4K'),
  atemTelevisionStudioPro4k('ATEM Television Studio Pro 4K'),
  atemTelevisionStudioPro('ATEM Television Studio Pro'),
  atemTelevisionStudioHD('ATEM Television Studio HD'),
  atemTelevisionStudioHD8('ATEM Television Studio HD8'),
  atemProductionStudio4k('ATEM Production Studio 4K'),
  atemBroadcastStudio4k('ATEM Broadcast Studio 4K'),
  atemBroadcastStudio('ATEM Broadcast Studio'),
  atemProductionStudio('ATEM Production Studio');

  final String displayName;
  const ProductModel(this.displayName);

  static ProductModel fromString(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('mini extreme iso')) {
      return ProductModel.atemMiniExtremeIso;
    }
    if (lower.contains('mini extreme')) {
      return ProductModel.atemMiniExtreme;
    }
    if (lower.contains('mini pro iso')) {
      return ProductModel.atemMiniProIso;
    }
    if (lower.contains('mini pro')) {
      return ProductModel.atemMiniPro;
    }
    if (lower.contains('mini')) {
      return ProductModel.atemMini;
    }
    if (lower.contains('constellation 8k')) {
      return ProductModel.atemConstellation8k;
    }
    if (lower.contains('constellation 4k')) {
      return ProductModel.atemConstellation4k;
    }
    if (lower.contains('television studio pro 4k')) {
      return ProductModel.atemTelevisionStudioPro4k;
    }
    if (lower.contains('television studio pro')) {
      return ProductModel.atemTelevisionStudioPro;
    }
    if (lower.contains('television studio hd8')) {
      return ProductModel.atemTelevisionStudioHD8;
    }
    if (lower.contains('television studio hd')) {
      return ProductModel.atemTelevisionStudioHD;
    }
    if (lower.contains('television studio 4k')) {
      return ProductModel.atemTelevisionStudio4k;
    }
    if (lower.contains('television studio')) {
      return ProductModel.atemTelevisionStudio;
    }
    if (lower.contains('production studio 4k')) {
      return ProductModel.atemProductionStudio4k;
    }
    if (lower.contains('broadcast studio 4k')) {
      return ProductModel.atemBroadcastStudio4k;
    }
    if (lower.contains('broadcast studio')) {
      return ProductModel.atemBroadcastStudio;
    }
    if (lower.contains('production studio')) {
      return ProductModel.atemProductionStudio;
    }
    if (lower.contains('4 m/e')) {
      return ProductModel.atem4M;
    }
    if (lower.contains('2 m/e')) {
      return ProductModel.atem2M;
    }
    if (lower.contains('1 m/e')) {
      return ProductModel.atem1M;
    }
    return ProductModel.unknown;
  }
}

/// Firmware version field (_ver).
class FirmwareVersionField extends AtemField {
  FirmwareVersionField(super.rawData);

  @override
  String get code => AtemFieldCode.firmwareVersion;

  late final int major = rawData[0];
  late final int minor = rawData[1];
  late final int patch = rawData[2];
  late final int build = rawData[3];

  String get versionString => '$major.$minor.$patch.$build';

  @override
  String toString() => 'FirmwareVersionField(version: $versionString)';
}

/// Topology field (_top).
class TopologyField extends AtemField {
  TopologyField(super.rawData);

  @override
  String get code => AtemFieldCode.topology;

  late final int meCount = rawData[0];
  late final int keyerCount = rawData[1];
  late final int dskCount = rawData[2];
  late final int auxCount = rawData[3];
  late final int mediaPlayerCount = rawData[4];
  late final int superSourceCount = rawData[5];
  late final int multiviewerCount = rawData[6];
  late final int audioMixerChannels = rawData[7];

  @override
  String toString() =>
      'TopologyField(MEs: $meCount, Keyers: $keyerCount, DSKs: $dskCount, '
      'Aux: $auxCount, MediaPlayers: $mediaPlayerCount, SuperSources: $superSourceCount, '
      'Multiviewers: $multiviewerCount, AudioChannels: $audioMixerChannels)';
}

/// Mixer effect config (_MeC).
class MixerEffectConfigField extends AtemField {
  MixerEffectConfigField(super.rawData);

  @override
  String get code => AtemFieldCode.mixerEffectConfig;

  late final int meIndex = rawData[0];
  late final int keyerCount = rawData[1];
  late final int dskCount = rawData[2];
  late final int superSourceCount = rawData[3];

  @override
  String toString() =>
      'MixerEffectConfigField(me: $meIndex, keyers: $keyerCount, '
      'dsks: $dskCount, superSources: $superSourceCount)';
}

/// Multiviewer config (_MvC).
class MultiviewerConfigField extends AtemField {
  MultiviewerConfigField(super.rawData);

  @override
  String get code => AtemFieldCode.multiviewerConfig;

  late final int count = rawData[0];
  late final int windows = rawData[1];

  @override
  String toString() =>
      'MultiviewerConfigField(count: $count, windows: $windows)';
}

/// Fairlight audio config (_FAC).
class FairlightAudioConfigField extends AtemField {
  FairlightAudioConfigField(super.rawData);

  @override
  String get code => AtemFieldCode.fairlightAudioConfig;

  late final int stripCount = _readUint16(0);
  late final int masterCount = rawData[2];
  late final int headphoneCount = rawData[3];

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'FairlightAudioConfigField(strips: $stripCount, masters: $masterCount, '
      'headphones: $headphoneCount)';
}

/// Video mode capability (_VMC).
class VideoModeCapabilityField extends AtemField {
  VideoModeCapabilityField(super.rawData);

  @override
  String get code => AtemFieldCode.videoModeCapability;

  late final int count = _readUint16(0);
  late final List<VideoMode> modes = _readModes();

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  List<VideoMode> _readModes() {
    final modes = <VideoMode>[];
    for (var i = 0; i < count; i++) {
      final offset = 2 + i * 2;
      if (offset + 1 < rawData.length) {
        final modeVal = _readUint16(offset);
        try {
          modes.add(VideoMode.values.firstWhere(
            (e) => e.value == modeVal,
            orElse: () => VideoMode.unknown,
          ));
        } catch (_) {
          modes.add(VideoMode.unknown);
        }
      }
    }
    return modes;
  }

  @override
  String toString() => 'VideoModeCapabilityField(modes: $modes)';
}

/// Macro config (_MAC).
class MacroConfigField extends AtemField {
  MacroConfigField(super.rawData);

  @override
  String get code => AtemFieldCode.macroConfig;

  late final int slotCount = _readUint16(0);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() => 'MacroConfigField(slots: $slotCount)';
}

/// DVE capabilities (_DVE).
class DveCapabilitiesField extends AtemField {
  DveCapabilitiesField(super.rawData);

  @override
  String get code => AtemFieldCode.dveCapabilities;

  late final int count = rawData[0];

  @override
  String toString() => 'DveCapabilitiesField(count: $count)';
}

/// Power status (Powr).
class PowerStatusField extends AtemField {
  PowerStatusField(super.rawData);

  @override
  String get code => AtemFieldCode.powerStatus;

  late final int psu1 = rawData[0];
  late final int psu2 = rawData[1];

  bool get hasPsu1 => psu1 != 0;
  bool get hasPsu2 => psu2 != 0;

  @override
  String toString() => 'PowerStatusField(psu1: $hasPsu1, psu2: $hasPsu2)';
}

/// Media player slots (_mpl).
class MediaPlayerSlotsField extends AtemField {
  MediaPlayerSlotsField(super.rawData);

  @override
  String get code => AtemFieldCode.mediaPlayerSlots;

  late final int count = rawData[0];

  @override
  String toString() => 'MediaPlayerSlotsField(count: $count)';
}

/// Init complete (InCm).
class InitCompleteField extends AtemField {
  InitCompleteField(super.rawData);

  @override
  String get code => AtemFieldCode.initComplete;

  @override
  String toString() => 'InitCompleteField()';
}
