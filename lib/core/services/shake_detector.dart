import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Service untuk mendeteksi gerakan shake menggunakan accelerometer
/// Digunakan untuk snooze notifikasi pengingat obat
class ShakeDetector {
  // Singleton pattern
  static final ShakeDetector _instance = ShakeDetector._internal();
  factory ShakeDetector() => _instance;
  ShakeDetector._internal();

  // Configuration (sesuai SKPL S-01)
  static const double shakeThreshold = 15.0; // m/s² - threshold guncangan
  static const int shakeDurationMs = 300; // ms - durasi minimum shake
  static const int maxSnoozeCount = 3; // maksimal 3x snooze per sesi
  static const int snoozeDurationMinutes = 10; // durasi snooze: 10 menit

  // State
  StreamSubscription<AccelerometerEvent>? _subscription;
  bool _isListening = false;
  int _snoozeCount = 0;
  int? _currentScheduleId;
  DateTime? _lastShakeTime;
  Function? _onShakeCallback;

  // Getters
  bool get isListening => _isListening;
  int get snoozeCount => _snoozeCount;
  int? get currentScheduleId => _currentScheduleId;

  /// Start listening to accelerometer events
  /// 
  /// [scheduleId] - ID jadwal yang sedang aktif
  /// [onShake] - Callback yang dipanggil saat shake terdeteksi
  void startListening(int scheduleId, Function onShake) {
    print('[ShakeDetector] Starting shake detection for schedule $scheduleId');

    // Stop previous listener if exists
    if (_isListening) {
      stopListening();
    }

    // Reset state untuk schedule baru
    _currentScheduleId = scheduleId;
    _onShakeCallback = onShake;
    _snoozeCount = 0;
    _lastShakeTime = null;
    _isListening = true;

    // Subscribe to accelerometer events
    _subscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (_isShakeDetected(event)) {
          _handleShake();
        }
      },
      onError: (error) {
        print('[ShakeDetector] Error: $error');
        stopListening();
      },
      cancelOnError: false,
    );

    print('[ShakeDetector] Shake detection started (threshold: $shakeThreshold m/s²)');
  }

  /// Stop listening to accelerometer events
  void stopListening() {
    if (!_isListening) return;

    print('[ShakeDetector] Stopping shake detection for schedule $_currentScheduleId');

    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _currentScheduleId = null;
    _onShakeCallback = null;
    _lastShakeTime = null;

    print('[ShakeDetector] Shake detection stopped');
  }

  /// Reset snooze count (dipanggil saat user confirm "Sudah Minum")
  void resetSnoozeCount() {
    print('[ShakeDetector] Resetting snooze count (was: $_snoozeCount)');
    _snoozeCount = 0;
  }

  /// Check if shake is detected based on accelerometer event
  /// 
  /// Formula: magnitude = √(x² + y² + z²)
  /// Shake detected if: magnitude ≥ 15 m/s² AND duration ≥ 300ms
  bool _isShakeDetected(AccelerometerEvent event) {
    // Calculate acceleration magnitude
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;
    final double magnitude = sqrt(x * x + y * y + z * z);

    // Check threshold
    if (magnitude < shakeThreshold) {
      return false;
    }

    // Debounce: check time since last shake
    final now = DateTime.now();
    if (_lastShakeTime != null) {
      final timeSinceLastShake = now.difference(_lastShakeTime!).inMilliseconds;
      if (timeSinceLastShake < shakeDurationMs) {
        return false; // Too soon, ignore
      }
    }

    // Shake detected!
    print('[ShakeDetector] Shake detected! Magnitude: ${magnitude.toStringAsFixed(2)} m/s²');
    _lastShakeTime = now;
    return true;
  }

  /// Handle shake event
  void _handleShake() {
    if (!_isListening || _onShakeCallback == null) return;

    _snoozeCount++;
    print('[ShakeDetector] Shake #$_snoozeCount detected for schedule $_currentScheduleId');

    if (_snoozeCount < maxSnoozeCount) {
      // Trigger snooze callback
      print('[ShakeDetector] Triggering snooze (count: $_snoozeCount/$maxSnoozeCount)');
      _onShakeCallback!();
    } else {
      // Max snooze reached, mark as missed
      print('[ShakeDetector] Max snooze count reached ($_snoozeCount/$maxSnoozeCount)');
      print('[ShakeDetector] Notification will be marked as "missed"');
      
      // Stop listening (no more snooze allowed)
      stopListening();
      
      // TODO: Mark notification as "missed" in database
      // This should be handled by NotificationService
    }
  }

  /// Check if sensor is available on device
  /// 
  /// Returns true if accelerometer is available
  Future<bool> isSensorAvailable() async {
    try {
      // Try to get one event from accelerometer
      final event = await accelerometerEventStream().first.timeout(
        const Duration(seconds: 2),
      );
      return event != null;
    } catch (e) {
      print('[ShakeDetector] Sensor not available: $e');
      return false;
    }
  }

  /// Get current shake detection status as string
  String getStatus() {
    if (!_isListening) {
      return 'Inactive';
    }
    return 'Active (Schedule: $_currentScheduleId, Snooze: $_snoozeCount/$maxSnoozeCount)';
  }
}
