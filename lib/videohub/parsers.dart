import 'models/device_info.dart';
import 'models/video_input.dart';
import 'models/video_output.dart';

/// Accepts a device info text block and parses it into a [VideohubDeviceInfo]
VideohubDeviceInfo parseDeviceInfo(
  String data, {
  VideohubDeviceInfo? deviceInfo,
}) {
  VideohubDeviceInfo device = deviceInfo ?? VideohubDeviceInfo();
  /*
    VIDEOHUB DEVICE:
    Device present: true
    Model name: Smart Videohub 12G 40x40
    Friendly name: MyVideoHub
    Unique ID: 7C2E5AB5C5DE
    Video inputs: 40
    Video processing units: 0
    Video outputs: 40
    Video monitoring outputs: 0
    Serial ports: 0
  */
  if (data.startsWith('VIDEOHUB DEVICE:')) {
    final lines = data.split('\n');
    device = device.copyWith(
      devicePresent: lines[1].parseValue == 'true',
      modelName: lines[2].parseValue,
      name: lines[3].parseValue,
      uniqueId: lines[4].parseValue,
      videoInputs: int.tryParse(lines[5].parseValue) ?? 0,
      processingUnits: int.tryParse(lines[6].parseValue) ?? 0,
      videoOutputs: int.tryParse(lines[7].parseValue) ?? 0,
      moinitoringOutputs: int.tryParse(lines[8].parseValue) ?? 0,
      serialPorts: int.tryParse(lines[9].parseValue) ?? 0,
    );
  }

  return device;
}

/// Accepts an input label text block and updates the map of [VideoOutput]
Map<int, VideoInput> parseInputLabels(
  String data,
  Map<int, VideoInput> inputs,
) {
  /*
    INPUT LABELS:
    0 01 RED
    1 02 Film
    2 03 Digital
    3 04 Aux
    4 SL PTZ
    5 OHC PTZ
    6 SR PTZ
    7 DS PTZ
    8 09 BB Presenter
    9 10 BB Aux 1
    10 11
  */
  if (data.startsWith('INPUT LABELS:')) {
    final lines = data.split('\n');
    for (final i in lines.sublist(1)) {
      final s = i.split(' ');
      final index = int.parse(s.first);
      final input = inputs[index] ?? VideoInput(index: index);
      inputs[index] = input.copyWith(label: s.sublist(1).join(' '));
    }
  }

  return inputs;
}

/// Accepts an output label text block and updates the map of [VideoOutput]
Map<int, VideoOutput> parseOutputLabels(
  String data,
  Map<int, VideoOutput> outputs,
) {
  /*
    OUTPUT LABELS:
    0 01 OLED 1
    1 02 Mon 2
    2 03 Mon 3
    3 04 Mon 4
    4 Op Desk 1A
    5 Op Desk 1B
    6 Op Desk 1C
    7 Op Desk 2A
    8 Op Desk 2B
    9 Op Desk 2C
    10 Op Desk 3A
  */
  if (data.startsWith('OUTPUT LABELS:')) {
    final lines = data.split('\n');
    for (final i in lines.sublist(1)) {
      final s = i.split(' ');
      final index = int.parse(s.first);
      final output = outputs[index] ?? VideoOutput(index: index);
      outputs[index] = output.copyWith(label: s.sublist(1).join(' '));
    }
  }

  return outputs;
}

/// Accepts an output lock text block and updates the map of [VideoOutput]
Map<int, VideoOutput> updateOutputLocks(
  String data,
  Map<int, VideoOutput> outputs,
) {
  /*
    VIDEO OUTPUT LOCKS:
    0 U
    1 U
    2 U
    3 U
    4 U
    5 U
    6 U
    7 U
    8 U
    9 U
    10 U
  */
  if (data.startsWith('VIDEO OUTPUT LOCKS:')) {
    final lines = data.split('\n');
    for (final i in lines.sublist(1)) {
      final s = i.split(' ');
      final index = int.parse(s.first);
      final output = outputs[index];
      if (output != null) {
        final locked = s.last == 'U' ? false : true;
        outputs[index] = output.copyWith(locked: locked);
      }
    }
  }

  return outputs;
}

/// Accepts an output routing text block and updates the map of [VideoOutput]
Map<int, VideoOutput> updateOutputRouting(
  String data,
  Map<int, VideoOutput> outputs,
) {
  /*
    VIDEO OUTPUT ROUTING:
    0 0
    1 0
    2 0
    3 17
    4 0
    5 0
    6 19
    7 20
    8 0
    9 0
    10 0
  */
  if (data.startsWith('VIDEO OUTPUT ROUTING:')) {
    final lines = data.split('\n');
    for (final i in lines.sublist(1)) {
      final s = i.split(' ');
      final index = int.parse(s.first);

      final output = outputs[index];
      if (output != null) {
        final input = int.parse(s.last);
        outputs[index] = output.copyWith(inputSourceIndex: input);
      }
    }
  }

  return outputs;
}

/// Shortcut for [this].split(':').last.trim()
extension ParseValue on String {
  /// Shortcut for [this].split(':').last.trim()
  String get parseValue => split(':').last.trim();
}
