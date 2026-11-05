import 'package:equatable/equatable.dart';

class InvoiceList extends Equatable {
  final int id;
  final String nomor;
  final DateTime jatuhTempo;
  final String telat;
  final String nilai;
  final String status;

  const InvoiceList({
    required this.id,
    required this.nomor,
    required this.jatuhTempo,
    required this.telat,
    required this.nilai,
    required this.status,
  });

  @override
  List<Object?> get props => [id, nomor, jatuhTempo, telat, nilai, status];
}
