// lib/features/wishlist/presentation/bloc/wishlist_event.dart
import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWishlistFirstPage extends WishlistEvent {
  final String? search;
  final List<List<dynamic>>? filters;
  final List<List<String>>? orderBy;
  final List<String>? fields;
  final int? limit;

  const LoadWishlistFirstPage({
    this.search,
    this.filters,
    this.orderBy,
    this.fields,
    this.limit,
  });

  @override
  List<Object?> get props => [search, filters, orderBy, fields, limit];
}

class LoadWishlistNextPage extends WishlistEvent {
  const LoadWishlistNextPage();
}

class RefreshWishlist extends WishlistEvent {
  const RefreshWishlist();
}

class LoadWishlist extends WishlistEvent {}

class ToggleWishlistItem extends WishlistEvent {
  final int productId;

  const ToggleWishlistItem({required this.productId});

  @override
  List<Object> get props => [productId];
}

class CheckWishlistStatus extends WishlistEvent {
  final int productId;

  const CheckWishlistStatus({required this.productId});

  @override
  List<Object> get props => [productId];
}

class BulkDeleteWishlistItems extends WishlistEvent {
  final int userId;
  final List<int> productIds;

  const BulkDeleteWishlistItems({
    required this.userId,
    required this.productIds,
  });

  @override
  List<Object> get props => [userId, productIds];
}

class ClearWishlistCache extends WishlistEvent {
  const ClearWishlistCache();
}
