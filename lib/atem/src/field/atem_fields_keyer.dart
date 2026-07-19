part of 'atem_fields.dart';

/// Key on air (KeOn).
class KeyOnAirField extends AtemField {
  KeyOnAirField(super.rawData);

  @override
  String get code => AtemFieldCode.keyOnAir;

  late final int meIndex = rawData[0];
  late final int keyerIndex = rawData[1];
  late final bool onAir = rawData[2] != 0;

  @override
  String toString() =>
      'KeyOnAirField(me: $meIndex, keyer: $keyerIndex, onAir: $onAir)';
}

/// Key properties base (KeBP).
class KeyPropertiesBaseField extends AtemField {
  KeyPropertiesBaseField(super.rawData);

  @override
  String get code => AtemFieldCode.keyPropertiesBase;

  late final int meIndex = rawData[0];
  late final int keyerIndex = rawData[1];
  late final int keyType = rawData[2];
  late final bool enabled = rawData[3] != 0;
  late final bool flyEnabled = rawData[4] != 0;
  late final int fillSource = _readUint16(5);
  late final int keySource = _readUint16(7);
  late final bool maskEnabled = rawData[9] != 0;
  late final int maskTop = _readUint16(10);
  late final int maskBottom = _readUint16(12);
  late final int maskLeft = _readUint16(14);
  late final int maskRight = _readUint16(16);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  KeyType get type {
    return KeyType.values.firstWhere(
      (e) => e.value == keyType,
      orElse: () => KeyType.off,
    );
  }

  @override
  String toString() =>
      'KeyPropertiesBaseField(me: $meIndex, keyer: $keyerIndex, type: $type, '
      'enabled: $enabled, fill: $fillSource, key: $keySource)';
}

/// Key type enum.
enum KeyType {
  off(0),
  luma(1),
  chroma(2),
  pattern(3),
  dve(4),
  fly(5);

  final int value;
  const KeyType(this.value);
}

/// Aux output source (AuxS).
class AuxSourceField extends AtemField {
  AuxSourceField(super.rawData);

  @override
  String get code => AtemFieldCode.auxSource;

  late final int auxIndex = rawData[0];
  late final int source = _readUint16(1);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() => 'AuxSourceField(aux: $auxIndex, source: $source)';
}

/// Color generator (ColV).
class ColorGeneratorField extends AtemField {
  ColorGeneratorField(super.rawData);

  @override
  String get code => AtemFieldCode.colorGenerator;

  late final int index = rawData[0];
  late final int hue = _readUint16(1);
  late final int saturation = _readUint16(3);
  late final int luminance = _readUint16(5);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'ColorGeneratorField(index: $index, hue: $hue, sat: $saturation, lum: $luminance)';
}

/// Fade to black properties (FtbP).
class FadeToBlackField extends AtemField {
  FadeToBlackField(super.rawData);

  @override
  String get code => AtemFieldCode.fadeToBlack;

  late final int meIndex = rawData[0];
  late final int rate = _readUint16(1);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() => 'FadeToBlackField(me: $meIndex, rate: $rate)';
}

/// Fade to black state (FtbS).
class FadeToBlackStateField extends AtemField {
  FadeToBlackStateField(super.rawData);

  @override
  String get code => AtemFieldCode.fadeToBlackState;

  late final int meIndex = rawData[0];
  late final bool active = rawData[1] != 0;
  late final int position = _readUint16(2);
  late final int rate = _readUint16(4);
  late final bool fullyBlack = rawData[6] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  double get positionNormalized => position / 65535.0;

  @override
  String toString() => 'FadeToBlackStateField(me: $meIndex, active: $active, '
      'position: ${positionNormalized.toStringAsFixed(3)}, rate: $rate)';
}

/// DSK properties base (DskB).
class DskPropertiesBaseField extends AtemField {
  DskPropertiesBaseField(super.rawData);

  @override
  String get code => AtemFieldCode.dskPropertiesBase;

  late final int dskIndex = rawData[0];
  late final int fillSource = _readUint16(1);
  late final int keySource = _readUint16(3);
  late final bool enabled = rawData[5] != 0;
  late final int rate = _readUint16(6);
  late final int fillSource2 = _readUint16(8);
  late final int keySource2 = _readUint16(10);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'DskPropertiesBaseField(dsk: $dskIndex, fill: $fillSource, '
      'key: $keySource, enabled: $enabled, rate: $rate)';
}

/// DSK properties (DskP).
class DskPropertiesField extends AtemField {
  DskPropertiesField(super.rawData);

  @override
  String get code => AtemFieldCode.dskProperties;

  late final int dskIndex = rawData[0];
  late final int clip = _readUint16(1);
  late final int gain = _readUint16(3);
  late final bool invertKey = rawData[5] != 0;

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'DskPropertiesField(dsk: $dskIndex, clip: $clip, gain: $gain, invert: $invertKey)';
}

/// DSK state (DskS).
class DskStateField extends AtemField {
  DskStateField(super.rawData);

  @override
  String get code => AtemFieldCode.dskState;

  late final int dskIndex = rawData[0];
  late final bool onAir = rawData[1] != 0;
  late final bool transitioning = rawData[2] != 0;
  late final int position = _readUint16(3);
  late final int remainingFrames = _readUint16(5);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  double get positionNormalized => position / 65535.0;

  @override
  String toString() =>
      'DskStateField(dsk: $dskIndex, onAir: $onAir, transitioning: $transitioning, '
      'position: ${positionNormalized.toStringAsFixed(3)})';
}
