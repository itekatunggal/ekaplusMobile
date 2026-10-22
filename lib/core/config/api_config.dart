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
  static const String baseTransaksiUrl = 'https://etm-bogor.ekatunggal.com';

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

  // API Endpoints - Transaksi
  static String get transaksi => '$baseTransaksiUrl/transaksi/get_all.php';
  static String get transaksiById => '$baseTransaksiUrl/transaksi/get_by_id.php';

  // Get full URL for any endpoint
  static String getUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$baseUrl/$endpoint';
  }

  // Get full URL specifically for transaksi endpoints
  static String getTransaksiUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$baseTransaksiUrl/$endpoint';
  }

  static String getImageUrl(String? path, {String? format}) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }

    final normalizedPath = path.trim();
    final url =
        normalizedPath.startsWith('http://') ||
            normalizedPath.startsWith('https://')
        ? normalizedPath
        : '$baseImageUrl/${normalizedPath.replaceFirst(RegExp(r'^/+'), '')}';
    final formattedUrl = format == null || format.isEmpty
        ? url
        : '$url${url.contains('?') ? '&' : '?'}format=$format';

    return addImageUpdatedAt(formattedUrl);
  }

  /// Adds a daily cache version to images served by the EKAPLUS files API.
  static String addImageUpdatedAt(String url, {DateTime? date}) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.host.toLowerCase() != 'api-ekaplus.ekatunggal.com' ||
        !uri.path.startsWith('/files/')) {
      return url;
    }

    final currentDate = date ?? DateTime.now();
    final year = currentDate.year.toString().padLeft(4, '0');
    final month = currentDate.month.toString().padLeft(2, '0');
    final day = currentDate.day.toString().padLeft(2, '0');
    final updatedAt = '$year-$month-$day';
    final existingUpdatedAt = RegExp(r'([?&])updated_at=[^&]*');
    if (existingUpdatedAt.hasMatch(url)) {
      return url.replaceFirstMapped(
        existingUpdatedAt,
        (match) => '${match.group(1)}updated_at=$updatedAt',
      );
    }
    final separator = url.contains('?') ? '&' : '?';

    return '$url${url.endsWith('?') || url.endsWith('&') ? '' : separator}'
        'updated_at=$updatedAt';
  }
}
