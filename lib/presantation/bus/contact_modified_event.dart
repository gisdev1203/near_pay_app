import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/core/models/db/contact.dart';


class ContactModifiedEvent implements Event {
  final Contact contact;

  ContactModifiedEvent({required this.contact});
}