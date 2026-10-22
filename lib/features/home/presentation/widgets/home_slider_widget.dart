// lib/features/home/presentation/widgets/home_slider_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class HomeSliderWidget extends StatelessWidget {
  final List<BannerSlider> banners;

  /// kalau false -> banner tidak merespon klik (mis. guest / loggedIn)
  final bool enableTap;

  const HomeSliderWidget({
    super.key,
    required this.banners,
    this.enableTap = true,
  });

  Future<void> _openLink(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.showRaw(context,
          const SnackBar(content: Text('Tidak dapat membuka link')),
        );
      }
    }
  }

  void _onBannerTap(BuildContext context, BannerSlider banner) {
    if (!enableTap) return;
    if (banner.redirect != true) return;

    final type = banner.redirectType?.trim() ?? '';

    if (type == 'Link') {
      final link = banner.link?.trim() ?? '';
      if (link.isEmpty) {
        AppSnackbar.showRaw(context,
          const SnackBar(content: Text('Link tidak tersedia')),
        );
        return;
      }
      _openLink(context, link);
    } else if (type == 'Page') {
      final pageName = banner.pages?.trim() ?? '';
      if (pageName.isEmpty) {
        AppSnackbar.showRaw(
          context,
          const SnackBar(content: Text('Halaman tujuan tidak tersedia')),
        );
        return;
      }
      try {
        context.pushNamed(pageName);
      } catch (e) {
        // Silent fail
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

  @override
  Widget build(BuildContext context) {
    final visible = banners.where((b) => b.disabled == false).toList();
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    // Responsive height
    final double sliderHeight = isMobile
        ? 180
        : isTablet
        ? 280
        : 380;

    // Responsive viewport fraction untuk desktop/tablet
    final double viewportFraction = isDesktop
        ? 0.85 // Desktop: tampilkan sedikit banner sebelah untuk hint swipe
        : isTablet
        ? 0.92
        : 1.0; // Mobile: full width

    // Max width untuk desktop agar tidak terlalu lebar
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

    // Wrapper untuk desktop/tablet agar tidak terlalu lebar
    Widget sliderWidget = CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOutCubic,
        enlargeCenterPage: isDesktop || isTablet,
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
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              );
            } else {
              final src = img.startsWith('http') ? img : img;
              imgWidget = CachedNetworkImage(
                imageUrl: src,
                fit: BoxFit.fill,
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
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop || isTablet ? 8 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  isDesktop || isTablet ? 16 : 0,
                ),
                child: InkWell(
                  onTap: () => _onBannerTap(context, banner),
                  child: Stack(
                    children: [
                      SizedBox(width: double.infinity, child: imgWidget),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.06),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!enableTap)
                        Positioned(
                          right: isDesktop || isTablet ? 16 : 8,
                          top: isDesktop || isTablet ? 16 : 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop || isTablet ? 12 : 8,
                              vertical: isDesktop || isTablet ? 6 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Tamu',
                              style: TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: isDesktop || isTablet ? 14 : 12,
                              ),
                            ),
                          ),
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

    // Bungkus dengan container agar center dan ada max width di desktop
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
