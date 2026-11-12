import 'package:ekaplus_ekatunggal/core/config/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureFlags hidden product routes', () {
    test('blocks every product entry point while product flags are off', () {
      const hiddenPaths = [
        '/search',
        '/category',
        '/category/12',
        '/wishlist',
        '/products',
        '/products-highlight',
        '/product/ABC-123',
      ];

      for (final path in hiddenPaths) {
        expect(
          FeatureFlags.isHiddenProductPath(path),
          isTrue,
          reason: '$path must be guarded',
        );
      }
    });

    test('also recognizes product paths in absolute banner links', () {
      expect(
        FeatureFlags.isHiddenProductPath(
          'https://example.com/product/ABC-123?source=banner',
        ),
        isTrue,
      );
    });

    test('does not block customer and account routes', () {
      expect(FeatureFlags.isHiddenProductPath('/customer'), isFalse);
      expect(FeatureFlags.isHiddenProductPath('/account'), isFalse);
    });
  });
}
