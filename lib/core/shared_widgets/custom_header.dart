import 'dart:io' as io;
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CustomHeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final Color backgroundColor;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLeadingPressed;
  final FaIconData? leadingIcon;
  final bool showBackButton;
  final List<Widget> actions;
  final bool centerTitle;
  final double bottomRadius;
  final double? height;

  const CustomHeaderAppBar({
    super.key,
    this.title = '',
    this.titleWidget,
    this.subtitle,
    this.backgroundColor = AppColors.primaryColor,
    this.onBackPressed,
    this.onLeadingPressed,
    this.leadingIcon,
    this.showBackButton = true,
    this.actions = const [],
    this.centerTitle = true,
    this.bottomRadius = 20,
    this.height,
  }) : assert(titleWidget != null || title != '');

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 10, 12, hasSubtitle ? 14 : 10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: showBackButton
                    ? _HeaderIconButton(
                        tooltip: 'Kembali',
                        onPressed:
                            onLeadingPressed ??
                            onBackPressed ??
                            () => context.pop(),
                        icon: FaIcon(
                          leadingIcon ?? FontAwesomeIcons.arrowLeft,
                          color: AppColors.whiteColor,
                          size: 17,
                        ),
                      )
                    : const SizedBox(width: 40, height: 40),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 52),
                child:
                    titleWidget ??
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: centerTitle
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            title,
                            textAlign: centerTitle
                                ? TextAlign.center
                                : TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              color: AppColors.whiteColor,
                              fontSize: isIOS ? 16 : 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (hasSubtitle) ...[
                          const SizedBox(height: 3),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              subtitle!,
                              textAlign: centerTitle
                                  ? TextAlign.center
                                  : TextAlign.start,
                              style: TextStyle(
                                fontFamily: AppFonts.primaryFont,
                                color: AppColors.whiteColor.withOpacity(0.75),
                                fontWeight: FontWeight.w400,
                                fontSize: isIOS ? 12 : 11,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: actions.isEmpty
                    ? const SizedBox(width: 40, height: 40)
                    : Row(mainAxisSize: MainAxisSize.min, children: actions),
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
    return Size.fromHeight(height ?? (hasSubtitle ? 76 : 60));
  }
}

class CustomHeaderSearchField extends StatelessWidget {
  const CustomHeaderSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.focusNode,
    this.hintText = 'Cari produk...',
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlignVertical: TextAlignVertical.center,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIconConstraints: const BoxConstraints.tightFor(
            width: 44,
            height: 42,
          ),
          prefixIcon: const Center(
            child: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              color: Color(0xFF4B5563),
              size: 16,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: Color(0xFF4B5563),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

class CustomHeaderActionButton extends StatelessWidget {
  const CustomHeaderActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return _HeaderIconButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.whiteColor.withOpacity(0.16),
        foregroundColor: AppColors.whiteColor,
        shape: const CircleBorder(),
      ),
      icon: icon,
    );
  }
}
