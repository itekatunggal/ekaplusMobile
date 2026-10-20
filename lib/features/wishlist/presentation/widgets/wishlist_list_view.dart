// lib/features/wishlist/presentation/widgets/wishlist_list_view.dart

// ignore_for_file: deprecated_member_use

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistListView extends StatefulWidget {
  final int userId;

  final List<WishlistItem> wishlistItems;

  final ScrollController? scrollController;

  final bool isLoadingMore;

  final bool isSelectionMode;

  final VoidCallback? onExitSelectionMode;

  const WishlistListView({
    super.key,
    required this.userId,
    required this.wishlistItems,
    this.scrollController,
    this.isLoadingMore = false,
    this.isSelectionMode = false,
    this.onExitSelectionMode,
  });

  @override
  State<WishlistListView> createState() => _WishlistListViewState();
}

class _WishlistListViewState extends State<WishlistListView>
    with AutomaticKeepAliveClientMixin {
  final Set<int> _selectedItems = {};

  late ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void didUpdateWidget(covariant WishlistListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Ketika keluar dari mode selection,
    // bersihkan semua item yang pernah dipilih.
    if (oldWidget.isSelectionMode && !widget.isSelectionMode) {
      if (_selectedItems.isNotEmpty) {
        setState(() {
          _selectedItems.clear();
        });
      }
    }

    // Bersihkan selected id yang sudah tidak ada di list.
    if (widget.isSelectionMode) {
      final availableIds = widget.wishlistItems
          .map((item) => item.item.id)
          .toSet();

      final hasInvalidItem = _selectedItems.any(
        (id) => !availableIds.contains(id),
      );

      if (hasInvalidItem) {
        setState(() {
          _selectedItems.removeWhere((id) => !availableIds.contains(id));
        });
      }
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isSelectionMode) _buildBulkActionBar(),

        Expanded(
          child: ListView.separated(
            controller: _scrollController,

            // Sama rata dengan layout Customer/Wishlist.
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),

            itemCount:
                widget.wishlistItems.length + (widget.isLoadingMore ? 1 : 0),

            separatorBuilder: (_, __) => const SizedBox(height: 2),

            itemBuilder: (context, index) {
              if (index == widget.wishlistItems.length &&
                  widget.isLoadingMore) {
                return _buildLoadingIndicator();
              }

              final item = widget.wishlistItems[index].item;

              return WishlistItemCard(
                key: ValueKey('wishlist_${item.id}'),
                userId: widget.userId,
                productCode: item.itemCode,
                productId: item.id,
                productName: item.itemName,
                imagePath: item.image,
                categoryName: item.category?.name ?? '',
                uom: item.uom,
                isSelectionMode: widget.isSelectionMode,
                isSelected: _selectedItems.contains(item.id),
                onSelectionChanged: (isSelected) {
                  _toggleSelection(item.id, isSelected);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionBar() {
    final allSelected =
        widget.wishlistItems.isNotEmpty &&
        widget.wishlistItems.every(
          (item) => _selectedItems.contains(item.item.id),
        );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.82,
            child: Checkbox(
              value: allSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    for (final item in widget.wishlistItems) {
                      _selectedItems.add(item.item.id);
                    }
                  } else {
                    _selectedItems.clear();
                  }
                });
              },
              activeColor: AppColors.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),

          const SizedBox(width: 2),

          const Text(
            'Pilih Semua',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.primaryFont,
            ),
          ),

          if (_selectedItems.isNotEmpty) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_selectedItems.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
            ),
          ],

          const Spacer(),

          SizedBox(
            height: 30,
            child: ElevatedButton.icon(
              onPressed: _selectedItems.isEmpty
                  ? null
                  : _showBulkDeleteConfirmation,
              icon: const Icon(Icons.delete_outline_rounded, size: 14),
              label: const Text(
                'Hapus',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                disabledForegroundColor: const Color(0xFF94A3B8),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  void _toggleSelection(int productId, bool isSelected) {
    if (!mounted) return;

    setState(() {
      if (isSelected) {
        _selectedItems.add(productId);
      } else {
        _selectedItems.remove(productId);
      }
    });
  }

  void _showBulkDeleteConfirmation() {
    final selectedCount = _selectedItems.length;

    if (selectedCount == 0) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 26,
                    color: AppColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Hapus $selectedCount Item?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Item yang dipilih akan dihapus dari wishlist Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFonts.primaryFont,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final itemsToDelete = _selectedItems.toList();

                          context.read<WishlistBloc>().add(
                            BulkDeleteWishlistItems(
                              userId: widget.userId,
                              productIds: itemsToDelete,
                            ),
                          );

                          Navigator.pop(dialogContext);

                          setState(() {
                            _selectedItems.clear();
                          });

                          widget.onExitSelectionMode?.call();

                          AppSnackbar.showRaw(
                            context,
                            SnackBar(
                              content: Text(
                                '$selectedCount item dihapus dari wishlist',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: const Color(0xFF16A34A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
