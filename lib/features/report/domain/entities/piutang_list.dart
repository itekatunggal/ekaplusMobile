import 'package:equatable/equatable.dart';

class ItemCategoryEntity extends Equatable {
  final int id;
  final String nomorInvoice;
  final Date jatuhTempo;
  final String telat;
  final String nilai;

  const ItemCategoryEntity({required this.id, required this.nomorInvoice, required this.jatuhTempo, required this.telat, required this.nilai });

  @override
  List<Object?> get props => [id, nomorInvoice, jatuhTempo, telat, nilai];
}

class VariantEntity extends Equatable {
  // final int id;
  // final String code;
  // final String name;
  // final String description;
  // final String image;
  final int id;
  final String nomorInvoice;
  final Date jatuhTempo;
  final String telat;
  final String nilai;

  const VariantEntity({
    required this.id,
    required this.nomorInvoice,
    required this.jatuhTempo,
    required this.telat,
    required this.nilai
  });

  @override
  List<Object?> get props => [id, nomorInvoice, jatuhTempo, telat, nilai];
}

class PiutangList extends Equatable {
  final int id;
  final String nomorInvoice;
  final Date jatuhTempo;
  final String telat;
  final String nilai;
  // final ItemCategoryEntity? itemCategory;
  // final List<VariantEntity> variants;
  // final bool isHotDeals;

  const Piutang({
    required this.id,
    required this.nomorInvoice,
    required this.jatuhTempo,
    required this.telat,
    required this.nilai,
    // this.itemCategory,
    // this.variants = const [],
    // this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [id, nomorInvoice, jatuhTempo, telat, nilai];
}
