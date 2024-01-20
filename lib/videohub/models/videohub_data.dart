import 'dart:convert';

import 'package:collection/collection.dart';

import 'device_info.dart';
import 'video_input.dart';
import 'video_output.dart';
import 'video_route.dart';

/// An incoming data snapshop from a Videohub unit
///
/// Contains device info and a list of inputs, outputs, and routes
class VideohubData {
  /// An incoming data snapshop from a Videohub unit
  ///
  /// Contains device info and a list of inputs, outputs, and routes
  VideohubData({
    required this.deviceInfo,
    required this.inputMap,
    required this.outputMap,
    required this.takeMode,
  });

  /// Detailed info about a single Videohub unit
  final VideohubDeviceInfo deviceInfo;

  /// Map of input indexes to inputs on the device
  final Map<int, VideoInput> inputMap;

  /// Map of output indexes to outputs on the device
  final Map<int, VideoOutput> outputMap;

  /// Take mode is enabled
  final bool takeMode;

  /// List of inputs on the device
  List<VideoInput> get inputs => inputMap.values.toList();

  /// List of outputs on the device
  List<VideoOutput> get outputs => outputMap.values.toList();

  /// List of all active input/output pairs (routes)
  List<VideoRoute> get routes => outputMap.values
      .where((e) => e.inputSourceIndex != null)
      .map((e) {
        final input = inputMap[e.inputSourceIndex];
        if (input != null) {
          return VideoRoute(input: input, output: e);
        }

        return null;
      })
      .whereNotNull()
      .toList();

  /// Creates a copy of this object with modified properties
  VideohubData copyWith({
    VideohubDeviceInfo? deviceInfo,
    Map<int, VideoInput>? inputMap,
    Map<int, VideoOutput>? outputMap,
    bool? takeMode,
  }) {
    return VideohubData(
      deviceInfo: deviceInfo ?? this.deviceInfo,
      inputMap: inputMap ?? this.inputMap,
      outputMap: outputMap ?? this.outputMap,
      takeMode: takeMode ?? this.takeMode,
    );
  }

  /// Serialize to Map
  Map<String, dynamic> toMap() {
    return {
      'deviceInfo': deviceInfo.toMap(),
      'inputMap': inputMap,
      'outputMap': outputMap,
      'takeMode': takeMode,
    };
  }

  /// Deserialize from Map
  factory VideohubData.fromMap(Map<String, dynamic> map) {
    return VideohubData(
      deviceInfo: VideohubDeviceInfo.fromMap(map['deviceInfo']),
      inputMap: Map<int, VideoInput>.from(map['inputMap']),
      outputMap: Map<int, VideoOutput>.from(map['outputMap']),
      takeMode: map['takeMode'],
    );
  }

  /// Serialize to JSON string
  String toJson() => json.encode(toMap());

  /// Deserialize from JSON string
  factory VideohubData.fromJson(String source) =>
      VideohubData.fromMap(json.decode(source));

  @override
  String toString() =>
      'VideohubData(deviceInfo: $deviceInfo, inputMap: $inputMap, outputMap: $outputMap, takeMode: $takeMode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideohubData &&
        other.deviceInfo == deviceInfo &&
        DeepCollectionEquality().equals(other.inputMap, inputMap) &&
        DeepCollectionEquality().equals(other.outputMap, outputMap) &&
        other.takeMode == takeMode;
  }

  @override
  int get hashCode =>
      deviceInfo.hashCode ^
      inputMap.hashCode ^
      outputMap.hashCode ^
      takeMode.hashCode;
}
