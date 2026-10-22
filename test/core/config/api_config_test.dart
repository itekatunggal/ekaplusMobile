import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiConfig image URL', () {
    final date = DateTime(2026, 10, 22);

    test('adds updated_at to a plain EKAPLUS image URL', () {
      expect(
        ApiConfig.addImageUpdatedAt(
          'https://api-ekaplus.ekatunggal.com/files/abc123.jpg',
          date: date,
        ),
        'https://api-ekaplus.ekatunggal.com/files/abc123.jpg'
        '?updated_at=2026-10-22',
      );
    });

    test('adds updated_at after the image format query', () {
      expect(
        ApiConfig.addImageUpdatedAt(
          'https://api-ekaplus.ekatunggal.com/files/abc123.jpg'
          '?format=rs:fill:300:300/q:80/ext:webp',
          date: date,
        ),
        'https://api-ekaplus.ekatunggal.com/files/abc123.jpg'
        '?format=rs:fill:300:300/q:80/ext:webp&updated_at=2026-10-22',
      );
    });

    test('does not modify images from another host', () {
      expect(
        ApiConfig.addImageUpdatedAt(
          'https://example.com/image.jpg',
          date: date,
        ),
        'https://example.com/image.jpg',
      );
    });

    test('replaces an existing updated_at value', () {
      expect(
        ApiConfig.addImageUpdatedAt(
          'https://api-ekaplus.ekatunggal.com/files/abc123.jpg'
          '?updated_at=2026-10-21',
          date: date,
        ),
        'https://api-ekaplus.ekatunggal.com/files/abc123.jpg'
        '?updated_at=2026-10-22',
      );
    });
  });
}
