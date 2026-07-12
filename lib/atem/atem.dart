/// Shared connection settings for an ATEM switcher.
///
/// ATEM protocol commands are not implemented yet. This class is retained so
/// applications using the original package API can keep their connection
/// configuration in one place.
class ATEM {
  /// Address of the ATEM switcher.
  static String atemIP = '';

  /// Whether an ATEM connection is active.
  static bool status = false;

  /// Name reported by the connected switcher.
  static String deviceName = '';

  /// TCP port used by the ATEM protocol.
  static int port = 9993;

  /// Most recent response received from the switcher, if any.
  static String? responseData;
}
