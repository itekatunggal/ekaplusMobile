// lib/features/search/presentation/pages/search_page.dart
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/filter_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/search/presentation/bloc/search_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<int> _selectedTypeIds = [];
  List<int> _selectedCategoryIds = [];

  // Riwayat pencarian (in-memory, hanya untuk tampilan UI)
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(const SearchEventInitial());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {}); // Update UI untuk clear button
    _runSearch(query);
  }

  List<List<dynamic>> _buildFilters() {
    final filters = <List<dynamic>>[];
    if (_selectedCategoryIds.isNotEmpty) {
      filters.add(['item_category', 'in', _selectedCategoryIds]);
    }
    if (_selectedTypeIds.isNotEmpty) {
      filters.add(['item_category.item_type', 'in', _selectedTypeIds]);
    }
    return filters;
  }

  void _runSearch([String? query]) {
    context.read<SearchBloc>().add(
      SearchEventQueryChanged(
        query ?? _searchController.text,
        filters: _buildFilters(),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _runSearch('');
    _searchFocusNode.requestFocus();
    setState(() {});
  }

  void _showFilterBottomSheet() {
    _searchFocusNode.unfocus();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => FilterProduct(
        selectedTypeIds: _selectedTypeIds,
        selectedCategoryIds: _selectedCategoryIds,
        onApplyFilter: (typeIds, categoryIds) {
          setState(() {
            _selectedTypeIds = List<int>.from(typeIds);
            _selectedCategoryIds = List<int>.from(categoryIds);
          });
          _runSearch();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedTypeIds.clear();
      _selectedCategoryIds.clear();
    });
    _runSearch();
  }

  void _addRecentSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _recentSearches.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
      _recentSearches.insert(0, q);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    });
  }

  void _removeRecentSearch(String query) {
    setState(() => _recentSearches.remove(query));
  }

  void _clearRecentSearches() {
    setState(() => _recentSearches.clear());
  }

  void _searchFromText(String text) {
    _searchController.text = text;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    _onSearchChanged(text);
    _addRecentSearch(text);
  }

  void _showComingSoon(String feature) {
    AppSnackbar.show(
      context,
      message: '$feature akan segera tersedia',
      type: AppSnackbarType.info,
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
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchStateLoading) {
                    return _buildLoadingShimmer();
                  }

                  if (state is SearchStateError) {
                    return _buildErrorState(state.message);
                  }

                  if (state is SearchStateInitial) {
                    return _buildInitialContent(state);
                  }

                  if (state is SearchStateLoaded) {
                    if (state.results.isEmpty) {
                      return _buildEmptyState(state.query);
                    }
                    return _buildSearchResults(state);
                  }

                  if (state is SearchStateEmpty) {
                    return _buildEmptyState(state.query);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 178,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomHeaderAppBar(
              title: 'Cari Produk',
              brandStyle: true,
              brandLabel: 'EKAPLUS',
              showBackButton: true,
              height: 178,
              actions: [
                CustomHeaderActionButton(
                  tooltip: 'Bantuan',
                  onPressed: () => _showComingSoon('Panduan pencarian'),
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

          // Search bar + tombol filter (ukuran sama dengan wishlist)
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
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        onChanged: _onSearchChanged,
        onSubmitted: _addRecentSearch,
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
                  onPressed: _clearSearch,
                  splashRadius: 18,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF94A3B8),
                    size: 17,
                  ),
                )
              // : IconButton(
              //     tooltip: 'Pencarian suara',
              //     onPressed: () => _showComingSoon('Pencarian suara'),
              //     splashRadius: 18,
              //     icon: const Icon(
              //       Icons.mic_none_rounded,
              //       color: Color(0xFF94A3B8),
              //       size: 17,
              //     ),
              //   ),
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 42,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    final activeFilterCount =
        _selectedTypeIds.length + _selectedCategoryIds.length;

    return Material(
      color: activeFilterCount > 0
          ? AppColors.secondaryColor
          : Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: _showFilterBottomSheet,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                color: activeFilterCount > 0 ? Colors.black87 : Colors.white,
                size: 19,
              ),
              if (activeFilterCount > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      activeFilterCount > 99 ? '99+' : '$activeFilterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SHARED SECTION UI =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required Widget icon,
    required Color iconBg,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: icon,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // ================= LOADING SHIMMER =================

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Hot deals shimmer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    5,
                    (i) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 80,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Categories shimmer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => Column(
                    children: [
                      Expanded(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ================= INITIAL CONTENT =================

  Widget _buildInitialContent(SearchStateInitial state) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Hot Deals Section
        if (state.hotDeals.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    icon: FaIcon(
                      FontAwesomeIcons.fire,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                    iconBg: Colors.red.shade50,
                    title: 'Paling Banyak Dicari',
                    trailing: Text(
                      'B2B Manufaktur',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 10.5,
                        color: Colors.blueGrey.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.hotDeals
                        .map((p) => _buildHotDealChip(p.name))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

        // Recent Searches Section
        if (_recentSearches.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildRecentSearches()),
        ],

        // Categories Section
        if (state.categories.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    icon: FaIcon(
                      FontAwesomeIcons.layerGroup,
                      size: 14,
                      color: Colors.teal.shade700,
                    ),
                    iconBg: Colors.teal.shade50,
                    title: 'Eksplor Kategori',
                    // subtitle: 'Pilih material manufaktur & komponen pabrik',
                    trailing: InkWell(
                      onTap: () => _showComingSoon('Semua kategori'),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return _buildCategoryItem(category);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  // ================= RECENT SEARCHES =================

  Widget _buildRecentSearches() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icon(
              Icons.history_rounded,
              size: 17,
              color: Colors.grey.shade700,
            ),
            iconBg: Colors.grey.shade100,
            title: 'Pencarian Terakhir',
            trailing: InkWell(
              onTap: _clearRecentSearches,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Text(
                  'Hapus Riwayat',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          ..._recentSearches.asMap().entries.map((entry) {
            final isLast = entry.key == _recentSearches.length - 1;
            return _buildRecentItem(entry.value, showDivider: !isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String text, {required bool showDivider}) {
    return Column(
      children: [
        InkWell(
          onTap: () => _searchFromText(text),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _removeRecentSearch(text),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  // ================= CATEGORY ITEM =================
  Widget _buildCategoryItem(category) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductPage(),
            settings: RouteSettings(arguments: category),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(33, 35, 38, 0.1),
                    blurRadius: 10,
                    spreadRadius: -10,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _buildCategoryIcon(category),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(category) {
    final String iconPath =
        "${ApiConfig.baseImageUrl}/${category.icon}?format=rs:fill:250:250/q:80/ext:webp";

    if (iconPath.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: Icon(
          Icons.category_rounded,
          color: Colors.grey.shade400,
          size: 32,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: iconPath,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.white),
      ),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey.shade100,
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.grey.shade400,
          size: 32,
        ),
      ),
    );
  }

  // ================= SEARCH RESULT =================

  Widget _buildSearchResults(SearchStateLoaded state) {
    return Column(
      children: [
        // Result count header
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.circleCheck,
                size: 16,
                color: Colors.green.shade600,
              ),
              const SizedBox(width: 10),
              Text(
                'Ditemukan ${state.results.length} produk',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),

        // Product Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final product = state.results[index];
              return ProductCard(
                product: product,
                onTap: () {
                  _addRecentSearch(_searchController.text);
                  context.pushNamed(
                    'productDetail',
                    pathParameters: {'id': product.id.toString()},
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotDealChip(String text) {
    return InkWell(
      onTap: () => _searchFromText(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 10,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget _buildEmptyState(String query) {
    final hasActiveFilters =
        _selectedTypeIds.isNotEmpty || _selectedCategoryIds.isNotEmpty;
    final hasQuery = query.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasQuery
                  ? 'Tidak ada hasil untuk\n"$query"'
                  : 'Tidak ada produk yang sesuai filter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilters
                  ? 'Coba ubah atau hapus filter yang aktif'
                  : 'Coba kata kunci lain atau eksplor kategori',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Hapus Filter'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= ERROR STATE =================

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
