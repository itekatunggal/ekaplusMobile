// lib/features/product/presentation/widgets/products_section.dart
import 'dart:io' show Platform;
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

final GetIt myinjection = GetIt.instance;

class ProductsSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int showCount;
  final bool hotDealsOnly;
  final bool isLoggedIn;

  const ProductsSection({
    super.key,
    this.title = 'Yang Baru Dari Kami',
    this.subtitle,
    this.showCount = 6,
    this.hotDealsOnly = false,
    this.isLoggedIn = false,
  });

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  List<_CategoryItem> _categories = [];
  int? _selectedCategoryId;

  late ProductBloc pBloc;

  @override
  void initState() {
    super.initState();

    pBloc = ProductBloc(
      getAllProduct: myinjection(),
      getProduct: myinjection(),
      getHotDeals: myinjection(),
    );

    pBloc.add(
      ProductEventLoadFirstPage(
        limit: widget.showCount,
        filters: widget.hotDealsOnly
            ? [
                ['hot_deals', '=', '1'],
              ]
            : null,
        orderBy: widget.hotDealsOnly
            ? null
            : [
                ['created_at', 'desc'],
              ],
      ),
    );
  }

  @override
  void dispose() {
    pBloc.close();
    super.dispose();
  }

  void _buildCategoryList(List products) {
    if (_categories.isNotEmpty) return;

    final Map<int, String> map = {};
    for (var p in products) {
      final cat = p.itemCategory;
      if (cat != null) {
        map.putIfAbsent(cat.id, () => cat.name);
      }
    }

    _categories = map.entries
        .map((e) => _CategoryItem(id: e.key, name: e.value))
        .toList();
  }

  void _onCategoryTap(int categoryId) {
    setState(() {
      _selectedCategoryId = _selectedCategoryId == categoryId
          ? null
          : categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, authState) {
        final isLoggedIn = authState is AuthSessionAuthenticated;

        return BlocProvider<ProductBloc>.value(
          value: pBloc,
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, productState) {
              if (productState is ProductListLoading ||
                  productState is ProductInitial ||
                  productState is ProductError) {
                // Show shimmer for loading and error states
                // Dialog will handle connectivity notification
                return _buildLoadingState();
              }

              if (productState is ProductListLoaded) {
                final allProducts = productState.products;
                _buildCategoryList(allProducts);

                if (allProducts.isEmpty) {
                  return _buildEmptyState();
                }

                final displayList = allProducts.take(widget.showCount).toList();
                return _buildContentState(context, displayList, isLoggedIn);
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  // ========== LOADING STATE ==========
  Widget _buildLoadingState() {
    return Container(
      // margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.03),
        //     blurRadius: 10,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderShimmer(),
          const SizedBox(height: 16),
          _buildCategoryChipsShimmer(),
          const SizedBox(height: 16),
          _buildProductCardsShimmer(),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: 70,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChipsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCardsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: SizedBox(
        height: 260,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return Container(
              width: 176,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }

  // ========== EMPTY STATE ==========
  Widget _buildEmptyState() {
    return Container(
      // margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.03),
        //     blurRadius: 10,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum Ada Produk',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== CONTENT STATE ==========
  Widget _buildContentState(
    BuildContext context,
    List displayList,
    bool isLoggedIn,
  ) {
    final bool isIOS = Platform.isIOS;

    return Container(
      // margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.03),
        //     blurRadius: 10,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.subtitle!,
              style: TextStyle(
                fontSize: isIOS ? 12 : 11,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (_categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCategoryChips(),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final product = displayList[index];
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 176,
                    minWidth: 176,
                    maxHeight: 260,
                  ),
                  child: ProductCard(
                    product: product,
                    width: 176,
                    showWishlistButton: isLoggedIn,
                    onTap: () {
                      context.pushNamed(
                        'productDetail',
                        pathParameters: {'id': product.id.toString()},
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ========== HEADER ==========
  Widget _buildHeader(BuildContext context) {
    final bool isIOS = Platform.isIOS;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            widget.title,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: isIOS ? 15 : 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            context.pushNamed(
              'productsHighlight',
              extra: {
                'hotDealsOnly': widget.hotDealsOnly,
                'title': widget.hotDealsOnly
                    ? 'Produk Terlaris'
                    : 'Produk Terbaru',
                'headerTitle': widget.hotDealsOnly
                    ? 'Jangan Kehabisan Produk Terlaris 🤩'
                    : 'Yang Baru Dari Kami 🔥',
                'headerSubTitle': widget.hotDealsOnly
                    ? 'Siapa cepat, dia dapat, sikaaat ...'
                    : 'Yang baru - baru, dijamin menarik !!!',
              },
            );
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
                    fontSize: isIOS ? 12 : 11,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: isIOS ? 12 : 11,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========== CATEGORY CHIPS ==========
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final selected = _selectedCategoryId == null;
            return _CategoryChip(
              label: 'Semua',
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                });
              },
            );
          }

          final category = _categories[index - 1];
          final selected = _selectedCategoryId == category.id;

          return _CategoryChip(
            label: category.name,
            selected: selected,
            onTap: () => _onCategoryTap(category.id),
          );
        },
      ),
    );
  }
}

// ========== CATEGORY ITEM ==========
class _CategoryItem {
  final int id;
  final String name;

  _CategoryItem({required this.id, required this.name});
}

// ========== CATEGORY CHIP ==========
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Platform.isIOS;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(18),
          border: selected
              ? null
              : Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: isIOS ? 12.5 : 12,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
