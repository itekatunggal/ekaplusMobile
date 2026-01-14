// lib/features/home/presentation/pages/splash_screen_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Tunggu 3 detik sebelum pindah ke home
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Navigate ke home page
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ETM
            Image.asset(
              'assets/images/account/logoETM.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            // const SizedBox(height: 24),
            // Loading indicator
            // const CircularProgressIndicator(
            //   valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            // ),
          ],
        ),
      ),
    );
  }
}
