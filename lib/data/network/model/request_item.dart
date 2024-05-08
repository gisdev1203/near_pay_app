// ignore_for_file: constant_identifier_names

import 'dart:convert';

/// Top-level function for running in isolate via flutter compute function
String encodeRequestItem(dynamic request) {
  return json.encode(request.toJson());
}

class RequestItem<T> {
  // After this time a request will expire
  static const int EXPIRE_TIME_S = 15;

  DateTime expireDt;
  bool isProcessing;
  T request;
  bool fromTransfer;

  RequestItem(T request, {this.fromTransfer = false}) {
    expireDt = DateTime.now().add(const Duration(seconds: EXPIRE_TIME_S));
    isProcessing = false;
    request = request;
  }
}