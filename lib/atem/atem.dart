/// ATEM SDK for Dart.
///
/// This package provides a complete implementation of the Blackmagic Design ATEM
/// protocol for controlling ATEM switchers over UDP.
library atem;

export 'src/connection/atem_connection.dart';
export 'src/state/atem_state.dart';
export 'src/field/atem_fields.dart' hide StreamingState;
export 'src/command/atem_commands.dart';
export 'src/transport/atem_packet.dart';
export 'src/transport/atem_udp_transport.dart';
