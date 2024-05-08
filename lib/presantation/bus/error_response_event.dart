import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/network/model/response/error_response.dart';


class ErrorEvent implements Event {
  final ErrorResponse response;

  ErrorEvent({required this.response});
}