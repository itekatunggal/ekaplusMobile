import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final int id;
  final String itemCode;
  final String itemName;
  final String qty;
  final DateTime date;
  final String amount;

  const InvoiceItem({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.date,
    required this.amount,
  });

  @override
  List<Object?> get props => [id, itemCode, itemName, qty, date, amount];
}
