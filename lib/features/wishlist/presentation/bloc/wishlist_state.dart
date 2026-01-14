// lib/features/wishlist/presentation/bloc/wishlist_state.dart
import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItem> items;
  final Map<int, bool> statusMap;
  final int page;
  final int limit;
  final bool hasMore;
  final bool isLoadingMore;
  final String? search;
  final List<List<dynamic>>? filters;
  final List<List<String>>? orderBy;
  final List<String>? fields;

  const WishlistLoaded({
    required this.items,
    this.statusMap = const {},
    required this.page,
    required this.limit,
    required this.hasMore,
    this.isLoadingMore = false,
    this.search,
    this.filters,
    this.orderBy,
    this.fields,
  });

  @override
  List<Object?> get props => [
    items,
    statusMap,
    page,
    limit,
    hasMore,
    isLoadingMore,
    search,
    filters,
    orderBy,
    fields,
  ];

  bool isInWishlist(String productId) {
    return false;
  }

  WishlistLoaded copyWith({
    List<WishlistItem>? items,
    Map<int, bool>? statusMap,
    int? page,
    int? limit,
    bool? hasMore,
    bool? isLoadingMore,
    String? search,
    List<List<dynamic>>? filters,
    List<List<String>>? orderBy,
    List<String>? fields,
  }) {
    return WishlistLoaded(
      items: items ?? this.items,
      statusMap: statusMap ?? this.statusMap,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
      filters: filters ?? this.filters,
      orderBy: orderBy ?? this.orderBy,
      fields: fields ?? this.fields,
    );
  }
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}

class WishListStatus extends WishlistState {
  final bool status;

  const WishListStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class WishlistToggled extends WishlistState {
  final bool isInWishlist;
  final int productId;

  const WishlistToggled({required this.isInWishlist, required this.productId});

  @override
  List<Object?> get props => [isInWishlist, productId];
}
