// ignore_for_file: empty_catches

import 'dart:async';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/category/data/models/category_group_model.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category_group.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';
import 'package:ekaplus_ekatunggal/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/filter_product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductPage extends StatefulWidget {
  final String? categoryName;
  final int? categoryId;

  const ProductPage({super.key, this.categoryName, this.categoryId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<int> _selectedTypeIds = [];
  List<int> _selectedCategoryIds = [];

  final Map<int, String> _typeNames = {};
  final Map<int, String> _categoryNames = {};

  int? _lockedTypeId;

  late ProductBloc pBloc;
  late TypeBloc typeBloc;
  late CategoryBloc categoryBloc;

  double _savedScrollPosition = 0.0;
  bool _shouldRestoreScroll = false;
  bool _isInitialized = false;
  bool _hasInitializedFromArgs = false;

  @override
  void initState() {
    super.initState();
    pBloc = ProductBloc(
      getAllProduct: myinjection(),
      getProduct: myinjection(),
      getHotDeals: myinjection(),
    );

    typeBloc = context.read<TypeBloc>();
    categoryBloc = context.read<CategoryBloc>();

    typeBloc.add(TypeEventGetAllTypes(0));
    categoryBloc.add(CategoryEventGetByType());

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      pBloc.add(const ProductEventLoadNextPage());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _loadProducts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInitializedFromArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Category) {
        _selectedCategoryIds = [args.id];
        _hasInitializedFromArgs = true;
      } else if (args is CategorySimpleModel) {
        _selectedCategoryIds = [args.id];
        _hasInitializedFromArgs = true;
      } else if (widget.categoryName != null) {
        if (widget.categoryId != null) {
          _selectedCategoryIds = [widget.categoryId!];
          _hasInitializedFromArgs = true;
        }
      } else {
        _hasInitializedFromArgs = true;
      }

      if (_hasInitializedFromArgs) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    pBloc.close();
    super.dispose();
  }

  void _removeTypeFilter(int typeId) {
    if (_lockedTypeId != null && typeId == _lockedTypeId) {
      return;
    }
    setState(() {
      _selectedTypeIds.remove(typeId);
    });
    _loadProducts();
  }

  void _loadProducts() {
    final filters = _buildFilters();
    pBloc.add(
      ProductEventLoadFirstPage(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        filters: filters.isEmpty ? null : filters,
      ),
    );
  }

  List<List<dynamic>> _buildFilters() {
    final List<List<dynamic>> filters = [];
    if (_selectedCategoryIds.isNotEmpty) {
      filters.add(["item_category", "in", _selectedCategoryIds]);
    }
    if (_selectedTypeIds.isNotEmpty) {
      filters.add(["item_category.item_type", "in", _selectedTypeIds]);
    }
    return filters;
  }

  void _removeCategoryFilter(int categoryId) {
    setState(() {
      _selectedCategoryIds.remove(categoryId);
    });
    _loadProducts();
  }

  void _clearAllFilters() {
    setState(() {
      if (_lockedTypeId != null) {
        _selectedTypeIds = [_lockedTypeId!];
      } else {
        _selectedTypeIds.clear();
      }
      _selectedCategoryIds.clear();
      _searchController.clear();
    });
    _loadProducts();
  }

  void _restoreScrollPosition() {
    if (_shouldRestoreScroll &&
        _scrollController.hasClients &&
        _savedScrollPosition > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          try {
            final maxScroll = _scrollController.position.maxScrollExtent;
            if (maxScroll > 0) {
              final targetScroll = _savedScrollPosition > maxScroll
                  ? maxScroll
                  : _savedScrollPosition;

              _scrollController.jumpTo(targetScroll);
            }
          } catch (e) {
            // Ignore scroll errors
          } finally {
            _shouldRestoreScroll = false;
            _savedScrollPosition = 0.0;
          }
        }
      });
    }
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  double _getChildAspectRatio(double width) {
    if (width >= 900) return 0.72;
    if (width >= 600) return 0.70;
    return 0.68;
  }

  double _getSpacing(double width) {
    if (width >= 900) return 16;
    if (width >= 600) return 14;
    return 12;
  }

  Widget _buildLoadingShimmer(double screenWidth) {
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final aspectRatio = _getChildAspectRatio(screenWidth);
    final spacing = _getSpacing(screenWidth);

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(50, 50, 93, 0.177),
                  blurRadius: 5,
                  spreadRadius: -1,
                  offset: Offset(0, 2),
                ),
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.137),
                  blurRadius: 3,
                  spreadRadius: -1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 27,
                            height: 27,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateTypeNames(List<Type> types) {
    _typeNames.clear();
    for (var type in types) {
      _typeNames[type.id] = type.name;
    }
  }

  void _updateCategoryNames(List<CategoryGroupEntity> categoryGroups) {
    _categoryNames.clear();
    for (var group in categoryGroups) {
      for (var category in group.categories) {
        _categoryNames[category.id] = category.name;
      }
    }
  }

  void _showComingSoon(String feature) {
    AppSnackbar.show(
      context,
      message: '$feature akan segera tersedia',
      type: AppSnackbarType.info,
    );
  }

  String get _headerTitle {
    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      return widget.categoryName!;
    }
    if (_selectedCategoryIds.length == 1 &&
        _categoryNames[_selectedCategoryIds.first] != null) {
      return _categoryNames[_selectedCategoryIds.first]!;
    }
    return 'Produk';
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 178,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomHeaderAppBar(
              title: _headerTitle,
              brandStyle: true,
              brandLabel: 'EKAPLUS',
              showBackButton: true,
              height: 178,
              actions: [
                CustomHeaderActionButton(
                  tooltip: 'Bantuan',
                  onPressed: () => _showComingSoon('Panduan produk'),
                  icon: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                CustomHeaderActionButton(
                  tooltip: 'Notifikasi',
                  onPressed: () => _showComingSoon('Notifikasi'),
                  icon: const Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                      Positioned(
                        right: -1,
                        top: -1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(width: 7, height: 7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search bar + tombol filter
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Row(
              children: [
                Expanded(child: _buildSearchField()),
                const SizedBox(width: 10),
                _buildFilterButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
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
        controller: _searchController,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) {
          _onSearchChanged(value);
          setState(() {});
        },
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.primaryFont,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Cari kain, busa, springbed, kode...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            fontFamily: AppFonts.primaryFont,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 18,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 42,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    setState(() {});
                  },
                  splashRadius: 18,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF94A3B8),
                    size: 17,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 42,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    final activeCount = _selectedTypeIds.length + _selectedCategoryIds.length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            onTap: () => _showFilterBottomSheet(context),
            borderRadius: BorderRadius.circular(11),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.sliders,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        if (activeCount > 0)
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  '$activeCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scaler = media.textScaler.clamp(
      minScaleFactor: 0.90,
      maxScaleFactor: 1.0,
    );

    return MediaQuery(
      data: media.copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<TypeBloc, TypeState>(
                    listener: (context, state) {
                      if (state is TypeStateLoadedAllType) {
                        setState(() {
                          _updateTypeNames(state.allType);
                        });
                      }
                    },
                  ),
                  BlocListener<CategoryBloc, CategoryState>(
                    listener: (context, state) {
                      if (state is CategoryStateLoadedCategoryByType) {
                        setState(() {
                          _updateCategoryNames(state.allCategory);
                        });
                      }
                    },
                  ),
                ],
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final crossAxisCount = _getCrossAxisCount(screenWidth);
                    final aspectRatio = _getChildAspectRatio(screenWidth);
                    final spacing = _getSpacing(screenWidth);

                    return Column(
                      children: [
                        // Filter Chips - Horizontal Scroll
                        if (_selectedTypeIds.isNotEmpty ||
                            _selectedCategoryIds.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Filter Aktif',
                                        style: TextStyle(
                                          fontFamily: AppFonts.primaryFont,
                                          fontSize: 13,
                                          color: Color(0xFF1E293B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: _clearAllFilters,
                                        icon: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: AppColors.primaryColor,
                                        ),
                                        label: const Text(
                                          'Hapus Semua',
                                          style: TextStyle(
                                            fontFamily: AppFonts.primaryFont,
                                            fontSize: 12,
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Type Chips - Horizontal
                                if (_selectedTypeIds.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'Type',
                                      style: TextStyle(
                                        fontFamily: AppFonts.primaryFont,
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 36,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _selectedTypeIds.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final typeId = _selectedTypeIds[index];
                                        final isLocked =
                                            _lockedTypeId != null &&
                                            typeId == _lockedTypeId;
                                        return _buildFilterChip(
                                          label:
                                              _typeNames[typeId] ??
                                              'Loading...',
                                          onRemove: isLocked
                                              ? null
                                              : () => _removeTypeFilter(typeId),
                                          isLocked: isLocked,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Category Chips - Horizontal
                                if (_selectedCategoryIds.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'Kategori',
                                      style: TextStyle(
                                        fontFamily: AppFonts.primaryFont,
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 36,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _selectedCategoryIds.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final categoryId =
                                            _selectedCategoryIds[index];
                                        return _buildFilterChip(
                                          label:
                                              _categoryNames[categoryId] ??
                                              'Loading...',
                                          onRemove: () =>
                                              _removeCategoryFilter(categoryId),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),

                        // Product Grid
                        Expanded(
                          child: BlocBuilder<ProductBloc, ProductState>(
                            bloc: pBloc,
                            builder: (context, state) {
                              // Initialize products only once
                              if (!_isInitialized &&
                                  state is! ProductListLoaded &&
                                  state is! ProductListLoading) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!_isInitialized) {
                                    _loadProducts();
                                    _isInitialized = true;
                                  }
                                });
                              }

                              if (state is ProductListLoading) {
                                return _buildLoadingShimmer(screenWidth);
                              }

                              if (state is ProductError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        state.message,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadProducts,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                        ),
                                        child: const Text('Coba Lagi'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (state is ProductListLoaded) {
                                _restoreScrollPosition();

                                if (state.products.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Tidak ada produk ditemukan',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (_selectedTypeIds.isNotEmpty ||
                                            _selectedCategoryIds.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: TextButton(
                                              onPressed: _clearAllFilters,
                                              child: const Text(
                                                'Hapus Filter',
                                                style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }

                                return Column(
                                  children: [
                                    Expanded(
                                      child: GridView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.all(16),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              childAspectRatio: aspectRatio,
                                              crossAxisSpacing: spacing,
                                              mainAxisSpacing: spacing,
                                            ),
                                        itemCount: state.products.length,
                                        itemBuilder: (context, index) {
                                          final product = state.products[index];
                                          return ProductCard(
                                            product: product,
                                            onTap: () {
                                              if (_scrollController
                                                  .hasClients) {
                                                _savedScrollPosition =
                                                    _scrollController.offset;
                                                _shouldRestoreScroll = true;
                                              }

                                              context.pushNamed(
                                                'productDetail',
                                                pathParameters: {
                                                  'id': product.id.toString(),
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    if (state.isLoadingMore)
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                  ],
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    VoidCallback? onRemove,
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLocked)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(Icons.lock_rounded, size: 14, color: Colors.black87),
            ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.primaryFont,
              color: Color(0xC6000000),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!isLocked) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Color(0xC6000000),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return FilterProduct(
          selectedTypeIds: _selectedTypeIds,
          selectedCategoryIds: _selectedCategoryIds,
          lockedTypeId: _lockedTypeId,
          onApplyFilter: (typeIds, categoryIds) {
            setState(() {
              _selectedTypeIds = typeIds;
              _selectedCategoryIds = categoryIds;
            });
            _loadProducts();
          },
        );
      },
    );
  }
}
