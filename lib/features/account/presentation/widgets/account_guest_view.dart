// lib/features/account/presentation/widgets/account_guest_view.dart
import 'dart:io' as io;
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountGuestView extends StatelessWidget {
  const AccountGuestView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final primaryYellow = AppColors.secondaryColor;

    // Breakpoints untuk responsive design
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildContent(
          context,
          primaryYellow: primaryYellow,
          isMobile: isMobile,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required Color primaryYellow,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
  }) {
    if (isMobile) {
      return _buildMobileLayout(context, primaryYellow);
    } else {
      return _buildTabletDesktopLayout(context, primaryYellow, isTablet);
    }
  }

  // Layout untuk Mobile (< 600px)
  Widget _buildMobileLayout(BuildContext context, Color primaryYellow) {
    final bool isIOS = io.Platform.isIOS;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Illustration
          _buildIllustration(primaryYellow, size: 180),

          const SizedBox(height: 24),

          // Heading
          Text(
            'Belanja Lebih Mudah',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: isIOS ? 20 : 19,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Masuk atau daftar untuk menikmati\nfitur lengkap dan penawaran eksklusif',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: isIOS ? 14 : 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B6B),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Buttons
          _buildButtons(context, primaryYellow, isFullWidth: true),
        ],
      ),
    );
  }

  // Layout untuk Tablet & Desktop (>= 600px)
  Widget _buildTabletDesktopLayout(
    BuildContext context,
    Color primaryYellow,
    bool isTablet,
  ) {
    final bool isIOS = io.Platform.isIOS;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 28 : 32),
      child: Row(
        children: [
          // Illustration
          _buildIllustration(primaryYellow, size: isTablet ? 160 : 180),

          SizedBox(width: isTablet ? 24 : 32),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heading
                Text(
                  'Belanja Lebih Mudah',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: isTablet ? (isIOS ? 22 : 21) : (isIOS ? 24 : 23),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Masuk atau daftar untuk menikmati fitur lengkap\ndan penawaran eksklusif dari Ekatunggal',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: isIOS ? 14 : 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B6B),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                _buildButtons(context, primaryYellow, isFullWidth: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(Color primaryYellow, {required double size}) {
    return Container(
      width: size,
      height: size * 0.67, // Aspect ratio 3:2
      decoration: BoxDecoration(
        color: primaryYellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/account/account.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              Icons.shopping_bag_outlined,
              size: size * 0.35,
              color: primaryYellow.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(
    BuildContext context,
    Color primaryYellow, {
    required bool isFullWidth,
  }) {
    final bool isIOS = io.Platform.isIOS;

    return Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // MASUK Button
        Flexible(
          flex: isFullWidth ? 1 : 0,
          child: SizedBox(
            width: isFullWidth ? double.infinity : 140,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.pushNamed('login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryYellow,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Masuk',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: isIOS ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // DAFTAR Button
        Flexible(
          flex: isFullWidth ? 1 : 0,
          child: SizedBox(
            width: isFullWidth ? double.infinity : 140,
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.pushNamed('register'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryYellow,
                side: BorderSide(color: primaryYellow, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Daftar',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: isIOS ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
