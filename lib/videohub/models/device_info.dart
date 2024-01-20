import 'dart:convert';

/// Detailed info about a single Videohub unit
class VideohubDeviceInfo {
  /// Detailed info about a single Videohub unit
  VideohubDeviceInfo({
    this.protocolVersion = '',
    this.devicePresent = false,
    this.modelName = '',
    this.name = '',
    this.uniqueId = '',
    this.videoInputs = 0,
    this.videoOutputs = 0,
    this.processingUnits = 0,
    this.moinitoringOutputs = 0,
    this.serialPorts = 0,
  });

  /// Protocol version
  final String protocolVersion;

  /// Device presence
  final bool devicePresent;

  /// Name of the model (e.g. Smart Videohub 12G 40x40)
  final String modelName;

  /// User-defined "friendly" name
  final String name;

  /// Unique ID of this videohub
  final String uniqueId;

  /// Number of video inputs
  final int videoInputs;

  /// Number of video outputs
  final int videoOutputs;

  /// Number of processing units
  final int processingUnits;

  /// Number of video monitoring outputs
  final int moinitoringOutputs;

  /// Number of serial ports
  final int serialPorts;

  /// Creates a copy of this object with modified properties
  VideohubDeviceInfo copyWith({
    String? protocolVersion,
    bool? devicePresent,
    String? modelName,
    String? name,
    String? uniqueId,
    int? videoInputs,
    int? videoOutputs,
    int? processingUnits,
    int? moinitoringOutputs,
    int? serialPorts,
  }) {
    return VideohubDeviceInfo(
      protocolVersion: protocolVersion ?? this.protocolVersion,
      devicePresent: devicePresent ?? this.devicePresent,
      modelName: modelName ?? this.modelName,
      name: name ?? this.name,
      uniqueId: uniqueId ?? this.uniqueId,
      videoInputs: videoInputs ?? this.videoInputs,
      videoOutputs: videoOutputs ?? this.videoOutputs,
      processingUnits: processingUnits ?? this.processingUnits,
      moinitoringOutputs: moinitoringOutputs ?? this.moinitoringOutputs,
      serialPorts: serialPorts ?? this.serialPorts,
    );
  }

  @override
  String toString() {
    return 'VideohubDeviceInfo(protocolVersion: $protocolVersion, devicePresent: $devicePresent, modelName: $modelName, name: $name, uniqueId: $uniqueId, videoInputs: $videoInputs, videoOutputs: $videoOutputs, processingUnits: $processingUnits, moinitoringOutputs: $moinitoringOutputs, serialPorts: $serialPorts)';
  }

  /// Serialize to Map
  Map<String, dynamic> toMap() {
    return {
      'protocolVersion': protocolVersion,
      'devicePresent': devicePresent,
      'modelName': modelName,
      'name': name,
      'uniqueId': uniqueId,
      'videoInputs': videoInputs,
      'videoOutputs': videoOutputs,
      'processingUnits': processingUnits,
      'moinitoringOutputs': moinitoringOutputs,
      'serialPorts': serialPorts,
    };
  }

  /// Deserialize from Map
  factory VideohubDeviceInfo.fromMap(Map<String, dynamic> map) {
    return VideohubDeviceInfo(
      protocolVersion: map['protocolVersion'] ?? '',
      devicePresent: map['devicePresent'] ?? false,
      modelName: map['modelName'] ?? '',
      name: map['name'] ?? '',
      uniqueId: map['uniqueId'] ?? '',
      videoInputs: map['videoInputs']?.toInt() ?? 0,
      videoOutputs: map['videoOutputs']?.toInt() ?? 0,
      processingUnits: map['processingUnits']?.toInt() ?? 0,
      moinitoringOutputs: map['moinitoringOutputs']?.toInt() ?? 0,
      serialPorts: map['serialPorts']?.toInt() ?? 0,
    );
  }

  /// Serialize to JSON string
  String toJson() => json.encode(toMap());

  /// Deserialize from JSON string
  factory VideohubDeviceInfo.fromJson(String source) =>
      VideohubDeviceInfo.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideohubDeviceInfo &&
        other.protocolVersion == protocolVersion &&
        other.devicePresent == devicePresent &&
        other.modelName == modelName &&
        other.name == name &&
        other.uniqueId == uniqueId &&
        other.videoInputs == videoInputs &&
        other.videoOutputs == videoOutputs &&
        other.processingUnits == processingUnits &&
        other.moinitoringOutputs == moinitoringOutputs &&
        other.serialPorts == serialPorts;
  }

  @override
  int get hashCode {
    return protocolVersion.hashCode ^
        devicePresent.hashCode ^
        modelName.hashCode ^
        name.hashCode ^
        uniqueId.hashCode ^
        videoInputs.hashCode ^
        videoOutputs.hashCode ^
        processingUnits.hashCode ^
        moinitoringOutputs.hashCode ^
        serialPorts.hashCode;
  }
}
