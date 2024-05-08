import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission for receiving push notifications
    await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
    );

    // Configure Firebase Cloud Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming messages when the app is in the foreground
      if (kDebugMode) {
        print('Received message in foreground: ${message.notification?.title}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notifications when the app is opened from a terminated state
      if (kDebugMode) {
        print('Received message in background: ${message.notification?.title}');
      }
    });
  }

  Future<String?> getToken() async {
    // Retrieve the FCM token for this device
    String? token = await _firebaseMessaging.getToken();
    return token;
  }

  Future<void> subscribeToTopic(String topic) async {
    // Subscribe the device to a specific topic to receive topic-based notifications
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    // Unsubscribe the device from a specific topic
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> sendNotificationToUser(String userToken, String title, String body) async {
    // Send a notification to a specific user identified by their FCM token
    // ignore: deprecated_member_use
    await _firebaseMessaging.sendMessage(
      to: userToken,
      data: {
        'title': title,
        'body': body,
      },
    );
  }
}
