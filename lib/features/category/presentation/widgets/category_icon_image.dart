import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryIconImage extends StatelessWidget {
  const CategoryIconImage({
    super.key,
    required this.icon,
    this.size = 32,
    this.fallbackIcon = Icons.category_outlined,
    this.fallbackColor,
    this.fallbackSize,
  });

  final String? icon;
  final double size;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final double? fallbackSize;

  Widget get _fallback => Icon(
    fallbackIcon,
    color: fallbackColor,
    size: fallbackSize ?? size * .875,
  );

  @override
  Widget build(BuildContext context) {
    final iconUrl = ApiConfig.getImageUrl(
      icon,
      format: 'rs:fill:200:200/q:80/ext:webp',
    );

    if (!iconUrl.startsWith('http')) {
      return _fallback;
    }

    return CachedNetworkImage(
      imageUrl: iconUrl,
      fit: BoxFit.contain,
      width: size,
      height: size,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(width: size, height: size, color: Colors.white),
      ),
      errorWidget: (context, url, error) => _fallback,
    );
  }
}
