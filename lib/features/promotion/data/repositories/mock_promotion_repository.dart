import 'package:ekaplus_ekatunggal/features/promotion/data/models/promotion_model.dart';
import 'package:ekaplus_ekatunggal/features/promotion/domain/entities/promotion.dart';
import 'package:ekaplus_ekatunggal/features/promotion/domain/repositories/promotion_repository.dart';

class MockPromotionRepository implements PromotionRepository {
  MockPromotionRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  static final _fixtures = <Promotion>[
    const PromotionModel(
      id: 'promo-demo-1',
      title: 'Informasi promo akan hadir di sini',
      summary: 'Pratinjau area informasi program pelanggan.',
      content:
          'Ini adalah konten demo. Informasi program resmi akan ditampilkan setelah disetujui dan tersedia.',
      status: 'active',
      targetAudience: 'Pelanggan EKAPLUS',
      isDemo: true,
    ),
    const PromotionModel(
      id: 'promo-demo-2',
      title: 'Program pelanggan sedang disiapkan',
      summary: 'Detail resmi akan ditampilkan pada halaman ini.',
      content:
          'Konten ini hanya digunakan untuk pratinjau tampilan dan bukan penawaran komersial.',
      status: 'active',
      isDemo: true,
    ),
    PromotionModel(
      id: 'promo-expired-demo',
      title: 'Contoh promo kedaluwarsa',
      summary: 'Tidak boleh tampil.',
      content: 'Fixture pengujian.',
      status: 'active',
      endAt: DateTime(2020, 1, 1),
      isDemo: true,
    ),
  ];

  @override
  Future<List<Promotion>> getPromotions({int? branchId, String? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalized = query?.trim().toLowerCase() ?? '';
    final now = _now();
    return _fixtures
        .where((promotion) {
          final branchMatches =
              promotion.branchId == null || promotion.branchId == branchId;
          final queryMatches =
              normalized.isEmpty ||
              promotion.title.toLowerCase().contains(normalized) ||
              promotion.summary.toLowerCase().contains(normalized);
          return promotion.isActiveAt(now) && branchMatches && queryMatches;
        })
        .toList(growable: false);
  }

  @override
  Future<Promotion?> getPromotionById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (final promotion in _fixtures) {
      if (promotion.id == id && promotion.isActiveAt(_now())) return promotion;
    }
    return null;
  }
}
