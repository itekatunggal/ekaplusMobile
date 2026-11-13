import 'package:ekaplus_ekatunggal/features/banner/data/models/banner_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BannerModel.fromJson', () {
    test('memetakan banner URL dari API dan mengaktifkan CTA', () {
      final banner = BannerModel.fromJson(const {
        'banner_name': 'produk',
        'image': '34b1c63c-d1af-42f2-9a10-85c3e8d704d3',
        'disabled': 0,
        'type': 'url',
        'type_value': 'https://www.ekatunggal.com/',
      });

      expect(banner.type, 'url');
      expect(banner.typeValue, 'https://www.ekatunggal.com/');
      expect(banner.hasAction, isTrue);
    });

    test('menormalkan tipe internal route', () {
      final banner = BannerModel.fromJson(const {
        'banner_name': 'produk',
        'image': 'image-id',
        'disabled': 0,
        'type': ' INTERNAL_ROUTE ',
        'type_value': ' productPage ',
      });

      expect(banner.type, 'internal_route');
      expect(banner.typeValue, 'productPage');
      expect(banner.hasAction, isTrue);
    });

    test('banner non tidak memiliki aksi', () {
      final banner = BannerModel.fromJson(const {
        'banner_name': 'informasi',
        'image': 'image-id',
        'disabled': 0,
        'type': 'non',
        'type_value': '',
      });

      expect(banner.hasAction, isFalse);
    });
  });
}
