// ignore_for_file: file_names

import 'dart:io' as io;
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/widgets/category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';

class TypeCategoryList extends StatelessWidget {
  const TypeCategoryList({super.key});

  double _itemWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width - 40) / 5.5;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TypeBloc, TypeState>(
      builder: (context, state) {
        if (state is TypeStateLoading || state is TypeStateError) {
          // Show shimmer for loading and error states
          // Dialog will handle connectivity notification
          return _buildLoadingShimmer(context);
        }

        if (state is TypeStateLoadedAllType) {
          final types = state.allType;
          final visible = types.length > 5 ? types.sublist(0, 5) : types;
          return _buildContainer(context, visible);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final itemWidth = _itemWidth(context);

    return Container(
      // margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.03),
        //     blurRadius: 10,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: itemWidth + 45,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => _buildShimmerItem(itemWidth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem(double itemWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          children: [
            Container(
              width: itemWidth * 0.85,
              height: itemWidth * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: itemWidth * 0.7,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(BuildContext context, List<Type> visible) {
    final bool isIOS = io.Platform.isIOS;

    return Container(
      // margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        // borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.03),
        //     blurRadius: 10,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
        image: const DecorationImage(
          image: AssetImage('assets/images/kategoribg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Text(
            "Temukan Produk Yang Anda Cari",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontWeight: FontWeight.w700,
              fontSize: isIOS ? 15 : 14,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: _itemWidth(context) + 45,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: visible.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _buildTypeItem(context, visible[index]);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildLihatSemuaButton(context),
        ],
      ),
    );
  }

  Widget _buildTypeItem(BuildContext context, Type item) {
    final itemWidth = _itemWidth(context);
    final imageSize = itemWidth * 0.85;
    final bool isIOS = io.Platform.isIOS;

    return GestureDetector(
      onTap: () {
        showCategoryModal(context);
      },
      child: SizedBox(
        width: itemWidth,
        child: Column(
          children: [
            Container(
              width: imageSize,
              height: imageSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildTypeImage(item, imageSize),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: isIOS ? 12 : 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeImage(Type item, double size) {
    final imgPath = item.image;

    if (imgPath == null || imgPath.isEmpty) {
      return Icon(Icons.category, size: size * 0.5, color: Colors.grey[400]);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: "${ApiConfig.baseUrl}/files/$imgPath",
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (_, __) => _buildImageShimmer(size),
        errorWidget: (_, __, ___) =>
            Icon(Icons.broken_image, size: size * 0.5, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildImageShimmer(double size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(width: size, height: size, color: Colors.white),
    );
  }

  Widget _buildLihatSemuaButton(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;

    return InkWell(
      onTap: () {
        showCategoryModal(context);
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lihat Semua',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: isIOS ? 12 : 11,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primaryColor,
              size: isIOS ? 12 : 11,
            ),
          ],
        ),
      ),
    );
  }
}
