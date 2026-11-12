import 'package:ekaplus_ekatunggal/features/promotion/domain/entities/promotion.dart';

abstract class PromotionRepository {
  Future<List<Promotion>> getPromotions({int? branchId, String? query});
  Future<Promotion?> getPromotionById(String id);
}
