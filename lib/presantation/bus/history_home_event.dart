import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/network/model/response/account_history_response_item.dart';


class HistoryHomeEvent implements Event {
  final List<AccountHistoryResponseItem> items;

  HistoryHomeEvent({required this.items});
}