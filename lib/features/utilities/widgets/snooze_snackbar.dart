import 'package:flutter/material.dart';

/// Widget Snackbar kustom untuk fitur "Snooze" (Tunda Pengingat).
class SnoozeSnackbar {
  static void show(BuildContext context, String medicineName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengingat Ditunda',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text('Mengingatkan kembali untuk meminum $medicineName dalam 10 menit.'),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: Colors.white,
          onPressed: () {
            // Logika untuk membatalkan snooze
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Penundaan dibatalkan.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
