// ignore_for_file: constant_identifier_names

import 'package:event_taxi/event_taxi.dart';

// Bus event for connection status changing
enum ConnectionStatus { CONNECTED, DISCONNECTED }

class ConnStatusEvent implements Event {
  final ConnectionStatus status;

  ConnStatusEvent({required this.status});
}