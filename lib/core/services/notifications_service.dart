import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class NotificationsService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // 2. Initialize Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // 3. Listen for Foreground Messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Token Refresh Listener
    _fcm.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      _updateTokenInSupabase(newToken);
    });

    // 5. Register token if already logged in
    await registerToken();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.notification?.title}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> registerToken() async {
    final user = _supabase.auth.currentUser;
    print('Registering token for user: ${user?.id}');
    if (user == null) {
      print('No user logged in, device token will not be registered');
      return;
    }

    try {
      String? token = await _fcm.getToken();
      print('FCM Token retrieved: $token');
      if (token != null) {
        await _updateTokenInSupabase(token);
      } else {
        print('FCM Token is null');
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  Future<void> _updateTokenInSupabase(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('User logged out during token update');
      return;
    }

    try {
      print(
        'Upserting token to Supabase table: ${AppConstants.fcmTokensTable}',
      );
      final response =
          await _supabase.from(AppConstants.fcmTokensTable).upsert({
            'user_id': user.id,
            'fcm_token': token,
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'updated_at': DateTime.now().toIso8601String(),
          }).select();
      print('FCM Token registered successfully: $response');
    } catch (e) {
      print('Error registering FCM token in Supabase: $e');
    }
  }

  Future<void> deleteToken() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    String? token = await _fcm.getToken();
    if (token != null) {
      try {
        await _supabase.from(AppConstants.fcmTokensTable).delete().match({
          'user_id': user.id,
          'fcm_token': token,
        });
      } catch (e) {
        print('Error deleting FCM token: $e');
      }
    }
  }
}
