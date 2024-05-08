import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/network/model/response/subscribe_response.dart';


class SubscribeEvent implements Event {
  final SubscribeResponse response;

  SubscribeEvent({required this.response});
}