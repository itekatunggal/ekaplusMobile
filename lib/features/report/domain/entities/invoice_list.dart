import 'package:equatable/equatable.dart';

class ItemCategoryEntity extends Equatable {
  final int id;
  final String nomor;
  final Date jatuhTempo;
  final String telat;
  final String nilai;
  final String status;

  const ItemCategoryEntity({required this.id, required this.nomor, required this.jatuhTempo, required this.telat, required this.nilai, required this.status });

  @override
  List<Object?> get props => [id, nomor, jatuhTempo, telat, nilai, status];
}

class VariantEntity extends Equatable {
  // final int id;
  // final String code;
  // final String name;
  // final String description;
  // final String image;
  final int id;
  final String nomor;
  final Date jatuhTempo;
  final String telat;
  final String nilai;
  final String status;

  const VariantEntity({
    required this.id,
    required this.nomor,
    required this.jatuhTempo,
    required this.telat,
    required this.nilai,
    required this.status
  });

  @override
  List<Object?> get props => [id, nomor, jatuhTempo, telat, nilai, status];
}

class InvoiceList extends Equatable {
  final int id;
  final String nomor;
  final Date jatuhTempo;
  final String telat;
  final String nilai;
  final String status;
  // final ItemCategoryEntity? itemCategory;
  // final List<VariantEntity> variants;
  // final bool isHotDeals;

  const Invoice({
    required this.id,
    required this.nomor,
    required this.jatuhTempo,
    required this.telat,
    required this.nilai,
    required this.status
    // this.itemCategory,
    // this.variants = const [],
    // this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [id, nomor, jatuhTempo, telat, nilai, status];
}
