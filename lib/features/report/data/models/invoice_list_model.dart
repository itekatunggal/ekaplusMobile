import 'package:ekaplus_ekatunggal/features/report/domain/entities/invoice_list.dart';

class InvoiceListModel extends InvoiceList {
  const InvoiceListModel({
    required super.id,
    required super.nomor,
    required super.jatuhTempo,
    required super.telat,
    required super.nilai,
    required super.status,
  });

  factory InvoiceListModel.fromJson(Map<String, dynamic> json) {
    return InvoiceListModel(
      id: (json['id'] as num).toInt(),
      nomor: json['nomor']?.toString() ?? '',
      jatuhTempo: DateTime.parse(json['jatuhTempo'].toString()),
      telat: json['telat']?.toString() ?? '',
      nilai: json['nilai']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nomor': nomor,
    'jatuhTempo': jatuhTempo.toIso8601String(),
    'telat': telat,
    'nilai': nilai,
    'status': status,
  };

  static List<InvoiceListModel> fromJsonList(List<dynamic> list) => list
      .map((item) => InvoiceListModel.fromJson(item as Map<String, dynamic>))
      .toList();
}
