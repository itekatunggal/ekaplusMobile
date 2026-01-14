// lib/features/wishlist/data/repositories/wishlist_repository_implementation.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;

  WishlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<WishlistItem>>> getWishlist(
    int userId, {
    int? page,
    int? limit,
    String? search,
    List<List<dynamic>>? filters,
    List<List<String>>? orderBy,
    List<String>? fields,
  }) async {
    try {
      final result = await remoteDataSource.getWishlist(
        userId,
        null,
        page: page,
        limit: limit,
        search: search,
        filters: filters,
        orderBy: orderBy,
        fields: fields,
      );
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist(int userId, int productId) async {
    try {
      await remoteDataSource.addToWishlist(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(
    int userId,
    int productId,
  ) async {
    try {
      await remoteDataSource.removeFromWishlist(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist(int userId, int productId) async {
    try {
      final result = await remoteDataSource.isInWishlist(userId, productId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> bulkDeleteWishlist(
    int userId,
    List<int> productIds,
  ) async {
    try {
      final deletedCount = await remoteDataSource.bulkDeleteWishlist(
        userId,
        productIds,
      );
      return Right(deletedCount);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
