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

class HyperDeck {
  // Necessary Data
  static String hyperDeckIP = '';
  static bool status = false;
  static int port = 9993;
  static Socket socket;
  static String responseData;

  // Device Info
  static String deviceName;
  static String deviceStatus;
  static String speed;
  static String slotId;
  static String clipId;
  static String displayTimecode;
  static String timecode;
  static String videoFormat;
  static String loop;
  static String timeline;
  static String inputVideoFormat;

  // Basic connect protocol, sends connection package to the device
  static void connect() {
    Socket.connect(hyperDeckIP, port).then((Socket sock) {
      socket = sock;
      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
    });
  }

  // Method to handle data returned from connection protocol
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

  // Method to handle error (if any) returned from connection protocol
  static void errorHandler(error, StackTrace trace) {
    print(error);
  }

  // Method to destroy socket connection after use
  static void doneHandler() {
    socket.destroy();
  }

  // Method to get device info
  static void deviceInfo() {
    socket.write(cHDDeviceInfo);
  }

  // Method to get current status of hyperdeck
  static void info() {
    socket.write(cHDUpdateInfo);
  }

  // Method to send record command to HyperDeck
  static void record() {
    socket.write(cHDRecord);
  }

  // Method to send stop command to HyperDeck
  static void stopRecording() {
    socket.write(cHDUpdateInfo);
  }
}
