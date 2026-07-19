/// ATEM command implementations.
library atem_commands_impl;

import 'dart:typed_data';
import 'atem_command.dart';
import 'atem_command_builder.dart';

/// Program input command (CPgI).
class ProgramInputCommand extends AtemCommand {
  const ProgramInputCommand({required this.meIndex, required this.source});

  final int meIndex;
  final int source;

  @override
  String get code => 'CPgI';

  @override
  Uint8List get data => build();

  Uint8List build() {
    return AtemCommandBuilder()
        .addUint8(meIndex)
        .addPadding(1)
        .addUint16(source)
        .build();
  }
}

/// Preview input command (CPvI).
class PreviewInputCommand extends AtemCommand {
  const PreviewInputCommand({required this.meIndex, required this.source});

  final int meIndex;
  final int source;

  @override
  String get code => 'CPvI';

  @override
  Uint8List get data => build();

  Uint8List build() {
    return AtemCommandBuilder()
        .addUint8(meIndex)
        .addPadding(1)
        .addUint16(source)
        .build();
  }
}

/// Cut command - instant transition (Cut Preview).
class CutCommand extends AtemCommand {
  const CutCommand({required this.meIndex});

  final int meIndex;

  @override
  String get code => 'CTPr';

  @override
  Uint8List get data => build();

  Uint8List build() {
    return AtemCommandBuilder().addUint8(meIndex).addPadding(3).build();
  }
}

/// Auto transition command.
class AutoTransitionCommand extends AtemCommand {
  const AutoTransitionCommand({required this.meIndex});

  final int meIndex;

  @override
  String get code => 'ATPr';

  @override
  Uint8List get data => build();

  Uint8List build() {
    return AtemCommandBuilder().addUint8(meIndex).addPadding(3).build();
  }
}

/// Key on air command.
class KeyOnAirCommand extends AtemCommand {
  const KeyOnAirCommand({
    required this.meIndex,
    required this.keyerIndex,
    required this.onAir,
  });

  final int meIndex;
  final int keyerIndex;
  final bool onAir;

  @override
  String get code => 'KeOn';

  @override
  Uint8List get data => build();

  Uint8List build() {
    return AtemCommandBuilder()
        .addUint8(meIndex)
        .addUint8(keyerIndex)
        .addBool(onAir)
        .addPadding(1)
        .build();
  }
}

/// Key properties base command.
class KeyPropertiesBaseCommand extends AtemCommand {
  const KeyPropertiesBaseCommand({
    required this.meIndex,
    required this.keyerIndex,
    this.keyType,
    this.enabled,
    this.flyEnabled,
    this.fillSource,
    this.keySource,
    this.maskEnabled,
    this.maskTop,
    this.maskBottom,
    this.maskLeft,
    this.maskRight,
  });

  final int meIndex;
  final int keyerIndex;
  final int? keyType;
  final bool? enabled;
  final bool? flyEnabled;
  final int? fillSource;
  final int? keySource;
  final bool? maskEnabled;
  final int? maskTop;
  final int? maskBottom;
  final int? maskLeft;
  final int? maskRight;

  @override
  String get code => 'KeBP';

  @override
  Uint8List get data => build();

  Uint8List build() {
    int mask = 0;
    if (keyType != null) mask |= 1 << 0;
    if (enabled != null) mask |= 1 << 1;
    if (flyEnabled != null) mask |= 1 << 2;
    if (fillSource != null) mask |= 1 << 3;
    if (keySource != null) mask |= 1 << 4;
    if (maskEnabled != null) mask |= 1 << 5;
    if (maskTop != null) mask |= 1 << 6;
    if (maskBottom != null) mask |= 1 << 7;
    if (maskLeft != null) mask |= 1 << 8;
    if (maskRight != null) mask |= 1 << 9;

    return AtemCommandBuilder()
        .addUint8(mask & 0xFF)
        .addUint8((mask >> 8) & 0xFF)
        .addUint8(meIndex)
        .addUint8(keyerIndex)
        .addUint8(keyType ?? 0)
        .addBool(enabled ?? false)
        .addBool(flyEnabled ?? false)
        .addUint16(fillSource ?? 0)
        .addUint16(keySource ?? 0)
        .addBool(maskEnabled ?? false)
        .addUint16(maskTop ?? 0)
        .addUint16(maskBottom ?? 0)
        .addUint16(maskLeft ?? 0)
        .addUint16(maskRight ?? 0)
        .build();
  }
}

/// Aux source command.
class AuxSourceCommand extends AtemCommand {
  const AuxSourceCommand({required this.auxIndex, required this.source});

  final int auxIndex;
  final int source;

  @override
  String get code => 'AuxS';

  @override
  Uint8List get data => build();

  Uint8List build() {
    return AtemCommandBuilder()
        .addUint8(auxIndex)
        .addPadding(1)
        .addUint16(source)
        .build();
  }
}

/// Color generator command.
class ColorGeneratorCommand extends AtemCommand {
  const ColorGeneratorCommand({
    required this.index,
    this.hue,
    this.saturation,
    this.luminance,
  });

  final int index;
  final int? hue;
  final int? saturation;
  final int? luminance;

  @override
  String get code => 'ColV';

  @override
  Uint8List get data => build();

  Uint8List build() {
    int mask = 0;
    if (hue != null) mask |= 1 << 0;
    if (saturation != null) mask |= 1 << 1;
    if (luminance != null) mask |= 1 << 2;

    return AtemCommandBuilder()
        .addUint8(mask)
        .addPadding(1)
        .addUint8(index)
        .addUint16(hue ?? 0)
        .addUint16(saturation ?? 0)
        .addUint16(luminance ?? 0)
        .build();
  }
}

/// Fade to black command.
class FadeToBlackCommand extends AtemCommand {
  const FadeToBlackCommand({required this.meIndex, this.rate});

  final int meIndex;
  final int? rate;

  @override
  String get code => 'FtbP';

  @override
  Uint8List get data => build();

  Uint8List build() {
    int mask = 0;
    if (rate != null) mask |= 1 << 0;

    return AtemCommandBuilder()
        .addUint8(mask)
        .addPadding(1)
        .addUint8(meIndex)
        .addUint16(rate ?? 50)
        .build();
  }
}

/// Fade to black execute command.
class FadeToBlackExecuteCommand extends AtemCommand {
  const FadeToBlackExecuteCommand({required this.meIndex, required this.onAir});

  final int meIndex;
  final bool onAir;

  @override
  String get code => 'FtbS';

  @override
  Uint8List get data => build();

  Uint8List build() {
    return AtemCommandBuilder()
        .addUint8(meIndex)
        .addBool(onAir)
        .addPadding(2)
        .build();
  }
}
