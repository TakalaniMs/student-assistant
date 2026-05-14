
import 'package:flutter/material.dart';
import '../app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    IconData icon;

    // Color-code based on application status
    switch (status.toLowerCase()) {
      case 'approved':
        bg = AppTheme.success.withOpacity(0.12);
        text = AppTheme.success;
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        bg = AppTheme.error.withOpacity(0.12);
        text = AppTheme.error;
        icon = Icons.cancel_outlined;
        break;
      default: // pending
        bg = const Color(0xFFFB8C00).withOpacity(0.12);
        text = const Color(0xFFFB8C00);
        icon = Icons.hourglass_empty_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 6),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}