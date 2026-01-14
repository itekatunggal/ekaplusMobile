// lib/features/product/domain/usecases/get_hot_deals.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';

class GetHotDeals {
  final ProductRepository productRepository;
  const GetHotDeals(this.productRepository);

  Future<Either<Failure, List<Product>>> execute() {
    return productRepository.getHotDeals();
  }
}
