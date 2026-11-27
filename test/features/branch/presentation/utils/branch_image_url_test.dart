import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/utils/branch_image_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the API file URL when branch image is available', () {
    const branch = Branch(
      id: 1,
      branchName: 'Bogor',
      image: '/branches/bogor.webp',
    );

    expect(
      branchImageUrl(branch),
      startsWith(
        'https://api-ekaplus.ekatunggal.com/files/branches/bogor.webp',
      ),
    );
  });

  test('uses the existing placeholder when branch image is null', () {
    const branch = Branch(id: 1, branchName: 'Bogor');

    expect(branchImageUrl(branch), startsWith('https://via.placeholder.com/'));
  });
}
