import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekaplus_ekatunggal/constant.dart';

/// Widget wrapper yang menangani konfirmasi keluar aplikasi
/// dengan snackbar "Klik sekali lagi untuk keluar aplikasi"
class ExitConfirmationWrapper extends StatefulWidget {
  final Widget child;
  final bool alwaysShowConfirmation;

  const ExitConfirmationWrapper({
    super.key,
    required this.child,
    this.alwaysShowConfirmation = false,
  });

  @override
  State<ExitConfirmationWrapper> createState() =>
      _ExitConfirmationWrapperState();
}

class _ExitConfirmationWrapperState extends State<ExitConfirmationWrapper> {
  DateTime? _lastBackPressTime;

  void _showExitSnackbar() {
    final bool isIOS = io.Platform.isIOS;

    AppSnackbar.showRaw(context, 
      SnackBar(
        content: Text(
          'Klik sekali lagi untuk keluar aplikasi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: isIOS ? 15 : 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color.fromARGB(190, 51, 51, 51),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      ),
    );
  }

  bool _shouldExitApp() {
    final now = DateTime.now();

    // Jika sudah pernah tekan back dalam 3 detik terakhir
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 3)) {
      return true; // Keluar aplikasi
    }

    // Set waktu back press terakhir dan tampilkan snackbar
    _lastBackPressTime = now;
    _showExitSnackbar();
    return false; // Jangan keluar dulu
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Jika alwaysShowConfirmation = true, langsung cek exit
        if (widget.alwaysShowConfirmation) {
          if (_shouldExitApp()) {
            io.exit(0);
          }
          return;
        }

        // Jika tidak, cek dulu apakah ada halaman sebelumnya
        final router = GoRouter.of(context);
        if (router.canPop()) {
          // Ada halaman sebelumnya, pop biasa
          router.pop();
        } else {
          // Tidak ada halaman sebelumnya, cek exit
          if (_shouldExitApp()) {
            io.exit(0);
          }
        }
      },
      child: widget.child,
    );
  }
}
