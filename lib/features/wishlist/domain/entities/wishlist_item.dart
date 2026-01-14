import 'package:equatable/equatable.dart';

class WishlistItem extends Equatable {
  final int id;
  final DateTime createdAt;
  final WishlistItemProduct item;
  final WishlistItemUser user;

  const WishlistItem({
    required this.id,
    required this.createdAt,
    required this.item,
    required this.user,
  });

  @override
  List<Object?> get props => [createdAt, item, user];
}

class WishlistItemProduct extends Equatable {
  final int id;
  final String image;
  final String itemCode;
  final String itemName;

  const WishlistItemProduct({
    required this.id,
    required this.image,
    required this.itemCode,
    required this.itemName,
  });

  @override
  List<Object?> get props => [id, image, itemCode, itemName];
}

class WishlistItemUser extends Equatable {
  final int id;
  final String fullName;

  const WishlistItemUser({required this.id, required this.fullName});

  @override
  List<Object?> get props => [id, fullName];
}
