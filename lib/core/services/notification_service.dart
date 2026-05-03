import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

/// Service untuk mengelola notifikasi lokal
/// Menggunakan flutter_local_notifications untuk reminder minum obat
class NotificationService {
  // Singleton pattern
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // ══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ══════════════════════════════════════════════════════════════

  /// Initialize notification service
  /// Harus dipanggil di main() sebelum runApp()
  Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ NotificationService already initialized');
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      print('✅ Timezone initialized: Asia/Jakarta');

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
      print('✅ NotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
    }
  }

  /// Request notification permissions (Android 13+)
  Future<void> _requestPermissions() async {
    try {
      // Request notification permission
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        print('✅ Notification permission granted');
      } else if (status.isDenied) {
        print('⚠️ Notification permission denied');
      } else if (status.isPermanentlyDenied) {
        print('❌ Notification permission permanently denied');
        // User needs to enable from settings
        await openAppSettings();
      }

      // Request exact alarm permission (Android 12+)
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    
    // TODO: Navigate to medication detail screen
    // Parse payload to get schedule_id
    // Navigator.push to MedicationDetailScreen
  }

  // ══════════════════════════════════════════════════════════════
  // SCHEDULE MEDICATION REMINDER
  // ══════════════════════════════════════════════════════════════

  /// Schedule medication reminder notification
  /// 
  /// Parameters:
  /// - scheduleId: ID dari schedule di database
  /// - medicationName: Nama obat
  /// - timeIntake: Waktu minum (format HH:mm)
  /// - dosage: Jumlah dosis
  /// - dosageUnit: Satuan dosis (tablet/mg/ml)
  Future<void> scheduleMedicationReminder({
    required int scheduleId,
    required String medicationName,
    required String timeIntake, // Format: "08:00"
    required double dosage,
    required String dosageUnit,
  }) async {
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized');
      return;
    }

    try {
      // Parse time (HH:mm)
      final timeParts = timeIntake.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Get current time
      final now = tz.TZDateTime.now(tz.local);
      
      // Schedule for today if time hasn't passed, otherwise tomorrow
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Notification details
      const androidDetails = AndroidNotificationDetails(
        'medication_reminder', // channel id
        'Pengingat Minum Obat', // channel name
        channelDescription: 'Notifikasi untuk mengingatkan waktu minum obat',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification
      await _notifications.zonedSchedule(
        scheduleId, // notification id (unique per schedule)
        '⏰ Waktunya Minum Obat!',
        '$medicationName - ${dosage.toInt()} $dosageUnit',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at same time
        payload: scheduleId.toString(), // Pass schedule_id for navigation
      );

      print('✅ Notification scheduled for $medicationName at $timeIntake (ID: $scheduleId)');
      print('   Next notification: $scheduledDate');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // CANCEL NOTIFICATION
  // ══════════════════════════════════════════════════════════════

  /// Cancel notification by schedule ID
  Future<void> cancelNotification(int scheduleId) async {
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized');
      return;
    }

    try {
      await _notifications.cancel(scheduleId);
      print('✅ Notification cancelled (ID: $scheduleId)');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized');
      return;
    }

    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // LOW STOCK NOTIFICATION
  // ══════════════════════════════════════════════════════════════

  /// Show low stock notification (immediate)
  Future<void> showLowStockNotification({
    required String medicationName,
    required double remainingStock,
    required String dosageUnit,
  }) async {
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'low_stock_alert', // channel id
        'Peringatan Stok Obat', // channel name
        channelDescription: 'Notifikasi saat stok obat hampir habis',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use negative ID to avoid conflict with schedule IDs
      final notificationId = -DateTime.now().millisecondsSinceEpoch;

      await _notifications.show(
        notificationId,
        '⚠️ Stok Obat Hampir Habis!',
        '$medicationName - Sisa ${remainingStock.toInt()} $dosageUnit. Segera beli obat baru.',
        notificationDetails,
      );

      print('✅ Low stock notification shown for $medicationName');
    } catch (e) {
      print('❌ Error showing low stock notification: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // UTILITY
  // ══════════════════════════════════════════════════════════════

  /// Get list of pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized');
      return [];
    }

    try {
      final pending = await _notifications.pendingNotificationRequests();
      print('📋 Pending notifications: ${pending.length}');
      return pending;
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if notification permission is granted
  Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}
