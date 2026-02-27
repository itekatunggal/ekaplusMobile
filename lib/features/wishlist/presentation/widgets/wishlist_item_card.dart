// lib/features/wishlist/presentation/widgets/wishlist_item_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/whatsapp_helper.dart';
import 'package:ekaplus_ekatunggal/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:ekaplus_ekatunggal/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class WishlistItemCard extends StatefulWidget {
  final int userId;
  final int productId;
  final String productCode;
  final String productName;
  final String imagePath;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const WishlistItemCard({
    super.key,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.imagePath,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  State<WishlistItemCard> createState() => _WishlistItemCardState();
}

class _WishlistItemCardState extends State<WishlistItemCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToProductDetail() async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final datasource = myinjection<ProductRemoteDatasource>();
      final products = await datasource.getAllProduct(
        filters: [
          ["variants.item", "=", widget.productId],
        ],
        limit: 1,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (products.isNotEmpty) {
        final product = products.first;

        await context.pushNamed(
          'productDetail',
          pathParameters: {'id': product.id.toString()},
        );

        if (mounted) {
          setState(() {});
        }
      } else {
        if (!mounted) return;
        _showProductNotFoundDialog(context);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      AppSnackbar.showRaw(context, 
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Gagal memuat produk',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  void _showProductNotFoundDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        insetPadding: EdgeInsets.symmetric(horizontal: isSmall ? 20 : 28),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(isSmall ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon dengan design lebih subtle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 32,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Produk Belum Tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 16 : 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.grey.shade900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                'Informasi detail untuk produk ini sedang dalam proses pembaruan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 12.5 : 13.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFonts.secondaryFont,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),

              // Product name badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.label_outline,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        widget.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmall ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.primaryFont,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmall ? 20 : 24),

              // CTA Section
              Column(
                children: [
                  // WhatsApp Button - Professional Design
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(c);
                          WhatsAppHelper.openProduct(
                            context,
                            widget.productName,
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // WhatsApp Icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF25D366),
                                      Color(0xFF128C7E),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF25D366,
                                      ).withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Text Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hubungi via WhatsApp',
                                      style: TextStyle(
                                        fontSize: isSmall ? 13 : 14,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: AppFonts.primaryFont,
                                        color: Colors.grey.shade900,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Dapatkan info lengkap produk',
                                      style: TextStyle(
                                        fontSize: isSmall ? 10.5 : 11.5,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: AppFonts.secondaryFont,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow Icon
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(c),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Kembali',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isSmall ? 13 : 14,
                          fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final textScaler = media.textScaler.clamp(
      minScaleFactor: 0.9,
      maxScaleFactor: 1.0,
    );

    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    final imageSize = isSmallScreen ? 80.0 : (isMediumScreen ? 90.0 : 100.0);
    final verticalMargin = isSmallScreen ? 5.0 : 6.0;
    final horizontalPadding = isSmallScreen
        ? 10.0
        : (isMediumScreen ? 12.0 : 14.0);
    final verticalPadding = isSmallScreen ? 10.0 : 12.0;
    final spacing = isSmallScreen ? 10.0 : 12.0;

    return MediaQuery(
      data: media.copyWith(textScaler: textScaler),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: GestureDetector(
          onTapDown: (_) {
            if (mounted) _controller.forward();
          },
          onTapUp: (_) {
            if (mounted) _controller.reverse();
            if (widget.isSelectionMode) {
              widget.onSelectionChanged?.call(!widget.isSelected);
            }
          },
          onTapCancel: () {
            if (mounted) _controller.reverse();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(
              vertical: verticalMargin,
              horizontal: 4,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.12),
                        AppColors.primaryColor.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primaryColor
                    : Colors.grey.shade200,
                width: widget.isSelected ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? AppColors.primaryColor.withOpacity(0.12)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: widget.isSelected ? 10 : 6,
                  offset: Offset(0, widget.isSelected ? 3 : 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isSelectionMode) ...[
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: imageSize,
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: 0.8,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? AppColors.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: widget.isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: widget.isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 5 : 7),
                ],
                _buildProductImage(context, imageSize, isSmallScreen),
                SizedBox(width: spacing),
                Expanded(
                  child: _buildProductInfo(
                    context,
                    isSmallScreen,
                    isMediumScreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, double size, bool isSmall) {
    return Hero(
      tag: 'product_${widget.productId}',
      child: GestureDetector(
        onTap: widget.isSelectionMode ? null : _navigateToProductDetail,
        child: Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade100, Colors.grey.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.imagePath.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl:
                                "${ApiConfig.baseImageUrl}/${widget.imagePath}?format=rs:fill:300:300/q:80/ext:webp",
                            fit: BoxFit.cover,
                            width: size,
                            height: size,
                            placeholder: (_, __) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (_, __, ___) => Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: size * 0.3,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.image_rounded,
                              size: size * 0.35,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, bool isSmall, bool isMedium) {
    final codeSize = isSmall ? 9.5 : 10.5;
    final nameSize = isSmall ? 12.0 : 12.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            widget.productCode,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: codeSize,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
              fontFamily: AppFonts.secondaryFont,
              letterSpacing: 0.2,
            ),
          ),
        ),
        SizedBox(height: isSmall ? 5 : 6),
        Text(
          widget.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: nameSize,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
            fontFamily: AppFonts.primaryFont,
            height: 1.3,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: isSmall ? 8 : 10),
        if (!widget.isSelectionMode) _buildActionButtons(context, isSmall),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isSmall) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 350;

    final buttonPadding = isVerySmall ? 7.0 : (isSmall ? 8.0 : 9.0);
    final fontSize = isVerySmall ? 9.5 : (isSmall ? 10.5 : 11.5);
    final spacing = isVerySmall ? 5.0 : (isSmall ? 7.0 : 8.0);
    final iconSize = isVerySmall ? 13.0 : (isSmall ? 14.0 : 15.0);
    final horizontalPadding = isVerySmall ? 2.0 : (isSmall ? 6.0 : 10.0);

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: OutlinedButton(
              onPressed: () => _showDeleteConfirmation(context),
              style:
                  OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: buttonPadding,
                      horizontal: horizontalPadding,
                    ),
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade200, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(Colors.red.shade50),
                  ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, size: iconSize),
                  SizedBox(width: isVerySmall ? 2 : 3),
                  Flexible(
                    child: Text(
                      'Hapus',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.primaryFont,
                        letterSpacing: isVerySmall ? -0.3 : 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppColors.secondaryColor,
                  AppColors.secondaryColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryColor.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _showInfoDialog(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: buttonPadding,
                  horizontal: horizontalPadding,
                ),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black87,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: iconSize),
                  SizedBox(width: isVerySmall ? 2 : 3),
                  Flexible(
                    child: Text(
                      'Info',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.primaryFont,
                        letterSpacing: isVerySmall ? -0.3 : 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        insetPadding: EdgeInsets.symmetric(horizontal: isSmall ? 18 : 28),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(isSmall ? 18 : 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Hapus dari Wishlist?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 15 : 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Produk ini akan dihapus dari daftar wishlist Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 11.5 : 12.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFonts.secondaryFont,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmall ? 18 : 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(c),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : 13,
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
                        context.read<WishlistBloc>().add(
                          ToggleWishlistItem(productId: widget.productId),
                        );
                        Navigator.pop(c);
                        AppSnackbar.showRaw(context, 
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${widget.productName} dihapus dari wishlist',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF25D366),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 12 : 13,
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

  void _showInfoDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        insetPadding: EdgeInsets.symmetric(horizontal: isSmall ? 18 : 28),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.green.shade50.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(isSmall ? 18 : 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.chat, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                'Chat WhatsApp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 15 : 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Tanyakan produk ini langsung via WhatsApp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 11.5 : 12.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFonts.secondaryFont,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmall ? 18 : 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(c),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(c);
                        WhatsAppHelper.openProduct(context, widget.productName);
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(Icons.chat, size: 16),
                      ),
                      label: Text(
                        'Chat Admin',
                        style: TextStyle(
                          fontSize: isSmall ? 11.5 : 12.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0xFF25D366).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
