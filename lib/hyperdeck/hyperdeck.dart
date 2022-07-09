import 'dart:io';
import 'hyperdeck_commands.dart';

/* 
  This package was tested against 'HypderDeck Studio Mini'
  No need to create objects. Call the class and access any data.
  This class uses default Dart I/O, so there's no need for third party packages.
  HyperDeck communicates via telnet protocol.
  For telnet protocol, This package uses dart's Socket class.
  Refer Example code or my github page for implementation.
  For contribution and clarification mail me: samsonchris71@gmail.com
*/
/// Hyperdeck control class
class HyperDeck {
  // Necessary Data
  /// IP address of the hyperdeck to connect to
  static String hyperDeckIP = '';
  static bool status = false;

  /// Port to connect via telnet
  static int port = 9993;

  /// Socket to hold the open connection, pass commands,
  /// and listen for events
  static Socket? socket;

  /// Most recent data received from the hyperdeck
  static String responseData = '';

  // Device Info
  /// Name of the hyperdeck device
  static String deviceName = '';

  /// Hyperdeck status
  static String deviceStatus = '';

  /// Speed
  static String speed = '';

  /// Slot ID
  static String slotId = '';

  /// Clip ID
  static String clipId = '';
  static String displayTimecode = '';

  /// Timecode
  static String timecode = '';

  /// Video format
  static String videoFormat = '';
  static String loop = '';
  static String timeline = '';

  /// Input video format
  static String inputVideoFormat = '';

  /// Connect to hyperdeck via open socket and listen to data
  static void connect() {
    Socket.connect(hyperDeckIP, port).then((Socket sock) {
      socket = sock;
      socket?.listen(
        dataHandler,
        onError: errorHandler,
        onDone: doneHandler,
        cancelOnError: false,
      );
    });
  }

  /// Handle data returned from connection protocol
  static void dataHandler(data) {
    status = true;
    responseData = String.fromCharCodes(data).trim();
    print('HyperDeck Response: $responseData');
    if (responseData.contains('connection info:')) {
      deviceName = responseData.split('\n').last.split(':').last.trim();
    }

    if (responseData.contains('transport info:')) {
      deviceStatus = responseData.split('\n')[1].split(':').last.trim();
      speed = responseData.split('\n')[2].split(':').last.trim();
      slotId = responseData.split('\n')[3].split(':').last.trim();
      clipId = responseData.split('\n')[4].split(':').last.trim();
      displayTimecode = responseData.split('\n')[6].split(' ').last.trim();
      timecode = responseData.split('\n')[7].split(':').last.trim();
      videoFormat = responseData.split('\n')[8].split(':').last.trim();
      loop = responseData.split('\n')[9].split(':').last.trim();
      timeline = responseData.split('\n')[10].split(':').last.trim();
      inputVideoFormat = responseData.split('\n')[11].split(':').last.trim();
    }
  }

  /// Handle error (if any) returned from connection protocol
  static void errorHandler(error, StackTrace trace) {
    print(error);
  }

  /// Destroy socket connection (once no longer needed)
  static void doneHandler() {
    socket?.destroy();
  }

  /// Get hyperdeck info
  static void deviceInfo() {
    socket?.write(cHDDeviceInfo);
  }

  /// Get current status of hyperdeck
  static void info() {
    socket?.write(cHDUpdateInfo);
  }

  /// Send record command to hyperdeck
  static void record() {
    socket?.write(cHDRecord);
  }

  /// Send stop command to hyperdeck
  static void stopRecording() {
    socket?.write(cHDUpdateInfo);
  }
}
