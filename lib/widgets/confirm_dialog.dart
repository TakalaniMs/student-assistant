import 'package:flutter/material.dart';
import '../app_theme.dart';

class ConfirmDialog {
  // Shows a styled confirmation dialog, returns true if confirmed
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isDanger ? Icons.warning_amber_rounded : Icons.help_outline,
              color: isDanger ? AppTheme.error : AppTheme.primary,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText,
                style:
                    const TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDanger ? AppTheme.error : AppTheme.primary,
              minimumSize: const Size(100, 42),
            ),
            child: Text(confirmText,style: TextStyle(color: AppTheme.surface),),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}