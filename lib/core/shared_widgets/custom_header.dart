import 'dart:io' as io;
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CustomHeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLeadingPressed;
  final IconData? leadingIcon;
  final bool showBackButton;

  const CustomHeaderAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.backgroundColor = AppColors.primaryColor,
    this.onBackPressed,
    this.onLeadingPressed,
    this.leadingIcon,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return Container(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, hasSubtitle ? 16 : 12),
          child: Row(
            children: [
              // Back Button or Custom Leading
              if (showBackButton)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: Icon(
                    leadingIcon ?? FontAwesomeIcons.arrowLeft,
                    color: AppColors.whiteColor,
                    size: 18,
                  ),
                  onPressed:
                      onLeadingPressed ?? onBackPressed ?? () => context.pop(),
                ),

              if (showBackButton) const SizedBox(width: 8),

              // Title & Subtitle
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: AppColors.whiteColor,
                        fontSize: isIOS ? 16 : 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w400,
                          fontSize: isIOS ? 12 : 11,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    // Lebih compact: 60px tanpa subtitle, 78px dengan subtitle
    return Size.fromHeight(hasSubtitle ? 78 : 60);
  }
}
