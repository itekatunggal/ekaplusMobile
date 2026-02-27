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

  const WishlistListView({
    super.key,
    required this.userId,
    required this.wishlistItems,
    this.scrollController,
    this.isLoadingMore = false,
  });

  @override
  State<WishlistListView> createState() => _WishlistListViewState();
}

class _WishlistListViewState extends State<WishlistListView>
    with AutomaticKeepAliveClientMixin {
  bool _isSelectionMode = false;
  final Set<int> _selectedItems = {};

  late ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        if (_isSelectionMode) _buildBulkActionBar(),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount:
                widget.wishlistItems.length + (widget.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == widget.wishlistItems.length &&
                  widget.isLoadingMore) {
                return _buildLoadingIndicator();
              }

              final item = widget.wishlistItems[index].item;

              return WishlistItemCard(
                key: ValueKey(
                  'wishlist_${item.id}',
                ), // Add key for state preservation
                userId: widget.userId,
                productCode: item.itemCode,
                productId: item.id,
                productName: item.itemName,
                imagePath: item.image,
                isSelectionMode: _isSelectionMode,
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _isSelectionMode ? '${_selectedItems.length} dipilih' : '',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.primaryFont,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () {
              if (mounted) {
                setState(() {
                  if (_isSelectionMode) {
                    _isSelectionMode = false;
                    _selectedItems.clear();
                  } else {
                    _isSelectionMode = true;
                  }
                });
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isSelectionMode ? 'Batal' : 'Pilih',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.primaryFont,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.85,
            child: Checkbox(
              value:
                  widget.wishlistItems.isNotEmpty &&
                  widget.wishlistItems.every(
                    (e) => _selectedItems.contains(e.item.id),
                  ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    if (value == true) {
                      for (var item in widget.wishlistItems) {
                        _selectedItems.add(item.item.id);
                      }
                    } else {
                      _selectedItems.clear();
                    }
                  });
                }
              },
              activeColor: AppColors.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 3),
          const Text(
            'Pilih Semua',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _selectedItems.isEmpty
                ? null
                : () => _showBulkDeleteConfirmation(),
            icon: const Icon(Icons.delete_outline, size: 14),
            label: const Text('Hapus', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.whiteColor,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              minimumSize: const Size(0, 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Memuat lebih banyak...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(int productId, bool isSelected) {
    if (mounted) {
      setState(() {
        if (isSelected) {
          _selectedItems.add(productId);
        } else {
          _selectedItems.remove(productId);
        }
      });
    }
  }

  void _showBulkDeleteConfirmation() {
    final selectedCount = _selectedItems.length;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 42,
                color: Colors.orange,
              ),
              const SizedBox(height: 14),
              Text(
                'Hapus $selectedCount Item?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: AppFonts.primaryFont,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Apakah Anda yakin ingin menghapus item yang dipilih dari wishlist?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
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

                        if (mounted) {
                          context.read<WishlistBloc>().add(
                            BulkDeleteWishlistItems(
                              userId: widget.userId,
                              productIds: itemsToDelete,
                            ),
                          );
                        }

                        Navigator.pop(dialogContext);

                        if (mounted) {
                          AppSnackbar.showRaw(context, 
                            SnackBar(
                              content: Text(
                                '$selectedCount item dihapus dari wishlist',
                                style: const TextStyle(fontSize: 13),
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          setState(() {
                            _isSelectionMode = false;
                            _selectedItems.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        backgroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 13,
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
      ),
    );
  }
}
