import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/core/models/db/account.dart';



class AccountChangedEvent implements Event {
  final Account account;
  final bool delayPop;
  final bool noPop;

  AccountChangedEvent({required this.account, this.delayPop = false, this.noPop = false});
}