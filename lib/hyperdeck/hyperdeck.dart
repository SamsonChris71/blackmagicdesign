import 'dart:io';
import 'hyperdeck_commands.dart';

/* 
  This package was tested against 'HypderDeck Studio Mini'
  No need to create objects. Call the class and access any data.
  This class uses default Dart I/O, so there's no need for third party packages.
  HyperDeck communicates via telnet protocol.
  For telnet protocol, I used dart's Socket class.
  Refer Example code or my github page for implementation.
  For contribution and clarification mail me: samsonchris71@gmail.com
*/

class HyperDeck {
  // Necessary Data
  static String hyperDeckIP = '';
  static bool status = false;
  static String deviceName = '';
  static int port = 9993;
  static Socket socket;
  static String responseData;

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
  }

  // Method to handle error (if any) returned from connection protocol
  static void errorHandler(error, StackTrace trace) {
    print(error);
  }

  // Method to destroy socket connection after use
  static void doneHandler() {
    socket.destroy();
  }

  // Method to send record command to HyperDeck
  static void record() {
    socket.write(cHDRecord);
    // if (responseData.toString().substring(0, 3) == '500') {
    // } else {}
  }
}
