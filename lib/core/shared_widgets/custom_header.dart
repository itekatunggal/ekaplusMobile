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

    return _HeaderBackground(
      backgroundColor: backgroundColor,
      bottomRadius: bottomRadius,
      shadow: const BoxShadow(
        color: Color(0x24000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
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
    final resolvedBottomRadius = bottomRadius == 20 ? 28.0 : bottomRadius;

    return _HeaderBackground(
      height: height,
      backgroundColor: backgroundColor,
      bottomRadius: resolvedBottomRadius,
      shadow: const BoxShadow(
        color: Color(0x1F0F172A),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
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

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({
    required this.child,
    required this.backgroundColor,
    required this.bottomRadius,
    required this.shadow,
    this.height,
  });

  final Widget child;
  final Color backgroundColor;
  final double bottomRadius;
  final BoxShadow shadow;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
        boxShadow: [shadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _HeaderBackgroundPainter(baseColor: backgroundColor),
          ),
          child,
        ],
      ),
    );
  }
}

class _HeaderBackgroundPainter extends CustomPainter {
  const _HeaderBackgroundPainter({required this.baseColor});

  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final w = size.width;
    final h = size.height;
    final bounds = Offset.zero & size;

    canvas.save();
    canvas.clipRect(bounds);

    // WARNA ASLI _EkaHeaderPainter: #850532 -> #990033 -> #690322.
    // Palet tetap, sesuai desain hasil generate awal.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF850532), Color(0xFF990033), Color(0xFF690322)],
          stops: [0, 0.52, 1],
        ).createShader(bounds),
    );

    // Cahaya dasar asli: merah maroon lembut, bukan warna baru.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.12, 0.05),
          radius: 0.9,
          colors: [Color(0x70D80042), Color(0x00D80042)],
          stops: [0, 1],
        ).createShader(bounds),
    );

    // Bayangan bawah asli.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00600024), Color(0x38600024)],
        ).createShader(bounds),
    );

    // 2. WATERFALL RIBBON: geometri dan ukuran SAMA seperti versi sebelumnya.
    const ribbonScale = 0.70;
    canvas.save();
    canvas.translate(w * 0.35, h * 0.23);
    canvas.scale(ribbonScale);

    final p0 = Offset(w * 1.08, h * .18);
    final p1 = Offset(w * .93, h * .15);
    final p2 = Offset(w * .70, h * .28);
    final p3 = Offset(w * .28, h * 1.08);

    const segments = 64;
    final upperPoints = <Offset>[];
    final lowerPoints = <Offset>[];

    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final u = 1.0 - t;

      final center =
          p0 * (u * u * u) +
          p1 * (3 * u * u * t) +
          p2 * (3 * u * t * t) +
          p3 * (t * t * t);

      final tangent =
          (p1 - p0) * (3 * u * u) +
          (p2 - p1) * (6 * u * t) +
          (p3 - p2) * (3 * t * t);

      final length = tangent.distance;
      final normal = length > 0.0001
          ? Offset(-tangent.dy / length, tangent.dx / length)
          : const Offset(0, -1);

      final thickness = h * (.065 + .70 * t * t);
      final half = thickness / 2;

      upperPoints.add(center + normal * half);
      lowerPoints.add(center - normal * half);
    }

    final upper = Path()..moveTo(upperPoints.first.dx, upperPoints.first.dy);
    for (var i = 1; i < upperPoints.length; i++) {
      upper.lineTo(upperPoints[i].dx, upperPoints[i].dy);
    }

    final band = Path()..moveTo(upperPoints.first.dx, upperPoints.first.dy);
    for (var i = 1; i < upperPoints.length; i++) {
      band.lineTo(upperPoints[i].dx, upperPoints[i].dy);
    }
    for (var i = lowerPoints.length - 1; i >= 0; i--) {
      band.lineTo(lowerPoints[i].dx, lowerPoints[i].dy);
    }
    band.close();

    // 3. Area sedikit lebih gelap di bawah pita, mengikuti sisi bawah.
    final below = Path()..moveTo(lowerPoints.first.dx, lowerPoints.first.dy);
    for (var i = 1; i < lowerPoints.length; i++) {
      below.lineTo(lowerPoints[i].dx, lowerPoints[i].dy);
    }
    below
      ..lineTo(-w * .10, h * 1.20)
      ..lineTo(w * 1.12, h * 1.20)
      ..close();
    canvas.drawPath(below, Paint()..color = const Color(0x28200008));

    final curveBounds = Rect.fromLTRB(w * .16, h * .08, w * 1.09, h * 1.16);

    // Aura halus mengikuti tepi atas; warna turunan dari palet awal.
    canvas.drawPath(
      upper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = h * .11
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0x00D80042), Color(0x20DA0043), Color(0x50FF0050)],
          stops: [0, .55, 1],
        ).createShader(curveBounds)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * .065),
    );

    // PITA: keempat warna dan stops diambil PERSIS dari _EkaHeaderPainter.
    // Hanya bentuk/posisi pita yang tetap berasal dari painter Ekaplus sekarang.
    canvas.drawPath(
      band,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0x00D60040),
            Color(0xFFDA0043),
            Color(0xFFFF0050),
            Color(0xFFE00043),
          ],
          stops: [0, 0.38, 0.75, 1],
        ).createShader(curveBounds),
    );

    // Pantulan di badan pita: DIGAMBAR SETELAH badan pita, agar terlihat.
    // Titik mengikuti dua tepi pita, bukan koordinat statis layar.
    final glowCenter = Offset.lerp(upperPoints[35], lowerPoints[35], .35)!;
    final sunGlowRect = Rect.fromCenter(
      center: glowCenter,
      width: w * .42,
      height: h * .22,
    );

    canvas.save();
    canvas.clipPath(band);
    canvas.drawOval(
      sunGlowRect,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x45FF7A8F), Color(0x25FF0050), Color(0x00D80042)],
          stops: [0.0, 0.45, 1.0],
        ).createShader(sunGlowRect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * .045),
    );
    canvas.restore();

    // Pantulan lembut di tepi atas, dengan spektrum asli merah-pink.
    canvas.drawPath(
      upper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = h * .065
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0x00D80042), Color(0x30DA0043), Color(0x75FF0050)],
          stops: [0, .62, 1],
        ).createShader(curveBounds)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * .035),
    );

    // Garis cahaya tipis (tetap mengikuti geometri kurva yang sama).
    canvas.drawPath(
      upper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = h * .006
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0x00FF0050), Color(0x28FF0050), Color(0x88FF7A8F)],
          stops: [0, .68, 1],
        ).createShader(curveBounds)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * .008),
    );

    // Kembalikan transformasi pita ke koordinat header.
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeaderBackgroundPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor;
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
