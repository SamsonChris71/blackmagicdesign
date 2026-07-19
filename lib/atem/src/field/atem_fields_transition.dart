part of 'atem_fields.dart';

/// Mix transition properties (TMxP).
class TransitionMixField extends AtemField {
  TransitionMixField(super.rawData);

  @override
  String get code => AtemFieldCode.transitionMix;

  late final int meIndex = rawData[0];
  late final int rate = _readUint16(1);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() => 'TransitionMixField(me: $meIndex, rate: $rate)';
}

/// Dip transition properties (TDpP).
class TransitionDipField extends AtemField {
  TransitionDipField(super.rawData);

  @override
  String get code => AtemFieldCode.transitionDip;

  late final int meIndex = rawData[0];
  late final int rate = _readUint16(1);
  late final int dipSource = _readUint16(3);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'TransitionDipField(me: $meIndex, rate: $rate, dipSource: $dipSource)';
}

/// Wipe transition properties (TWpP).
class TransitionWipeField extends AtemField {
  TransitionWipeField(super.rawData);

  @override
  String get code => AtemFieldCode.transitionWipe;

  late final int meIndex = rawData[0];
  late final int pattern = _readUint16(1);
  late final int rate = _readUint16(3);
  late final bool reverse = rawData[5] != 0;
  late final bool flipFlop = rawData[6] != 0;
  late final int borderSize = _readUint16(7);
  late final int borderInput = _readUint16(9);
  late final int borderOuterWidth = _readUint16(11);
  late final int borderInnerWidth = _readUint16(13);
  late final int borderOuterSoftness = _readUint16(15);
  late final int borderInnerSoftness = _readUint16(17);
  late final int borderBevel = _readUint16(19);
  late final int borderBevelSoftness = _readUint16(21);
  late final int borderBevelPosition = _readUint16(23);
  late final int borderOpacity = _readUint16(25);
  late final int borderHue = _readUint16(27);
  late final int borderSaturation = _readUint16(29);
  late final int borderLuma = _readUint16(31);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'TransitionWipeField(me: $meIndex, pattern: $pattern, rate: $rate)';
}

/// DVE transition properties (TDvP).
class TransitionDveField extends AtemField {
  TransitionDveField(super.rawData);

  @override
  String get code => AtemFieldCode.transitionDve;

  late final int meIndex = rawData[0];
  late final int rate = _readUint16(1);
  late final int pattern = _readUint16(3);
  late final int patternRate = _readUint16(5);
  late final int patternReverse = _readUint16(7);
  late final int patternFlipFlop = _readUint16(9);
  late final int preMultiplied = _readUint16(11);
  late final int clip = _readUint16(13);
  late final int gain = _readUint16(15);
  late final int invertKey = _readUint16(17);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() => 'TransitionDveField(me: $meIndex, rate: $rate)';
}

/// Stinger transition properties (TStP).
class TransitionStingerField extends AtemField {
  TransitionStingerField(super.rawData);

  @override
  String get code => AtemFieldCode.transitionStinger;

  late final int meIndex = rawData[0];
  late final int rate = _readUint16(1);
  late final int triggerPoint = _readUint16(3);
  late final int preMultiplied = _readUint16(5);
  late final int clip = _readUint16(7);
  late final int gain = _readUint16(9);
  late final int invertKey = _readUint16(11);
  late final int mixRate = _readUint16(13);

  int _readUint16(int offset) => (rawData[offset] << 8) | rawData[offset + 1];

  @override
  String toString() =>
      'TransitionStingerField(me: $meIndex, rate: $rate, trigger: $triggerPoint)';
}
