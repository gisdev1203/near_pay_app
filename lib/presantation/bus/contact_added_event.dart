import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/models/db/contact.dart';


class ContactAddedEvent implements Event {
  final Contact contact;

  ContactAddedEvent({required this.contact});
}