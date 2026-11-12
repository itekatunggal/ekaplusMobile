import 'package:ekaplus_ekatunggal/features/promotion/data/repositories/mock_promotion_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockPromotionRepository repository;

  setUp(() {
    repository = MockPromotionRepository(now: () => DateTime(2026, 11, 11));
  });

  test('hanya mengembalikan promo yang masih aktif', () async {
    final promotions = await repository.getPromotions();

    expect(promotions, hasLength(2));
    expect(
      promotions.map((item) => item.id),
      isNot(contains('promo-expired-demo')),
    );
  });

  test('mendukung pencarian dan menyembunyikan detail kedaluwarsa', () async {
    final result = await repository.getPromotions(query: 'disiapkan');
    final expired = await repository.getPromotionById('promo-expired-demo');

    expect(result, hasLength(1));
    expect(result.single.id, 'promo-demo-2');
    expect(expired, isNull);
  });
}
