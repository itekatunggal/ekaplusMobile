import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category_group.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:ekaplus_ekatunggal/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final CategorySimpleEntity category;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.categoryId,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  final ProductBloc _pBloc = ProductBloc(
    getAllProduct: myinjection(),
    getProduct: myinjection(),
    getHotDeals: myinjection(),
  );

  String? _resolvedTitle;
  String? _resolvedSubtitle;

  @override
  void initState() {
    super.initState();
    _resolvedTitle = widget.category.title;
    _resolvedSubtitle = widget.category.subtitle;
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    _pBloc.add(
      ProductEventLoadFirstPage(
        filters: [
          ['item_category', '=', widget.categoryId],
        ],
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_isLoadingMore) return;

    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    if (current >= max * 0.9) {
      setState(() => _isLoadingMore = true);
      _pBloc.add(const ProductEventLoadNextPage());
    }
  }

  int _crossAxisCount(double width) {
    if (width >= 600) return 3;
    return 2;
  }

  double _aspectRatio(double width) {
    if (width >= 600) return 0.72;
    return 0.68;
  }

  double _spacing(double width) {
    if (width >= 600) return 16;
    return 12;
  }

  EdgeInsets _padding(double width) {
    if (width >= 600) return const EdgeInsets.all(16);
    return const EdgeInsets.all(12);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryStateLoadedCategory) {
              setState(() {
                _resolvedTitle = state.detailCategory.title ?? _resolvedTitle;
                _resolvedSubtitle =
                    state.detailCategory.subtitle ?? _resolvedSubtitle;
              });
            }
          },
        ),
        BlocListener<ProductBloc, ProductState>(
          bloc: _pBloc,
          listener: (context, state) {
            if (state is ProductListLoaded && !state.isLoadingMore) {
              setState(() => _isLoadingMore = false);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(),
                BlocBuilder<ProductBloc, ProductState>(
                  bloc: _pBloc,
                  builder: (context, state) {
                    if (state is ProductListLoading || state is ProductError) {
                      // Show loading for both loading and error states
                      // Dialog will handle connectivity notification
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (state is ProductListLoaded) {
                      if (state.products.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada produk',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: _padding(width),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _crossAxisCount(width),
                                childAspectRatio: _aspectRatio(width),
                                crossAxisSpacing: _spacing(width),
                                mainAxisSpacing: _spacing(width),
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = state.products[index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                context.pushNamed(
                                  'productDetail',
                                  pathParameters: {'id': product.id.toString()},
                                );
                              },
                            );
                          }, childCount: state.products.length),
                        ),
                      );
                    }

                    return const SliverToBoxAdapter();
                  },
                ),
                BlocBuilder<ProductBloc, ProductState>(
                  bloc: _pBloc,
                  builder: (context, state) {
                    if (state is ProductListLoaded && state.isLoadingMore) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        String name = widget.category.name;
        if (state is CategoryStateLoadedCategory) {
          name = state.detailCategory.name;
        }

        return SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              name,
              style: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB71C1C), Color(0xFF8E0000)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                if (widget.category.image.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl:
                        '${ApiConfig.baseImageUrl}/${widget.category.image}',
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
