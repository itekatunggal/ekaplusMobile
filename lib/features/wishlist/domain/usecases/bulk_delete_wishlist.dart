import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/repositories/wishlist_repository.dart';

class BulkDeleteWishlist {
  final WishlistRepository repository;

  BulkDeleteWishlist(this.repository);

  Future<Either<Failure, int>> call(int userId, List<int> productIds) async {
    return await repository.bulkDeleteWishlist(userId, productIds);
  }
}
