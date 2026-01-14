/// API Configuration for Eka Tunggal App
///
/// Centralized API endpoints and base URL configuration
class ApiConfig {
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Base URL - Ganti sesuai dengan server Anda
  static const String baseUrl = 'https://api-ekaplus.ekatunggal.com';
  static const String baseImageUrl = 'https://api-ekaplus.ekatunggal.com/files';

  // Development/Production toggle
  static const bool isDevelopment = true;

  // Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API Endpoints
  static String get categories => '$baseUrl/categories/get_all.php';
  static String get categoriesById => '$baseUrl/categories/get_by_id.php';

  static String get itemTypes => '$baseUrl/item_types/get_all.php';
  static String get itemTypesById => '$baseUrl/item_types/get_by_id.php';

  static String get items => '$baseUrl/items/get_all.php';
  static String get itemsById => '$baseUrl/items/get_by_id.php';

  static String get itemVariants => '$baseUrl/item_variants/get_all.php';
  static String get itemVariantsById => '$baseUrl/item_variants/get_by_id.php';

  static String get branches => '$baseUrl/branches/get_all.php';
  static String get branchesById => '$baseUrl/branches/get_by_id.php';

  static String get users => '$baseUrl/users/get_all.php';
  static String get usersById => '$baseUrl/users/get_by_id.php';

  /// Get full URL for any endpoint
  static String getUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$baseUrl/$endpoint';
  }

  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    // Remove leading slash if exists
    final path = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;
    return '$baseImageUrl/$path';
  }
}
