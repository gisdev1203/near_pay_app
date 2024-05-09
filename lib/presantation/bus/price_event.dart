import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/data/network/model/response/price_response.dart';



class PriceEvent implements Event {
  final PriceResponse response;

  PriceEvent({required this.response});
}