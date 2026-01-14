// lib/features/wishlist/domain/usecases/check_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/repositories/wishlist_repository.dart';

class CheckWishlist {
  final WishlistRepository repository;

  CheckWishlist(this.repository);

  Future<Either<Failure, bool>> call(int userId, int productId) async {
    return await repository.isInWishlist(userId, productId);
  }
}
