import 'package:event_taxi/event_taxi.dart';

class ConfirmationHeightChangedEvent implements Event {
  final int confirmationHeight;

  ConfirmationHeightChangedEvent({required this.confirmationHeight});
}