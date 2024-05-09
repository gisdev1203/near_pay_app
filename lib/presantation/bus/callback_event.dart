import 'package:event_taxi/event_taxi.dart';

import 'package:near_pay_app/data/network/model/response/callback_response.dart';

class CallbackEvent implements Event {
  final CallbackResponse response;

  CallbackEvent({required this.response});
}