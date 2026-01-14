// lib/features/wishlist/presentation/widgets/wishlist_locked_state.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WishlistLockedState extends StatelessWidget {
  const WishlistLockedState({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const Spacer(),

            // Heart icon
            SizedBox(
              width: 140,
              height: 140,
              child: Center(
                child: Image.asset(
                  'assets/images/wishlistIcon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.favorite_border,
                    size: 120,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Text description
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Wishlist hanya bisa diakses oleh\npengguna yang sudah masuk.\nSilahkan ',
                  ),
                  TextSpan(
                    text: 'masuk atau daftar',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const TextSpan(
                    text: ' untuk\nmenyimpan produk favorit Anda.',
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Action buttons
            Row(
              children: [
                // Button DAFTAR
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/register'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: AppColors.secondaryColor,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'DAFTAR',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.blackColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Button MASUK
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.secondaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'MASUK',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.blackColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
