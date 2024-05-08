import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, dynamic error) {
    String errorMessage = _getErrorMessage(error);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Error) {
      return error.toString();
    } else if (error is Exception) {
      return error.toString();
    } else {
      return 'An unknown error occurred.';
    }
  }
}
