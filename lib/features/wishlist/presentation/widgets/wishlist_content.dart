// lib/features/wishlist/presentation/widgets/wishlist_content.dart

// ignore_for_file: use_build_context_synchronously

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_state.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_empty_state.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class WishlistContent extends StatefulWidget {
  final int userId;

  final String searchQuery;

  final bool isSelectionMode;

  final VoidCallback onExitSelectionMode;

  const WishlistContent({
    super.key,
    required this.userId,
    this.searchQuery = '',
    this.isSelectionMode = false,
    required this.onExitSelectionMode,
  });

  @override
  State<WishlistContent> createState() => _WishlistContentState();
}

class _WishlistContentState extends State<WishlistContent>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  bool _hasInitialized = false;

  List<WishlistItem>? _cachedItems;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  String? _errorMessage;
  String? _selectedCategoryKey;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized && mounted) {
        _loadWishlist();
        _hasInitialized = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  void _loadWishlist() {
    if (!mounted) return;

    context.read<WishlistBloc>().add(const LoadWishlistFirstPage());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_isLoadingMore) return;

    if (!_hasMore) return;

    if (!mounted) return;

    final position = _scrollController.position;

    final maxScrollExtent = position.maxScrollExtent;
    final currentOffset = position.pixels;

    if (maxScrollExtent <= 0) return;

    // Load berikutnya ketika sudah mendekati bawah.
    if (currentOffset >= maxScrollExtent * 0.90) {
      setState(() {
        _isLoadingMore = true;
      });

      context.read<WishlistBloc>().add(const LoadWishlistNextPage());
    }
  }

  List<WishlistItem> _getFilteredItems() {
    final items = _cachedItems ?? const <WishlistItem>[];

    final query = widget.searchQuery.trim().toLowerCase();

    return items.where((wishlist) {
      final item = wishlist.item;

      if (_selectedCategoryKey != null &&
          _categoryKey(item.category) != _selectedCategoryKey) {
        return false;
      }

      if (query.isEmpty) return true;

      final name = item.itemName.toLowerCase();
      final code = item.itemCode.toLowerCase();

      return name.contains(query) || code.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final media = MediaQuery.of(context);

    final scaler = media.textScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.0,
    );

    return MediaQuery(
      data: media.copyWith(textScaler: scaler),
      child: BlocListener<WishlistBloc, WishlistState>(
        listener: (context, state) {
          if (state is WishlistLoaded) {
            if (!mounted) return;

            setState(() {
              _cachedItems = state.items;
              final availableCategoryKeys = state.items
                  .map((wishlist) => _categoryKey(wishlist.item.category))
                  .whereType<String>()
                  .toSet();
              if (!availableCategoryKeys.contains(_selectedCategoryKey)) {
                _selectedCategoryKey = null;
              }
              _isLoading = false;
              _errorMessage = null;
              _isLoadingMore = false;
              _hasMore = state.hasMore;
            });
          } else if (state is WishlistLoading) {
            if (_cachedItems == null && mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            }
          } else if (state is WishlistError) {
            if (!mounted) return;

            setState(() {
              _isLoading = false;
              _isLoadingMore = false;
              _errorMessage = state.message;
            });
          } else if (state is WishlistToggled) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!mounted) return;

              context.read<WishlistBloc>().add(const LoadWishlistFirstPage());
            });
          }
        },
        child: BlocBuilder<WishlistBloc, WishlistState>(
          builder: (context, wishlistState) {
            // ===============================
            // DATA TERSEDIA
            // ===============================

            if (_cachedItems != null && _cachedItems!.isNotEmpty) {
              final filteredItems = _getFilteredItems();

              return Column(
                children: [
                  // Filter / category chips
                  _buildFilterSection(items: _cachedItems!),

                  Expanded(
                    child: filteredItems.isEmpty
                        ? _buildSearchEmptyState()
                        : WishlistListView(
                            userId: widget.userId,
                            wishlistItems: filteredItems,
                            scrollController: _scrollController,
                            isLoadingMore: false,
                            isSelectionMode: widget.isSelectionMode,
                            onExitSelectionMode: widget.onExitSelectionMode,
                          ),
                  ),

                  if (_isLoadingMore && _hasMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                ],
              );
            }

            // ===============================
            // EMPTY WISHLIST
            // ===============================

            if (_cachedItems != null && _cachedItems!.isEmpty && !_isLoading) {
              return const WishlistEmptyState();
            }

            // ===============================
            // ERROR
            // ===============================

            if (_errorMessage != null) {
              return _buildErrorState();
            }

            // ===============================
            // LOADING
            // ===============================

            return _buildLoadingShimmer();
          },
        ),
      ),
    );
  }

  String? _categoryKey(WishlistItemCategory? category) {
    if (category == null || category.name.trim().isEmpty) return null;
    return '${category.id}:${category.name.trim().toLowerCase()}';
  }

  Widget _buildFilterSection({required List<WishlistItem> items}) {
    final categories = <String, _WishlistCategoryFilter>{};
    for (final wishlist in items) {
      final category = wishlist.item.category;
      final key = _categoryKey(category);
      if (category == null || key == null) continue;

      final current = categories[key];
      categories[key] = _WishlistCategoryFilter(
        key: key,
        label: category.name,
        count: (current?.count ?? 0) + 1,
      );
    }
    final categoryFilters = categories.values.toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Semua',
              count: items.length,
              selected: _selectedCategoryKey == null,
              onTap: () => setState(() => _selectedCategoryKey = null),
            ),
            for (final category in categoryFilters) ...[
              const SizedBox(width: 8),
              _buildFilterChip(
                label: category.label,
                count: category.count,
                selected: _selectedCategoryKey == category.key,
                onTap: () => setState(() {
                  _selectedCategoryKey = category.key;
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryColor
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: selected
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF334155),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.22)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF64748B),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 28,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Item tidak ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Coba cari menggunakan SKU atau nama item lainnya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w400,
                fontFamily: AppFonts.primaryFont,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 28,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Wishlist belum dapat dimuat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _errorMessage?.trim().isNotEmpty == true
                  ? _errorMessage!
                  : 'Periksa koneksi Anda, lalu coba kembali.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w400,
                fontFamily: AppFonts.primaryFont,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadWishlist,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        // Shimmer filter
        Container(
          width: double.infinity,
          color: const Color(0xFFF8FAFC),
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 76,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 118,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 110,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 150,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Container(
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WishlistCategoryFilter {
  final String key;
  final String label;
  final int count;

  const _WishlistCategoryFilter({
    required this.key,
    required this.label,
    required this.count,
  });
}
