/// Central switch for features that are temporarily unavailable.
///
/// Product code stays intact so it can be enabled again when the catalog is
/// ready, without restoring deleted routes or widgets.
abstract final class FeatureFlags {
  static const bool showProductCatalog = false;
  static const bool showProductCategories = false;
  static const bool showWishlist = false;
  static const bool showProductSearch = false;
  static const bool showHomeLoyalty = true;
  static const bool showBranchDirectory = true;
  static const bool showSalesDirectory = true;
  static const bool showPromotions = true;
  static const bool showArticles = true;
  static const bool useDummySales = true;
  static const bool useDummyPromotions = true;
  static const bool useDummyArticles = true;

  static bool isHiddenProductRouteName(String routeName) {
    return switch (routeName) {
      'search' => !showProductSearch,
      'category' || 'categoryDetail' => !showProductCategories,
      'wishlist' => !showWishlist,
      'productPage' ||
      'productDetail' ||
      'productsHighlight' => !showProductCatalog,
      _ => false,
    };
  }

  static bool isHiddenProductPath(String path) {
    final normalizedPath =
        Uri.tryParse(path)?.path.toLowerCase() ?? path.toLowerCase();
    if (!showProductSearch && normalizedPath == '/search') return true;
    if (!showWishlist && normalizedPath == '/wishlist') return true;
    if (!showProductCategories &&
        (normalizedPath == '/category' ||
            normalizedPath.startsWith('/category/'))) {
      return true;
    }
    if (!showProductCatalog &&
        (normalizedPath == '/products' ||
            normalizedPath.startsWith('/products/') ||
            normalizedPath == '/products-highlight' ||
            normalizedPath.startsWith('/product/'))) {
      return true;
    }
    return false;
  }
}
