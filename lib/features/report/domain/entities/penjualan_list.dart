import 'package:equatable/equatable.dart';

class PenjualanList extends Equatable {
  final int id;
  final DateTime date;
  final String nilai;

  const PenjualanList({
    required this.id,
    required this.date,
    required this.nilai,
  });

  @override
  List<Object?> get props => [id, date, nilai];
}
