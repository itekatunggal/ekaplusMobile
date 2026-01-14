// lib/features/wishlist/presentation/widgets/wishlist_empty_state.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class WishlistEmptyState extends StatelessWidget {
  const WishlistEmptyState({super.key});

  double _scale(double width) {
    if (width >= 900) return 1.0;
    if (width >= 600) return 0.95;
    if (width >= 360) return 0.85;
    return 0.8;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = _scale(constraints.maxWidth);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),

                Icon(
                  FontAwesomeIcons.solidHeart,
                  size: 72 * scale,
                  color: const Color(0xffD43834),
                ),

                SizedBox(height: 16 * scale),

                Text(
                  'Wishlist Anda Masih Kosong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),

                SizedBox(height: 6 * scale),

                Text(
                  'Tambahkan produk favorit Anda untuk\nmengetahui produk lebih detail.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontWeight: FontWeight.w400,
                    fontSize: 13 * scale,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13 * scale),
                      backgroundColor: AppColors.secondaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Jelajahi Produk',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 14 * scale,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16 * scale),
              ],
            ),
          );
        },
      ),
    );
  }
}
