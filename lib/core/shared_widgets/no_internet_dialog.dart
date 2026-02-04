// lib/core/shared_widgets/no_internet_dialog.dart

import 'dart:io' as io;
import 'package:flutter/material.dart';
import '../../constant.dart';

enum NoInternetDialogVariant { offline, serverIssue }

class NoInternetDialog extends StatelessWidget {
  final NoInternetDialogVariant variant;

  const NoInternetDialog({super.key, required this.variant});

  static Future<String?> show(
    BuildContext context, {
    required NoInternetDialogVariant variant,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoInternetDialog(variant: variant),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;
    final content = _dialogContent(variant);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        color: AppColors.whiteColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(content),

            const SizedBox(height: 24),

            // Title
            Text(
              content.title,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: isIOS ? 19 : 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              content.description,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: isIOS ? 14 : 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Primary Button - Hubungkan Kembali
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop('retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Hubungkan Kembali',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: isIOS ? 15 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Secondary Button - Tutup
            TextButton(
              onPressed: () => Navigator.of(context).pop('close'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Tutup',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: isIOS ? 14 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _DialogContent _dialogContent(NoInternetDialogVariant variant) {
    switch (variant) {
      case NoInternetDialogVariant.serverIssue:
        return const _DialogContent(
          title: 'Server Sedang Bermasalah',
          description:
              'Mohon maaf, server sedang mengalami gangguan. Coba lagi dalam beberapa saat.',
          icon: Icons.cloud_off,
          accentColor: Colors.orange,
        );
      case NoInternetDialogVariant.offline:
      default:
        return const _DialogContent(
          title: 'Koneksi Internet Tidak Aktif',
          description:
              'Aktifkan Wi-Fi atau data seluler kamu agar bisa kembali melihat produk kami.',
          icon: Icons.wifi_off,
          accentColor: Colors.red,
        );
    }
  }

  Widget _buildStatusIcon(_DialogContent content) {
    final accentColor = content.accentColor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Status Icon Container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            content.icon,
            size: 40,
            color: accentColor.withOpacity(0.85),
          ),
        ),

        // Status Dot Indicator
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogContent {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const _DialogContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
