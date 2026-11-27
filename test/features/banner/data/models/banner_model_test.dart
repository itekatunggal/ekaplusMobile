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
        'sort_by': 5,
        'show_button': 1,
        'button_display': 'Lihat promo',
      });

      expect(banner.type, 'url');
      expect(banner.typeValue, 'https://www.ekatunggal.com/');
      expect(banner.hasAction, isTrue);
      expect(banner.sortBy, 5);
      expect(banner.showButton, isTrue);
      expect(banner.buttonLabel, 'Lihat promo');
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

    test('menggunakan label CTA default saat button_display kosong', () {
      final banner = BannerModel.fromJson(const {
        'banner_name': 'promo',
        'image': 'image-id',
        'disabled': 0,
        'type': 'url',
        'type_value': 'https://www.ekatunggal.com/',
        'show_button': 1,
        'button_display': '  ',
      });

      expect(banner.shouldShowButton, isTrue);
      expect(banner.buttonLabel, 'Selengkapnya');
    });

    test('menggunakan label CTA default saat show_button tidak aktif', () {
      final banner = BannerModel.fromJson(const {
        'banner_name': 'promo',
        'image': 'image-id',
        'disabled': 0,
        'type': 'internal_route',
        'type_value': 'promotion',
        'show_button': 0,
        'button_display': 'Lihat Promo',
      });

      expect(banner.shouldShowButton, isTrue);
      expect(banner.buttonLabel, 'Selengkapnya');
    });

    test('mengurutkan daftar banner berdasarkan sort_by terkecil', () {
      final banners = BannerModel.fromJsonList(const [
        {'banner_name': 'Ketiga', 'sort_by': 30},
        {'banner_name': 'Pertama', 'sort_by': '10'},
        {'banner_name': 'Kedua', 'sort_by': 20},
      ]);

      expect(banners.map((banner) => banner.name), [
        'Pertama',
        'Kedua',
        'Ketiga',
      ]);
    });
  });
}
