import 'dart:convert';

import 'video_input.dart';
import 'video_output.dart';

/// A [VideoInput] paired with the [VideoOutput] which it is sending signal to
class VideoRoute {
  /// A [VideoInput] paired with the [VideoOutput] which it is sending signal to
  VideoRoute({
    required this.input,
    required this.output,
  });

  /// Input
  final VideoInput input;

  /// Output
  final VideoOutput output;

  /// Serialize to Map
  Map<String, dynamic> toMap() {
    return {
      'input': input.toMap(),
      'output': output.toMap(),
    };
  }

  /// Deserialize from Map
  factory VideoRoute.fromMap(Map<String, dynamic> map) {
    return VideoRoute(
      input: VideoInput.fromMap(map['input']),
      output: VideoOutput.fromMap(map['output']),
    );
  }

  /// Serialize to JSON string
  String toJson() => json.encode(toMap());

  /// Deserialize from JSON string
  factory VideoRoute.fromJson(String source) =>
      VideoRoute.fromMap(json.decode(source));

  @override
  String toString() => 'VideoRoute(input: $input, output: $output)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoRoute &&
        other.input == input &&
        other.output == output;
  }

  @override
  int get hashCode => input.hashCode ^ output.hashCode;

  /// Creates a copy of this object with modified properties
  VideoRoute copyWith({
    VideoInput? input,
    VideoOutput? output,
  }) {
    return VideoRoute(
      input: input ?? this.input,
      output: output ?? this.output,
    );
  }
}
