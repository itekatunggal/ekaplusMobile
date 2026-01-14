// lib/features/product/data/repositories/product_repository_implementation.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ProductRepositoryImplementation extends ProductRepository {
  final ProductRemoteDatasource productRemoteDatasource;

  ProductRepositoryImplementation({required this.productRemoteDatasource});

  @override
  Future<Either<Failure, List<Product>>> getAllProduct({
    int page = 1,
    int limit = 20,
    List<List<dynamic>>? filters,
    List<String>? fields,
    List<List<String>>? orderBy,
    String? search,
  }) async {
    try {
      final result = await productRemoteDatasource.getAllProduct(
        page: page,
        limit: limit,
        filters: filters,
        fields: fields,
        orderBy: orderBy,
        search: search,
      );

      return Right(result);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      // final List<ConnectivityResult> connectivityResult = await Connectivity()
      //     .checkConnectivity();

      // if (connectivityResult.contains(ConnectivityResult.none)) {
      //   return Left(Failure(message: "No Connection")); // ⚠️ PERBAIKI
      // }

      Product result = await productRemoteDatasource.getProduct(id);
      return Right(result);
    } catch (e) {
      return Left(Failure(message: e.toString())); // ⚠️ PERBAIKI
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getHotDeals() async {
    try {
      final List<ConnectivityResult> connectivityResult = await Connectivity()
          .checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return Left(Failure(message: "No Connection"));
      }

      // Ambil semua product
      List<Product> allProducts = await productRemoteDatasource.getAllProduct(
        page: 1,
      );

      // ✅ Filter yang isHotDeals == true
      final List<Product> hotDeals = allProducts
          .where((p) => p.isHotDeals == true)
          .toList();

      return Right(hotDeals);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
