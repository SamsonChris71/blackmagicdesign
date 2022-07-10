/// Abstract base video connection to define fields and methods
/// for video inputs and outputs
abstract class BaseVideoConnection {
  /// Abstract base video connection to define fields and methods
  /// for video inputs and outputs
  BaseVideoConnection({
    required this.index,
    this.label = '',
  });

  /// The index used for routing commands
  final int index;

  /// The user-defined name that appears in the user interface
  final String label;

  /// Creates a copy of this object with modified properties
  BaseVideoConnection copyWith();

  @override
  String toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BaseVideoConnection &&
        other.index == index &&
        other.label == label;
  }

  @override
  int get hashCode => index.hashCode ^ label.hashCode;
}
