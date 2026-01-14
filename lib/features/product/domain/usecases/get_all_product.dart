// lib/features/product/domain/usecases/get_all_product.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';

class GetAllProduct {
  final ProductRepository repository;

  GetAllProduct(this.repository);

  Future<Either<Failure, List<Product>>> execute({
    int page = 1,
    int limit = 20,
    String? search,
    List<List<dynamic>>? filters,
    List<List<String>>? orderBy,
    List<String>? fields,
  }) {
    return repository.getAllProduct(
      page: page,
      limit: limit,
      search: search,
      filters: filters,
      orderBy: orderBy,
      fields: fields,
    );
  }
}
