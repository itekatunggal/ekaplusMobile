// lib/features/home/presentation/widgets/home_slider_widget.dart

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/config/feature_flags.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class HomeSliderWidget extends StatelessWidget {
  final List<BannerSlider> banners;

  /// Tinggi area banner yang tertutup widget lain (mis. kartu perusahaan
  /// yang overlap di bagian bawah). Dipakai supaya tombol CTA tetap
  /// berada di area banner yang terlihat.
  final double bottomOverlap;

  const HomeSliderWidget({
    super.key,
    required this.banners,
    this.bottomOverlap = 0,
  });

  Future<void> _openLink(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        throw const FormatException('Skema URL tidak didukung');
      }
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        throw StateError('URL tidak dapat dibuka');
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.showRaw(
          context,
          const SnackBar(content: Text('Tidak dapat membuka link')),
        );
      }
    }
  }

  void _onBannerTap(BuildContext context, BannerSlider banner) {
    if (!banner.hasAction) return;

    if (banner.type == 'url') {
      if (FeatureFlags.isHiddenProductPath(banner.typeValue)) {
        AppSnackbar.showRaw(
          context,
          const SnackBar(content: Text('Katalog produk belum tersedia')),
        );
        return;
      }
      _openLink(context, banner.typeValue);
    } else if (banner.type == 'internal_route') {
      final destination = banner.typeValue;
      if (FeatureFlags.isHiddenProductRouteName(destination) ||
          FeatureFlags.isHiddenProductPath(destination)) {
        AppSnackbar.showRaw(
          context,
          const SnackBar(content: Text('Katalog produk belum tersedia')),
        );
        return;
      }
      try {
        if (destination.startsWith('/')) {
          context.push(destination);
        } else {
          context.pushNamed(destination);
        }
      } catch (_) {
        AppSnackbar.showRaw(
          context,
          const SnackBar(content: Text('Halaman tujuan tidak tersedia')),
        );
      }
    }
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1200),
      direction: ShimmerDirection.ltr,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }

  /// CTA gaya "glass": semi-transparan + blur + border putih tipis,
  /// sehingga warnanya mengikuti gambar banner di belakangnya.
  Widget _buildCta({
    required BuildContext context,
    required BannerSlider banner,
    required bool isWide,
  }) {
    final radius = BorderRadius.circular(20);
    return Positioned(
      left: isWide ? 24 : 14,
      bottom: bottomOverlap + (isWide ? 16 : 8),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: Colors.white.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: radius,
              onTap: () => _onBannerTap(context, banner),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 18 : 12,
                  vertical: isWide ? 9 : 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selengkapnya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWide ? 13 : 10.5,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(color: Color(0x66000000), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: isWide ? 16 : 13,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = banners.where((b) => b.disabled == false).toList();
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    final bool isWide = isDesktop || isTablet;

    // Dipakai hanya untuk state kosong; carousel mengikuti tinggi parent
    final double sliderHeight = isMobile
        ? 180
        : isTablet
        ? 280
        : 380;

    final double viewportFraction = isDesktop
        ? 0.85
        : isTablet
        ? 0.92
        : 1.0;

    final double maxWidth = isDesktop ? 1400 : double.infinity;

    if (visible.isEmpty) {
      return Container(
        height: sliderHeight,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: const Center(
          child: Icon(Icons.image, size: 60, color: Colors.grey),
        ),
      );
    }

    final Widget sliderWidget = CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
        autoPlay: visible.length > 1,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOutCubic,
        enlargeCenterPage: isWide,
        enlargeFactor: 0.15,
        viewportFraction: viewportFraction,
        padEnds: true,
      ),
      items: visible.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            final img = ApiConfig.getImageUrl(
              banner.img,
              format:
                  'rs:fit:${isMobile
                      ? 600
                      : isTablet
                      ? 1200
                      : 1600}:400/q:80/ext:webp',
            );

            Widget imgWidget;
            if (img.startsWith('assets/')) {
              imgWidget = Image.asset(
                img,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              );
            } else {
              imgWidget = CachedNetworkImage(
                imageUrl: img,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => _buildShimmerPlaceholder(),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 200),
              );
            }

            return Container(
              margin: EdgeInsets.symmetric(horizontal: isWide ? 8 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isWide ? 16 : 0),
                child: InkWell(
                  onTap: banner.hasAction
                      ? () => _onBannerTap(context, banner)
                      : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imgWidget,
                      // Gradient bawah tipis supaya CTA tetap terbaca
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.22),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.6, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (banner.hasAction)
                        _buildCta(
                          context: context,
                          banner: banner,
                          isWide: isWide,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );

    if (isDesktop) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: sliderWidget,
        ),
      );
    }

    return sliderWidget;
  }
}
