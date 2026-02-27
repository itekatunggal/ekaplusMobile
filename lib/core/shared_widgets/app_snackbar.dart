import 'package:flutter/material.dart';

enum AppSnackbarType { success, error, info, warning }

class AppSnackbar {
  static Color _bg(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return const Color(0xFF065F46);
      case AppSnackbarType.error:
        return const Color(0xFF7F1D1D);
      case AppSnackbarType.warning:
        return const Color(0xFF78350F);
      case AppSnackbarType.info:
        return const Color(0xFF111827);
    }
  }

  static IconData _icon(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return Icons.check_circle_rounded;
      case AppSnackbarType.error:
        return Icons.error_rounded;
      case AppSnackbarType.warning:
        return Icons.warning_amber_rounded;
      case AppSnackbarType.info:
        return Icons.info_rounded;
    }
  }

  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    showRaw(
      context,
      SnackBar(
        content: Row(
          children: [
            Icon(_icon(type), color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: _bg(type),
      ),
      type: type,
    );
  }

  static void showRaw(
    BuildContext context,
    SnackBar snackBar, {
    AppSnackbarType type = AppSnackbarType.info,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: snackBar.content,
        action: snackBar.action,
        duration: snackBar.duration,
        behavior: SnackBarBehavior.floating,
        dismissDirection: snackBar.dismissDirection,
        padding:
            snackBar.padding ??
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: snackBar.margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 30),
        shape:
            snackBar.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: snackBar.elevation ?? 0,
        clipBehavior: snackBar.clipBehavior,
        showCloseIcon: snackBar.showCloseIcon,
        closeIconColor: snackBar.closeIconColor,
        backgroundColor: snackBar.backgroundColor ?? _bg(type),
      ),
    );
  }
}
