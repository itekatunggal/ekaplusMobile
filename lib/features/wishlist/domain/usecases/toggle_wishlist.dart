// lib/features/wishlist/domain/usecases/toggle_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/repositories/wishlist_repository.dart';

class ToggleWishlist {
  final WishlistRepository repository;

  ToggleWishlist(this.repository);

  Future<Either<Failure, bool>> call(int userId, int productId) async {
    // Check if already in wishlist
    final checkResult = await repository.isInWishlist(userId, productId);

    return checkResult.fold((failure) => Left(failure), (isInWishlist) async {
      if (isInWishlist) {
        final removeResult = await repository.removeFromWishlist(
          userId,
          productId,
        );
        return removeResult.fold(
          (failure) => Left(failure),
          (_) => const Right(false), // false = removed
        );
      } else {
        final addResult = await repository.addToWishlist(userId, productId);
        return addResult.fold(
          (failure) => Left(failure),
          (_) => const Right(true), // true = added
        );
      }
    });
  }
}
