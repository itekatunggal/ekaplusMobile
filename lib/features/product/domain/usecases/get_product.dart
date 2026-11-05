// lib/features/product/domain/usecases/get_product.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';

class GetProduct {
  final ProductRepository productRepository;
  const GetProduct(this.productRepository);

  Future<Either<Failure, Product>> execute(String id) {
    return productRepository.getProduct(id);
  }
}
