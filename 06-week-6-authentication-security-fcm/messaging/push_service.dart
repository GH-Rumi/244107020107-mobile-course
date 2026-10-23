import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;

const AndroidNotificationChannel _announcementChannel = AndroidNotificationChannel(
  'campus_announcement_channel',
  'Pengumuman Kampus',
  description: 'Notifikasi penting dari kampus',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handler background ringan
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// Meminta izin notifikasi (Android 13+ dan iOS).
Future<void> requestNotificationPermission() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final android = _local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await android?.requestNotificationsPermission();
}

// Tambahkan parameter `go` agar klik dari foreground langsung pindah halaman
Future<void> initLocalNotifications(void Function(String route) go) async {
  // Pastikan menggunakan icon bawaan flutter (jika error, ganti ke '@mipmap/ic_launcher')
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      // Jika notifikasi diklik saat aplikasi sedang aktif (foreground)
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        go(payload);
      }
    },
  );

  // Daftarkan channel agar pesan FCM background memakai channel yang sama.
  await _local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_announcementChannel);
}

void listenForeground(void Function(String route) go) {
  // Listener saat pesan masuk di foreground (Tampilkan banner manual)
  FirebaseMessaging.onMessage.listen((message) async {
    final route = message.data['route'] ?? '/';

    const androidDetails = AndroidNotificationDetails(
      'campus_announcement_channel', // id channel
      'Pengumuman Kampus', // nama channel
      channelDescription: 'Notifikasi penting dari kampus',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: route,
    );
  });

  // Listener saat pesan di-klik dari background (Banner sistem Android)
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = message.data['route'] ?? '/';
    go(route);
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    go(initial.data['route'] ?? '/');
  }
}
