// lib/features/product/presentation/widgets/product_card.dart
// ignore_for_file: deprecated_member_use

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final double width;
  final bool showWishlistButton;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width = 176,
    this.showWishlistButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = product.variants.isNotEmpty
        ? "${ApiConfig.baseImageUrl}/${product.variants[0].image}"
        : "";

    final media = MediaQuery.of(context);
    final scale = media.textScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.0,
    );

    return MediaQuery(
      data: media.copyWith(textScaler: scale),
      child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, authState) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section - Clean
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey.shade50,
                        child: imagePath.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imagePath,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: Colors.grey[200]!,
                                  highlightColor: Colors.grey[50]!,
                                  child: Container(color: Colors.grey.shade100),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey.shade50,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 36,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade50,
                                child: Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 36,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Content Section - Minimal & Clean
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Product Name
                          SizedBox(
                            height: 33,
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppFonts.primaryFont,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                                color: Colors.black87,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),

                          // See More - Minimal Text Link
                          const Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
