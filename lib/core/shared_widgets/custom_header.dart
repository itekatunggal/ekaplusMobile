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
  final bool brandStyle;
  final String brandLabel;

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
    this.brandStyle = false,
    this.brandLabel = 'EKAPLUS',
  }) : assert(titleWidget != null || title != '');

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    if (brandStyle) {
      return _buildBrandHeader(context, isIOS: isIOS);
    }

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

  Widget _buildBrandHeader(BuildContext context, {required bool isIOS}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD52A2F), AppColors.primaryColor],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius == 20 ? 28 : bottomRadius),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            showBackButton ? 12 : 16,
            8,
            12,
            height != null && height! >= 120 ? 44 : 14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showBackButton) ...[
                _HeaderIconButton(
                  tooltip: 'Kembali',
                  onPressed:
                      onLeadingPressed ?? onBackPressed ?? () => context.pop(),
                  icon: FaIcon(
                    leadingIcon ?? FontAwesomeIcons.arrowLeft,
                    color: AppColors.whiteColor,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child:
                    titleWidget ??
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brandLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            color: Color(0xFFFECACA),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: .35,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            color: AppColors.whiteColor,
                            fontSize: isIOS ? 19 : 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.3,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              color: AppColors.whiteColor.withOpacity(.72),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: 8),
                Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    if (brandStyle) {
      return Size.fromHeight(height ?? 82);
    }

    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    return Size.fromHeight(height ?? (hasSubtitle ? 76 : 60));
  }
}

/// Reusable layout untuk halaman utama seperti Customer dan Account.
///
/// Polanya:
/// - header merah/gradient di bagian atas
/// - background halaman abu-abu langsung setelah header
/// - body overlap ke area header
/// - TIDAK membungkus seluruh body dengan card putih
///
/// Jika ingin section putih, buat Container/Card putih di dalam [body].
class CustomHeaderScaffold extends StatelessWidget {
  const CustomHeaderScaffold({
    super.key,
    required this.title,
    required this.body,
    this.titleWidget,
    this.subtitle,
    this.actions = const [],
    this.showBackButton = false,
    this.onBackPressed,
    this.onLeadingPressed,
    this.leadingIcon,
    this.backgroundColor = AppColors.background,
    this.headerHeight = 154,
    this.contentTop = 116,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.resizeToAvoidBottomInset,
  }) : assert(titleWidget != null || title != '');

  final String title;
  final Widget body;
  final Widget? titleWidget;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLeadingPressed;
  final FaIconData? leadingIcon;
  final Color backgroundColor;
  final double headerHeight;
  final double contentTop;
  final EdgeInsetsGeometry bodyPadding;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: CustomHeaderAppBar(
              title: title,
              titleWidget: titleWidget,
              subtitle: subtitle,
              actions: actions,
              showBackButton: showBackButton,
              onBackPressed: onBackPressed,
              onLeadingPressed: onLeadingPressed,
              leadingIcon: leadingIcon,
              brandStyle: true,
              height: headerHeight,
              bottomRadius: 28,
            ),
          ),

          // Body dibuat transparan terhadap Scaffold.
          // Jadi area halaman akan langsung memakai AppColors.background
          // seperti halaman Customer, bukan satu card putih besar.
          Positioned.fill(
            top: contentTop,
            child: SafeArea(
              top: false,
              child: Padding(padding: bodyPadding, child: body),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomHeaderSearchField extends StatelessWidget {
  const CustomHeaderSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.focusNode,
    this.hintText = 'Cari...',
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
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: AppFonts.primaryFont,
          color: Color(0xFF1E293B),
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 18,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF94A3B8),
                    size: 17,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
