// lib/features/home/presentation/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ TAMBAHKAN
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ✅ NAVIGASI KE SEARCH PAGE
        context.pushNamed('search');
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              'Cari produk',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
