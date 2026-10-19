// lib/features/wishlist/presentation/widgets/wishlist_content.dart
// FINAL SOLUTION dengan fix infinite scroll

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

  const WishlistContent({super.key, required this.userId});

  @override
  State<WishlistContent> createState() => _WishlistContentState();
}

class _WishlistContentState extends State<WishlistContent>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _hasInitialized = false;

  // ✅ CACHE DATA DI WIDGET LEVEL
  List<WishlistItem>? _cachedItems;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true; // ✅ Track apakah masih ada data
  String? _errorMessage;

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
    if (_isLoadingMore) return; // ✅ Jangan load kalau sedang loading
    if (!_hasMore) return; // ✅ Jangan load kalau udah ga ada data
    if (!mounted) return;

    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    if (current >= max * 0.9) {
      if (mounted) {
        setState(() => _isLoadingMore = true);
      }
      context.read<WishlistBloc>().add(const LoadWishlistNextPage());
    }
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
          // ✅ UPDATE CACHE SETIAP STATE BERUBAH
          if (state is WishlistLoaded) {
            if (mounted) {
              setState(() {
                _cachedItems = state.items;
                _isLoading = false;
                _errorMessage = null;
                _isLoadingMore = false; // ✅ Reset loading more
                _hasMore = state.hasMore; // ✅ Update hasMore dari BLoC
              });
            }
          } else if (state is WishlistLoading) {
            // Hanya set loading kalau belum ada cached data
            if (_cachedItems == null && mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            }
          } else if (state is WishlistError) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _isLoadingMore = false;
                _errorMessage = state.message;
              });
            }
          } else if (state is WishlistToggled) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                context.read<WishlistBloc>().add(const LoadWishlistFirstPage());
              }
            });
          }
        },
        child: BlocBuilder<WishlistBloc, WishlistState>(
          builder: (context, wishlistState) {
            if (_cachedItems != null && _cachedItems!.isNotEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: WishlistListView(
                      userId: widget.userId,
                      wishlistItems: _cachedItems!,
                      scrollController: _scrollController,
                      isLoadingMore:
                          false, // ✅ Jangan pass isLoadingMore ke ListView
                    ),
                  ),
                  // ✅ Loading indicator di bawah list, hanya kalau masih ada data
                  if (_isLoadingMore && _hasMore)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }

            // ✅ EMPTY STATE
            if (_cachedItems != null && _cachedItems!.isEmpty && !_isLoading) {
              return const WishlistEmptyState();
            }

            // ✅ ERROR STATE - Show shimmer instead of error message
            // Dialog will handle connectivity notification
            if (_errorMessage != null) {
              return _buildLoadingShimmer();
            }

            // ✅ LOADING STATE
            return _buildLoadingShimmer();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 48, 0, 20),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.07),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                      const SizedBox(height: 5),
                      Container(
                        width: 120,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
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
    );
  }
}
