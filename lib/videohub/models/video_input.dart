import 'dart:convert';

import 'base_video_connection.dart';

/// An input to the Videohub
class VideoInput extends BaseVideoConnection {
  /// An input to the Videohub
  VideoInput({
    required super.index,
    super.label = '',
  });

  @override
  VideoInput copyWith({
    int? index,
    String? label,
  }) {
    return VideoInput(
      index: index ?? this.index,
      label: label ?? this.label,
    );
  }

  /// Serialize to Map
  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'label': label,
    };
  }

  /// Deserialize from Map
  factory VideoInput.fromMap(Map<String, dynamic> map) {
    return VideoInput(
      index: map['index']?.toInt() ?? 0,
      label: map['label'] ?? '',
    );
  }

  /// Serialize to JSON string
  String toJson() => json.encode(toMap());

  /// Deserialize from JSON string
  factory VideoInput.fromJson(String source) =>
      VideoInput.fromMap(json.decode(source));

  @override
  String toString() => 'VideoInput(index: $index, label: $label)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoInput && other.index == index && other.label == label;
  }

  @override
  int get hashCode => index.hashCode ^ label.hashCode;
}
