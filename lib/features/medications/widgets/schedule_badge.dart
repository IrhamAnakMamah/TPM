import 'package:flutter/material.dart';

class ScheduleBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const ScheduleBadge({
    super.key,
    required this.icon,
    required this.label,
    this.color = const Color(0xFF0D9488),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}