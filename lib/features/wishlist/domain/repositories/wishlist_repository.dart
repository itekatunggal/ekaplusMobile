// lib/features/wishlist/domain/repositories/wishlist_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<WishlistItem>>> getWishlist(
    int userId, {
    int? page,
    int? limit,
    String? search,
    List<List<dynamic>>? filters,
    List<List<String>>? orderBy,
    List<String>? fields,
  });

  Future<Either<Failure, void>> addToWishlist(int userId, int productId);

  Future<Either<Failure, void>> removeFromWishlist(int userId, int productId);

  Future<Either<Failure, bool>> isInWishlist(int userId, int productId);

  Future<Either<Failure, int>> bulkDeleteWishlist(
    int userId,
    List<int> productIds,
  );
}
