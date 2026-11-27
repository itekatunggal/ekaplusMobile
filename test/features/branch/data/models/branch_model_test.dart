import 'package:ekaplus_ekatunggal/features/branch/data/models/branch_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BranchModel.fromJson', () {
    test('maps image and phone from the API response', () {
      final branch = BranchModel.fromJson({
        'id': 12,
        'branch_name': 'Ekatunggal Bogor',
        'image': '/branches/bogor.webp',
        'phone': '0251 123456',
      });

      expect(branch.image, '/branches/bogor.webp');
      expect(branch.phone, '0251 123456');
    });

    test('keeps empty image and phone values nullable', () {
      final branch = BranchModel.fromJson({
        'id': 12,
        'branch_name': 'Ekatunggal Bogor',
        'image': null,
        'phone': '   ',
      });

      expect(branch.image, isNull);
      expect(branch.phone, isNull);
    });
  });
}
