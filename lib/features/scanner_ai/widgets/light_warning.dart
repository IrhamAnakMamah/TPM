import 'package:flutter/material.dart';

/// Widget peringatan cahaya untuk fitur scanner AI.
///
/// Muncul di atas tampilan kamera jika cahaya terdeteksi kurang terang.
class LightWarning extends StatelessWidget {
  final bool isVisible;

  const LightWarning({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber, width: 1.5),
        ),
        child: const Row(
          children: [
            Icon(Icons.wb_incandescent_outlined, color: Colors.amber),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cahaya kurang terang. Pindahkan ke tempat yang lebih terang untuk hasil scan yang akurat.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
