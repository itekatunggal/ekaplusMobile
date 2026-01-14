// lib/core/shared_widgets/no_internet_dialog.dart

import 'dart:io' as io;
import 'package:flutter/material.dart';
import '../../constant.dart';

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NoInternetDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        padding: const EdgeInsets.all(24),
        color: AppColors.whiteColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // WiFi Icon with Red Dot
            _buildWifiIcon(),

            const SizedBox(height: 24),

            // Title
            Text(
              'Koneksi Internet Terganggu',
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
              'Periksa pengaturan Wi-Fi atau data seluler kamu agar bisa kembali melihat produk kami.',
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

  Widget _buildWifiIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // WiFi Off Icon Container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.wifi_off,
            size: 40,
            color: Colors.red.shade400,
          ),
        ),

        // Red Dot Indicator
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
