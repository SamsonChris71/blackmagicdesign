/*
  This package isn't finished yet.
  Don't use it.
*/

class ATEM {
  /// IP address of the ATEM to connect to
  String atemIP = '';
  bool status = false;

  /// Name of the ATEM
  String deviceName = '';

  /// Port to connect via telnet
  int port = 9993;

  /// Most recent data received from the ATEM
  String responseData = '';
}
