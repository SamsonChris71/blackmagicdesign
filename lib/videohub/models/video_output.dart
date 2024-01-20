import 'dart:convert';

import 'base_video_connection.dart';

/// An input to the Videohub
class VideoOutput extends BaseVideoConnection {
  /// An input to the Videohub
  VideoOutput({
    required super.index,
    super.label = '',
    this.locked = false,
    this.inputSourceIndex,
  });

  /// Patching is locked
  final bool locked;

  /// Index of the [VideoInput] that is currently feeding this output
  final int? inputSourceIndex;

  /// Creates a copy of this object with modified properties
  @override
  VideoOutput copyWith({
    int? index,
    String? label,
    bool? locked,
    int? inputSourceIndex,
  }) {
    return VideoOutput(
      index: index ?? this.index,
      label: label ?? this.label,
      locked: locked ?? this.locked,
      inputSourceIndex: inputSourceIndex ?? this.inputSourceIndex,
    );
  }

  /// Serialize to Map
  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'label': label,
      'locked': locked,
      'inputSourceIndex': inputSourceIndex,
    };
  }

  /// Deserialize from Map
  factory VideoOutput.fromMap(Map<String, dynamic> map) {
    return VideoOutput(
      index: map['index'],
      label: map['label'] ?? '',
      locked: map['locked'] ?? false,
      inputSourceIndex: map['inputSourceIndex']?.toInt() ?? 0,
    );
  }

  /// Serialize to JSON string
  String toJson() => json.encode(toMap());

  /// Deserialize from JSON string
  factory VideoOutput.fromJson(String source) =>
      VideoOutput.fromMap(json.decode(source));

  @override
  String toString() =>
      'VideoOutput(index: $index, label: $label, locked: $locked, inputSourceIndex: $inputSourceIndex)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoOutput &&
        other.index == index &&
        other.label == label &&
        other.locked == locked &&
        other.inputSourceIndex == inputSourceIndex;
  }

  @override
  int get hashCode =>
      index.hashCode ^
      label.hashCode ^
      locked.hashCode ^
      inputSourceIndex.hashCode;
}
