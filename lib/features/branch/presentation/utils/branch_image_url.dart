import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';

String branchImageUrl(Branch branch) {
  final image = branch.image?.trim() ?? '';
  if (image.isNotEmpty) return ApiConfig.getImageUrl(image);

  final seedSource = branch.city?.trim().isNotEmpty == true
      ? branch.city!
      : branch.branchName;
  final seed = seedSource.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '-',
  );
  return Uri.https(
    'via.placeholder.com',
    '/photo/office-building/800x450.webp',
    {'seed': seed.isEmpty ? '${branch.id}' : '$seed-${branch.id}'},
  ).toString();
}
