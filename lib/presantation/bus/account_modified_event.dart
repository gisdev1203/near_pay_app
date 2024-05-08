import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/models/db/account.dart';


class AccountModifiedEvent implements Event {
  final Account account;
  final bool deleted;

  AccountModifiedEvent({required this.account, this.deleted = false});
}