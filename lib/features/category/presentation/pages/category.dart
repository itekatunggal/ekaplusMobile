// lib/features/category/presentation/pages/category_page.dart
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';

import 'package:ekaplus_ekatunggal/features/category/domain/entities/category_group.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with TickerProviderStateMixin {
  String? _expandedType;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(CategoryEventGetByType());
  }

  void _toggleExpand(String typeName) {
    setState(() {
      _expandedType = _expandedType == typeName ? null : typeName;
    });
  }

  void _openProductPage(category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPage(),
        settings: RouteSettings(arguments: category),
      ),
    );
  }

  // Fungsi untuk mendapatkan jumlah kolom berdasarkan lebar layar
  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    return 3;
  }

  // Fungsi untuk mendapatkan lebar tile berdasarkan lebar layar
  double _getTileWidth(double width) {
    if (width >= 900) return 130;
    if (width >= 600) return 120;
    return 105; // Lebih kecil untuk mobile
  }

  // Fungsi untuk mendapatkan padding berdasarkan lebar layar
  double _getHorizontalPadding(double width) {
    if (width >= 1200) return 40;
    if (width >= 900) return 24;
    if (width >= 600) return 16;
    return 12;
  }

  // Fungsi untuk mendapatkan spacing berdasarkan lebar layar
  double _getSpacing(double width) {
    if (width >= 900) return 14;
    if (width >= 600) return 12;
    return 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomHeaderAppBar(
        title: 'Kategori',
        showBackButton: false,
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryStateLoading) {
            return _buildShimmerLoading();
          }

          if (state is CategoryStateError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CategoryStateLoadedCategoryByType) {
            final allCategories = state.allCategory;

            if (allCategories.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada kategori',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final horizontalPadding = _getHorizontalPadding(screenWidth);
                final spacing = _getSpacing(screenWidth);
                final crossAxisCount = _getCrossAxisCount(screenWidth);
                final tileWidth = _getTileWidth(screenWidth);

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12,
                  ),
                  child: Column(
                    children: allCategories.map((typeGroup) {
                      final categories = typeGroup.categories;
                      final typeName = typeGroup.typeName;
                      final isExpanded = _expandedType == typeName;

                      final content = isExpanded
                          ? GridView.builder(
                              key: ValueKey('expanded-$typeName'),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: categories.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: spacing,
                                    crossAxisSpacing: spacing,
                                    childAspectRatio: 0.68,
                                  ),
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                return _CategoryTile(
                                  category: cat,
                                  onTap: () => _openProductPage(cat),
                                );
                              },
                            )
                          : SizedBox(
                              key: ValueKey('collapsed-$typeName'),
                              height: tileWidth / 0.68,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: categories.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: spacing),
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  return _CategoryTile(
                                    category: cat,
                                    width: tileWidth,
                                    onTap: () => _openProductPage(cat),
                                  );
                                },
                              ),
                            );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    typeName,
                                    style: TextStyle(
                                      fontFamily: AppFonts.primaryFont,
                                      fontSize: screenWidth >= 600 ? 14 : 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.blackColor,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _toggleExpand(typeName),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    isExpanded ? 'Sembunyikan' : 'Lihat Semua',
                                    style: TextStyle(
                                      fontFamily: AppFonts.primaryFont,
                                      color: AppColors.primaryColor,
                                      fontSize: screenWidth >= 600 ? 12 : 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ClipRect(
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: content,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final horizontalPadding = _getHorizontalPadding(screenWidth);
        final spacing = _getSpacing(screenWidth);
        final tileWidth = _getTileWidth(screenWidth);
        final tileHeight = tileWidth / 0.68;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 12,
          ),
          child: Column(
            children: List.generate(3, (sectionIndex) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer untuk header section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 70,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Shimmer untuk list horizontal
                  SizedBox(
                    height: tileHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      separatorBuilder: (_, __) => SizedBox(width: spacing),
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: tileWidth,
                            height: tileHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategorySimpleEntity category;
  final double? width;
  final VoidCallback? onTap;

  const _CategoryTile({required this.category, this.width, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = width ?? constraints.maxWidth;
        final tileHeight = width != null ? (width! / 0.68) : 160.0;

        // Responsive font size
        final screenWidth = MediaQuery.of(context).size.width;
        final fontSize = screenWidth >= 600 ? 12.0 : 11.0;

        final card = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: tileWidth,
            height: tileHeight,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  bottom: 42,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl:
                          "${ApiConfig.baseImageUrl}/${category.icon}?format=rs:fill:250:250/q:80/ext:webp",
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 42,
                    color: AppColors.primaryColor,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return SizedBox(
          width: width,
          child: GestureDetector(onTap: onTap, child: card),
        );
      },
    );
  }
}
