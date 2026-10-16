import 'package:equatable/equatable.dart';

class ProductList extends Equatable {
  final int id;
  final String name;
  final int qty;
  final String total;
  final String persen;

  const ProductList({
    required this.id,
    required this.name,
    required this.qty,
    required this.total,
    required this.persen,
  });

  @override
  List<Object?> get props => [id, name, qty, total, persen];
}
