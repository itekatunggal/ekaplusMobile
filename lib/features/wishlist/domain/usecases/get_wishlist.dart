// lib/features/wishlist/domain/usecases/get_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/repositories/wishlist_repository.dart';

class GetWishlist {
  final WishlistRepository repository;

  GetWishlist(this.repository);

  Future<Either<Failure, List<WishlistItem>>> call(
    int userId, {
    int? page,
    int? limit,
    String? search,
    List<List<dynamic>>? filters,
    List<List<String>>? orderBy,
    List<String>? fields,
  }) async {
    return await repository.getWishlist(
      userId,
      page: page,
      limit: limit,
      search: search,
      filters: filters,
      orderBy: orderBy,
      fields: fields,
    );
  }
}
