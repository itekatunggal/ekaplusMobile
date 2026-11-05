import 'package:equatable/equatable.dart';

class PiutangList extends Equatable {
  final int id;
  final String nomorInvoice;
  final DateTime jatuhTempo;
  final String telat;
  final String nilai;

  const PiutangList({
    required this.id,
    required this.nomorInvoice,
    required this.jatuhTempo,
    required this.telat,
    required this.nilai,
  });

  @override
  List<Object?> get props => [id, nomorInvoice, jatuhTempo, telat, nilai];
}
