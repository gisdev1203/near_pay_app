import 'dart:convert';
import 'package:http/http.dart' as http;

class StripePaymentService {
  final String _apiKey;
  final String _baseUrl = 'https://api.stripe.com/v1';

  StripePaymentService(this._apiKey);

  Future<Map<String, dynamic>> createPaymentIntent(double amount, String currency) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payment_intents'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': (amount * 100).toInt().toString(), // Amount in cents
        'currency': currency,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create payment intent: ${response.statusCode}');
    }
  }

  Future<void> confirmPayment(String paymentIntentId, String paymentMethodId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payment_intents/$paymentIntentId/confirm'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'payment_method': paymentMethodId,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to confirm payment: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> retrievePaymentMethod(String paymentMethodId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/payment_methods/$paymentMethodId'),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to retrieve payment method: ${response.statusCode}');
    }
  }

  // Add more methods for handling refunds, retrieving charges, etc.
}
