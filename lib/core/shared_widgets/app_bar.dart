import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLeadingPressed;

  const CustomAppBar({super.key, required this.title, this.onLeadingPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteColor,
        ),
      ),
      backgroundColor: AppColors.primaryColor,
      toolbarHeight: 80,
      leading: IconButton(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        icon: const Icon(
          FontAwesomeIcons.arrowLeft,
          color: AppColors.whiteColor,
          size: 20,
        ),
        onPressed: onLeadingPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
