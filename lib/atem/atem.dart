/*
  This package isn't finished yet.
  Don't use it.
*/

class ATEM {
  /// IP address of the ATEM to connect to
  static String atemIP = '';
  static bool status = false;

  /// Name of the ATEM
  static String deviceName = '';

  /// Port to connect via telnet
  static int port = 9993;

  /// Most recent data received from the ATEM
  static String responseData = '';
}
