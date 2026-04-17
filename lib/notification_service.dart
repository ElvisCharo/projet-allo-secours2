import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('FCM background message received: ${message.messageId}');
}

class NotificationService {
  static Future<void> initFCM() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      print('FCM token: $token');
    }

    messaging.onTokenRefresh.listen((String newToken) {
      if (newToken.isNotEmpty) {
        _updateTokenToServer(newToken);
      }
    });
  }

  static Future<NotificationSettings> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission: ${settings.authorizationStatus}');
    return settings;
  }

  static Future<void> saveToken() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    await _updateTokenToServer(token);
  }

  static Future<void> _updateTokenToServer(String token) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  static Future<void> createNotificationForPatient({
    required String patientId,
    required String appointmentId,
    required String specialistId,
    required String specialistName,
    required String title,
    required String body,
    required String status,
  }) async {
    final notificationRef = FirebaseFirestore.instance
        .collection('users')
        .doc(patientId)
        .collection('notifications');

    await notificationRef.add({
      'appointmentId': appointmentId,
      'specialistId': specialistId,
      'specialistName': specialistName,
      'title': title,
      'body': body,
      'status': status,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
