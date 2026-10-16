import 'package:equatable/equatable.dart';

class DeliveryList extends Equatable {
  final int id;
  final String name;
  final String customer;
  final DateTime date;
  final String status;

  const DeliveryList({
    required this.id,
    required this.name,
    required this.customer,
    required this.date,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, customer, date, status];
}
