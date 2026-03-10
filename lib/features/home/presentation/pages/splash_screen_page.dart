// lib/features/home/presentation/pages/splash_screen_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  static const _backgroundColor = Colors.white;
  static const _textColor = Color(0xFFBF0000);

  late AnimationController _controller;

  final String _mainText = 'EKA';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/icon_app.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                const int totalChars = 4; // E K A +

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(_mainText.length, (index) {
                      final double start = index / totalChars;
                      final double end = (index + 1) / totalChars;
                      final double opacity =
                          (_controller.value - start) / (end - start);

                      return Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Text(
                          _mainText[index],
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                      );
                    }),
                    Builder(
                      builder: (context) {
                        final int index = 3;
                        final double start = index / totalChars;
                        final double end = (index + 1) / totalChars;
                        final double opacity =
                            (_controller.value - start) / (end - start);

                        return Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: const Offset(1, -4),
                            child: const Text(
                              '+',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
