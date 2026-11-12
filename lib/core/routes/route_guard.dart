import 'package:ekaplus_ekatunggal/core/config/feature_flags.dart';

String? resolveAppRedirect({
  required String path,
  required bool sessionResolved,
  required bool authenticated,
}) {
  if (FeatureFlags.isHiddenProductPath(path)) return '/';

  final normalizedPath =
      Uri.tryParse(path)?.path.toLowerCase() ?? path.toLowerCase();
  final isCustomerPath =
      normalizedPath == '/customer' || normalizedPath.startsWith('/customer/');
  if (isCustomerPath && sessionResolved && !authenticated) return '/login';

  return null;
}
