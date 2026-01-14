import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const String whatsappNumber = '628111115365';
  static const String adminName = 'Admin Vika';

  static Future<void> openProduct(
    BuildContext context,
    String productName,
  ) async {
    final message =
        'Halo $adminName, saya ingin menanyakan perihal produk: $productName';
    await _open(context, message);
  }

  static Future<void> openGeneral(BuildContext context) async {
    final message =
        'Halo $adminName, saya ingin bertanya mengenai produk dan layanan Ekatunggal';
    await _open(context, message);
  }

  static Future<void> _open(BuildContext context, String message) async {
    final cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^\d]'), '');
    final encodedMessage = Uri.encodeComponent(message);

    final List<String> urls = [
      'https://wa.me/$cleanNumber?text=$encodedMessage',
      'https://api.whatsapp.com/send?phone=$cleanNumber&text=$encodedMessage',
      'whatsapp://send?phone=$cleanNumber&text=$encodedMessage',
    ];

    bool opened = false;

    for (final url in urls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          opened = true;
          break;
        }
      } catch (_) {}
    }

    if (!opened && context.mounted) {
      _showNotAvailableDialog(context, cleanNumber);
    }
  }

  static void _showNotAvailableDialog(
    BuildContext context,
    String cleanNumber,
  ) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('WhatsApp Tidak Tersedia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pastikan WhatsApp sudah terinstall di perangkat Anda.'),
            const SizedBox(height: 12),
            const Text('Nomor yang akan dihubungi:'),
            const SizedBox(height: 4),
            SelectableText(
              cleanNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              final uri = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.whatsapp',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Install WhatsApp'),
          ),
        ],
      ),
    );
  }
}
