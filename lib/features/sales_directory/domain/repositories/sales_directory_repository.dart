import 'package:ekaplus_ekatunggal/features/sales_directory/domain/entities/sales_profile.dart';

abstract class SalesDirectoryRepository {
  Future<List<SalesProfile>> getSales({
    required int branchId,
    String? query,
    String? position,
  });

  Future<SalesProfile?> getSalesById(int id);
}
