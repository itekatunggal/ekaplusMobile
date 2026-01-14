// lib/features/product/presentation/pages/product_detail_page.dart

// ignore_for_file: unused_element, unused_element_parameter

import 'dart:async';
import 'dart:io' as io;
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';

// ==================== CONSTANTS ====================
class _ProductDetailConstants {
  static const double mainImageHeight = 350.0;
  static const double thumbnailHeight = 80.0;
  static const double thumbnailSize = 60.0;
  static const double thumbnailMargin = 10.0;
  static const int autoSlideDurationSeconds = 4;
  static const Duration animationDuration = Duration(milliseconds: 400);
  // static const Duration imageTransitionDuration = Duration(milliseconds: 300);
  static const double floatingButtonSize = 40.0;
}

// ==================== MAIN PAGE ====================
class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedVariantIndex = 0;
  Timer? _autoSlideTimer;
  final ScrollController _thumbnailScrollController = ScrollController();
  late PageController _pageController;

  late ProductBloc _productBloc;
  late WishlistBloc _wishlistBloc;

  Product? _currentProduct;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initializeBlocs();
    _resetState();
    _loadProductDetail();
  }

  @override
  void didUpdateWidget(ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _resetState();
      _loadProductDetail();
    }
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _initializeBlocs() {
    _productBloc = context.read<ProductBloc>();
    _wishlistBloc = context.read<WishlistBloc>();
  }

  void _loadProductDetail() {
    _productBloc.add(ProductEventGetDetail(widget.productId));
  }

  void _resetState() {
    _selectedVariantIndex = 0;
    _currentProduct = null;
    _autoSlideTimer?.cancel();
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _cleanupResources() {
    _autoSlideTimer?.cancel();
    _thumbnailScrollController.dispose();
    _pageController.dispose();
  }

  void _startAutoSlide(int variantsLength) {
    if (variantsLength <= 1) return;

    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(
      const Duration(seconds: _ProductDetailConstants.autoSlideDurationSeconds),
      (timer) {
        if (mounted && _currentProduct != null) {
          final nextIndex = (_selectedVariantIndex + 1) % variantsLength;
          _animateToPage(nextIndex, variantsLength);
        }
      },
    );
  }

  void _animateToPage(int index, int variantsLength) {
    if (_currentProduct == null || index < 0 || index >= variantsLength) return;

    _pageController.animateToPage(
      index,
      duration: _ProductDetailConstants.animationDuration,
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    if (_currentProduct == null) return;

    setState(() {
      _selectedVariantIndex = index;
    });

    _checkWishlistStatus(_currentProduct!.variants[index].id);
    _scrollToSelectedThumbnail(index);
    _startAutoSlide(_currentProduct!.variants.length);
  }

  void _selectVariantByIndex(int index, int variantsLength) {
    if (_currentProduct == null || index < 0 || index >= variantsLength) return;

    _animateToPage(index, variantsLength);
    _startAutoSlide(variantsLength);
  }

  void _checkWishlistStatus(int productId) {
    _wishlistBloc.add(CheckWishlistStatus(productId: productId));
  }

  void _scrollToSelectedThumbnail(int index) {
    if (!_thumbnailScrollController.hasClients) return;

    final itemWidth =
        _ProductDetailConstants.thumbnailSize +
        _ProductDetailConstants.thumbnailMargin;
    final screenWidth = MediaQuery.of(context).size.width;
    final centerOffset = (screenWidth / 2) - (itemWidth / 2);
    final targetScroll = (index * itemWidth) - centerOffset;

    final maxScroll = _thumbnailScrollController.position.maxScrollExtent;
    final minScroll = _thumbnailScrollController.position.minScrollExtent;
    final finalScroll = targetScroll.clamp(minScroll, maxScroll);

    _thumbnailScrollController.animateTo(
      finalScroll,
      duration: _ProductDetailConstants.animationDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<ProductBloc, ProductState>(
          bloc: _productBloc,
          buildWhen: (previous, current) {
            return current is ProductDetailLoading ||
                current is ProductError ||
                current is ProductDetailLoaded;
          },
          builder: (context, state) {
            if (state is ProductDetailLoading) {
              return const _LoadingShimmer();
            }

            if (state is ProductError) {
              return _ErrorView(
                message: state.message,
                onRetry: _loadProductDetail,
              );
            }

            if (state is ProductDetailLoaded) {
              if (state.product.variants.isEmpty) {
                return const _EmptyView(message: 'Tidak ada varian tersedia');
              }
              return _buildProductContent(state.product);
            }

            return _EmptyView(
              message: 'Data tidak tersedia',
              onRetry: _loadProductDetail,
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductContent(Product product) {
    _currentProduct = product;

    if (_selectedVariantIndex >= product.variants.length) {
      _selectedVariantIndex = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkWishlistStatus(product.variants[_selectedVariantIndex].id);
        _startAutoSlide(product.variants.length);
        _scrollToSelectedThumbnail(_selectedVariantIndex);
      }
    });

    final selectedVariant = product.variants[_selectedVariantIndex];

    return RefreshIndicator(
      onRefresh: () async {
        _resetState();
        _productBloc.add(ProductEventGetDetail(widget.productId));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primaryColor,
      edgeOffset: MediaQuery.of(context).padding.top + 60,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Swipeable Full Image Section
            _SwipeableImageSection(
              variants: product.variants,
              selectedIndex: _selectedVariantIndex,
              pageController: _pageController,
              wishlistBloc: _wishlistBloc,
              onPageChanged: _onPageChanged,
              onBackPressed: () => Navigator.pop(context),
            ),

            // Content Card yang overlap dengan gambar
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Thumbnail Gallery
                    if (product.variants.length > 1)
                      _ThumbnailGallery(
                        variants: product.variants,
                        selectedIndex: _selectedVariantIndex,
                        scrollController: _thumbnailScrollController,
                        onVariantSelected: (index) {
                          _selectVariantByIndex(index, product.variants.length);
                        },
                      ),
                    if (product.variants.length > 1) const SizedBox(height: 20),

                    // Product Info Section
                    _ProductInfoSection(
                      variant: selectedVariant,
                      product: product,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SWIPEABLE IMAGE SECTION ====================
class _SwipeableImageSection extends StatelessWidget {
  final List<dynamic> variants;
  final int selectedIndex;
  final PageController pageController;
  final WishlistBloc wishlistBloc;
  final Function(int) onPageChanged;
  final VoidCallback onBackPressed;

  const _SwipeableImageSection({
    required this.variants,
    required this.selectedIndex,
    required this.pageController,
    required this.wishlistBloc,
    required this.onPageChanged,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final imageHeight = _ProductDetailConstants.mainImageHeight + topPadding;
    final currentVariant = variants[selectedIndex];

    return SizedBox(
      height: imageHeight,
      child: Stack(
        children: [
          // Swipeable PageView untuk gambar
          PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: variants.length,
            itemBuilder: (context, index) {
              return _ImagePage(
                variant: variants[index],
                onTap: () => _openZoomableImage(context, index),
              );
            },
          ),

          // Gradient Overlay untuk visibility tombol
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: topPadding + 8,
            left: 16,
            child: _FloatingCircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBackPressed,
            ),
          ),

          // Wishlist Button
          Positioned(
            top: topPadding + 8,
            right: 16,
            child: _WishlistButton(
              key: ValueKey('wishlist_${currentVariant.id}'),
              variant: currentVariant,
              wishlistBloc: wishlistBloc,
            ),
          ),

          // Zoom Hint
          Positioned(bottom: 40, right: 16, child: _ZoomHintBadge()),
        ],
      ),
    );
  }

  void _openZoomableImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenGalleryViewer(
              variants: variants,
              initialIndex: initialIndex,
            ),
          );
        },
      ),
    );
  }
}

// ==================== FULL SCREEN GALLERY VIEWER ====================
class _FullScreenGalleryViewer extends StatefulWidget {
  final List<dynamic> variants;
  final int initialIndex;

  const _FullScreenGalleryViewer({
    required this.variants,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGalleryViewer> createState() =>
      _FullScreenGalleryViewerState();
}

class _FullScreenGalleryViewerState extends State<_FullScreenGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  final ScrollController _thumbnailScrollController = ScrollController();

  // Track zoom state
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedThumbnail(_currentIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _scrollToSelectedThumbnail(index);
  }

  void _selectVariant(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToSelectedThumbnail(int index) {
    if (!_thumbnailScrollController.hasClients) return;

    const itemWidth = 56.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final centerOffset = (screenWidth / 2) - (itemWidth / 2);
    final targetScroll = (index * itemWidth) - centerOffset;

    final maxScroll = _thumbnailScrollController.position.maxScrollExtent;
    final minScroll = _thumbnailScrollController.position.minScrollExtent;
    final finalScroll = targetScroll.clamp(minScroll, maxScroll);

    _thumbnailScrollController.animateTo(
      finalScroll,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Handle zoom scale changes
  void _onScaleChanged(PhotoViewScaleState scaleState) {
    final isNowZoomed = scaleState != PhotoViewScaleState.initial;
    if (_isZoomed != isNowZoomed) {
      setState(() {
        _isZoomed = isNowZoomed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swipeable Zoomable Images
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            // Disable swipe when zoomed
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: widget.variants.length,
            itemBuilder: (context, index) {
              final variant = widget.variants[index];
              final imageUrl = "${ApiConfig.baseImageUrl}/${variant.image}";

              return PhotoView(
                imageProvider: CachedNetworkImageProvider(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                initialScale: PhotoViewComputedScale.contained,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                // Listen to scale changes
                scaleStateChangedCallback: _onScaleChanged,
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.white54,
                    size: 80,
                  ),
                ),
              );
            },
          ),

          // Close Button - Always visible
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // // Page Counter - Hide when zoomed
          // AnimatedOpacity(
          //   opacity: _isZoomed ? 0.0 : 1.0,
          //   duration: const Duration(milliseconds: 200),
          //   child: SafeArea(
          //     child: Align(
          //       alignment: Alignment.topCenter,
          //       child: Padding(
          //         padding: const EdgeInsets.all(16.0),
          //         child: Container(
          //           padding: const EdgeInsets.symmetric(
          //             horizontal: 16,
          //             vertical: 8,
          //           ),
          //           decoration: BoxDecoration(
          //             color: Colors.black.withOpacity(0.6),
          //             borderRadius: BorderRadius.circular(20),
          //           ),
          //           child: Text(
          //             '${_currentIndex + 1} / ${widget.variants.length}',
          //             style: const TextStyle(
          //               color: Colors.white,
          //               fontSize: 14,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // Bottom Thumbnail Gallery - Hide when zoomed
          if (widget.variants.length > 1)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: _isZoomed ? -100 : 0, // Slide down when zoomed
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _isZoomed ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 16),
                      child: SizedBox(
                        height: 56,
                        child: ListView.builder(
                          controller: _thumbnailScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: widget.variants.length,
                          itemBuilder: (context, index) {
                            return _FullScreenThumbnailItem(
                              variant: widget.variants[index],
                              isSelected: index == _currentIndex,
                              onTap: () => _selectVariant(index),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== FULL SCREEN THUMBNAIL ITEM ====================
class _FullScreenThumbnailItem extends StatelessWidget {
  final dynamic variant;
  final bool isSelected;
  final VoidCallback onTap;

  const _FullScreenThumbnailItem({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (variant.image.isEmpty) {
      return Container(
        color: Colors.grey.shade800,
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade600,
          size: 20,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: "${ApiConfig.baseImageUrl}/${variant.image}",
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade800,
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: Colors.white54,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade800,
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade600,
          size: 20,
        ),
      ),
    );
  }
}

// ==================== IMAGE PAGE (Single Image in PageView) ====================
class _ImagePage extends StatelessWidget {
  final dynamic variant;
  final VoidCallback onTap;

  const _ImagePage({required this.variant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'product_image_${variant.id}',
        child: Container(
          color: Colors.grey.shade100,
          child: _buildImageWidget(),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (variant.image.isEmpty) {
      return Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: Colors.grey.shade300,
        ),
      );
    }

    return CachedNetworkImage(
      key: ValueKey<int>(variant.id),
      imageUrl: "${ApiConfig.baseImageUrl}/${variant.image}",
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Container(color: Colors.grey.shade100),
      ),
      errorWidget: (context, url, error) => Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}

// ==================== PAGE INDICATOR (Dots) ====================
class _PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const _PageIndicator({required this.itemCount, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ==================== FLOATING CIRCLE BUTTON ====================
class _FloatingCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const _FloatingCircleButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _ProductDetailConstants.floatingButtonSize,
        height: _ProductDetailConstants.floatingButtonSize,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.black87),
      ),
    );
  }
}

// ==================== ZOOM HINT BADGE ====================
class _ZoomHintBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.zoom_in_rounded,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 4),
          Text(
            'Tap to zoom',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isIOS ? 11 : 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== WISHLIST BUTTON ====================
class _WishlistButton extends StatelessWidget {
  final dynamic variant;
  final WishlistBloc wishlistBloc;

  const _WishlistButton({
    super.key,
    required this.variant,
    required this.wishlistBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, authState) {
        if (authState is! AuthSessionAuthenticated) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<WishlistBloc, WishlistState>(
          bloc: wishlistBloc,
          builder: (context, wishlistState) {
            final isInWishlist =
                wishlistState is WishListStatus && wishlistState.status;

            if (wishlistState is WishlistError) {
              return const SizedBox.shrink();
            }

            return _buildButton(context, isInWishlist);
          },
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, bool isInWishlist) {
    return GestureDetector(
      onTap: () => _handleWishlistToggle(context, isInWishlist),
      child: Container(
        width: _ProductDetailConstants.floatingButtonSize,
        height: _ProductDetailConstants.floatingButtonSize,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isInWishlist ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: isInWishlist ? Colors.red : Colors.grey.shade600,
        ),
      ),
    );
  }

  void _handleWishlistToggle(BuildContext context, bool isInWishlist) {
    wishlistBloc.add(ToggleWishlistItem(productId: variant.id));
    _showSnackbar(context, isInWishlist);
  }

  void _showSnackbar(BuildContext context, bool isInWishlist) {
    final bool isIOS = io.Platform.isIOS;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isInWishlist ? 'Dihapus dari wishlist' : 'Ditambahkan ke wishlist',
          style: TextStyle(fontSize: isIOS ? 14 : 12),
        ),
        duration: const Duration(milliseconds: 1000),
        backgroundColor: isInWishlist
            ? Colors.grey.shade700
            : AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ==================== LOADING SHIMMER ====================
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainImageShimmer(topPadding),
          Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildThumbnailShimmer(),
                  const SizedBox(height: 24),
                  _buildInfoShimmer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainImageShimmer(double topPadding) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        width: double.infinity,
        height: _ProductDetailConstants.mainImageHeight + topPadding,
        color: Colors.grey.shade100,
      ),
    );
  }

  Widget _buildThumbnailShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(
            4,
            (index) => Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              2,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ERROR VIEW ====================
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Center(
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
                    Icons.error_outline_rounded,
                    size: 56,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Terjadi Kesalahan',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: isIOS ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isIOS ? 14 : 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
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
                      fontSize: isIOS ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Back button
        Positioned(
          top: topPadding + 8,
          left: 16,
          child: _FloatingCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

// ==================== EMPTY VIEW ====================
class _EmptyView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _EmptyView({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
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
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: isIOS ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Muat Ulang',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: isIOS ? 14 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Back button
        Positioned(
          top: topPadding + 8,
          left: 16,
          child: _FloatingCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

// ==================== THUMBNAIL GALLERY ====================
class _ThumbnailGallery extends StatelessWidget {
  final List<dynamic> variants;
  final int selectedIndex;
  final ScrollController scrollController;
  final Function(int) onVariantSelected;

  const _ThumbnailGallery({
    required this.variants,
    required this.selectedIndex,
    required this.scrollController,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _ProductDetailConstants.thumbnailHeight,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: variants.length,
        itemBuilder: (context, index) {
          return _ThumbnailItem(
            variant: variants[index],
            isSelected: index == selectedIndex,
            onTap: () => onVariantSelected(index),
          );
        },
      ),
    );
  }
}

// ==================== THUMBNAIL ITEM ====================
class _ThumbnailItem extends StatelessWidget {
  final dynamic variant;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThumbnailItem({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _ProductDetailConstants.thumbnailSize,
        height: _ProductDetailConstants.thumbnailSize,
        margin: const EdgeInsets.only(
          right: _ProductDetailConstants.thumbnailMargin,
          top: 10,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (variant.image.isEmpty) {
      return Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 24);
    }

    return CachedNetworkImage(
      imageUrl: "${ApiConfig.baseImageUrl}/${variant.image}",
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Container(color: Colors.grey.shade100),
      ),
      errorWidget: (context, url, error) =>
          Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 24),
    );
  }
}

// ==================== PRODUCT INFO SECTION ====================
class _ProductInfoSection extends StatelessWidget {
  final dynamic variant;
  final Product product;

  const _ProductInfoSection({required this.variant, required this.product});

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hot Deals Badge
          if (product.isHotDeals) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(73, 252, 153, 153),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'BEST SELLER',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: isIOS ? 11 : 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Product Name
          Text(
            variant.name,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: isIOS ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),

          // Category subtitle
          if (product.itemCategory != null) ...[
            const SizedBox(height: 4),
            Text(
              product.itemCategory!.name,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: isIOS ? 14 : 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Info Cards
          _InfoCard(
            icon: Icons.qr_code_rounded,
            iconColor: AppColors.primaryColor,
            label: 'PRODUCT CODE',
            value: variant.code,
          ),

          const SizedBox(height: 12),

          if (product.itemCategory != null)
            _InfoCard(
              icon: Icons.category_rounded,
              iconColor: Colors.orange,
              label: 'CATEGORY',
              value: product.itemCategory!.name,
            ),

          // Description Section
          if (variant.description.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Deskripsi',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: isIOS ? 16 : 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              variant.description,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: isIOS ? 14 : 12,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== INFO CARD ====================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIOS = io.Platform.isIOS;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: isIOS ? 10 : 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: isIOS ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
