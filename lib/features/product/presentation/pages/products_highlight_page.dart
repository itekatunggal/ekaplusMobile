// lib/features/product/presentation/pages/products_highlight_page.dart
import 'dart:io' as io;
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:get_it/get_it.dart';

final GetIt myinjection = GetIt.instance;

class ProductsHighlight extends StatefulWidget {
  final bool hotDealsOnly;
  final String title;
  final String headerTitle;
  final String headerSubTitle;

  const ProductsHighlight({
    super.key,
    this.hotDealsOnly = false,
    this.headerTitle = '',
    this.title = 'Products',
    this.headerSubTitle = 'Products',
  });

  @override
  State<ProductsHighlight> createState() => _ProductsHighlightState();
}

class _ProductsHighlightState extends State<ProductsHighlight> {
  late final ProductBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) return 0.72;
    if (width >= 390) return 0.68;
    if (width >= 360) return 0.65;
    return 0.62;
  }

  double _getCrossAxisSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) return 16;
    if (width >= 390) return 14;
    return 12;
  }

  double _getMainAxisSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) return 16;
    if (width >= 390) return 14;
    return 12;
  }

  EdgeInsets _getGridPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
    if (width >= 390) {
      return const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
    }
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  }

  @override
  void initState() {
    super.initState();

    _bloc = ProductBloc(
      getAllProduct: myinjection(),
      getProduct: myinjection(),
      getHotDeals: myinjection(),
    );

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    _bloc.add(
      ProductEventLoadFirstPage(
        filters: widget.hotDealsOnly
            ? [
                ['hot_deals', '=', '1'],
              ]
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.85) {
      final currentState = _bloc.state;

      if (currentState is ProductListLoaded &&
          !widget.hotDealsOnly &&
          !currentState.isLoadingMore &&
          currentState.hasMore) {
        setState(() => _isLoadingMore = true);
        _bloc.add(const ProductEventLoadNextPage());
      }
    }
  }

  Future<void> _refresh() async {
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: widget.title),
        body: SafeArea(
          child: BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductListLoaded) {
                setState(() => _isLoadingMore = false);
              }
            },
            builder: (context, state) {
              if (state is ProductListLoading || state is ProductInitial) {
                return _buildLoadingShimmer(context);
              }

              if (state is ProductError) {
                return _buildErrorState(context, state.message);
              }

              if (state is ProductListLoaded) {
                return _buildProductList(context, state, state.products);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // ========== ERROR STATE ==========
  Widget _buildErrorState(BuildContext context, String message) {
    final bool isIOS = io.Platform.isIOS;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: isIOS ? 16 : 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Periksa koneksi internet Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isIOS ? 14 : 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _refresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Coba Lagi',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: isIOS ? 14 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== PRODUCT LIST ==========
  Widget _buildProductList(
    BuildContext context,
    ProductListLoaded state,
    List<dynamic> products,
  ) {
    final bool isIOS = io.Platform.isIOS;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryColor,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header Section
          if (widget.headerTitle.isNotEmpty || widget.headerSubTitle.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.06),
                      AppColors.primaryColor.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.headerTitle.isNotEmpty)
                      Text(
                        widget.headerTitle,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: isIOS ? 15 : 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    if (widget.headerTitle.isNotEmpty &&
                        widget.headerSubTitle.isNotEmpty)
                      const SizedBox(height: 4),
                    if (widget.headerSubTitle.isNotEmpty)
                      Text(
                        widget.headerSubTitle,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: isIOS ? 12 : 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Empty State
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Belum Ada Produk',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: isIOS ? 16 : 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Produk akan segera tersedia',
                      style: TextStyle(
                        fontSize: isIOS ? 14 : 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Product Grid
            SliverPadding(
              padding: _getGridPadding(context),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: _getChildAspectRatio(context),
                  crossAxisSpacing: _getCrossAxisSpacing(context),
                  mainAxisSpacing: _getMainAxisSpacing(context),
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    width: double.infinity,
                    onTap: () {
                      context.pushNamed(
                        'productDetail',
                        pathParameters: {'id': product.id.toString()},
                      );
                    },
                  );
                }, childCount: products.length),
              ),
            ),

            // Loading More Indicator
            if (!widget.hotDealsOnly && state.isLoadingMore && state.hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // End Message
            if (!state.hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '✓ Semua produk sudah dimuat',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: isIOS ? 12 : 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],

          // Bottom Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // ========== LOADING SHIMMER ==========
  Widget _buildLoadingShimmer(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          if (widget.headerTitle.isNotEmpty || widget.headerSubTitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[50]!,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

          // Grid Shimmer
          Padding(
            padding: _getGridPadding(context),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: _getChildAspectRatio(context),
                crossAxisSpacing: _getCrossAxisSpacing(context),
                mainAxisSpacing: _getMainAxisSpacing(context),
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[50]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
