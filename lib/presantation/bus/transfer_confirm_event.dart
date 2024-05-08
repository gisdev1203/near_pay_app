import 'package:event_taxi/event_taxi.dart';

import 'package:near_pay_app/network/model/response/account_balance_item.dart';

class TransferConfirmEvent implements Event {
  final Map<String, AccountBalanceItem> balMap;

  TransferConfirmEvent({required this.balMap});
}