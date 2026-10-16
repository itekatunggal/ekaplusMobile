import 'package:ekaplus_ekatunggal/features/report/domain/entities/piutang_list.dart';

class PiutangListModel extends PiutangList {
  const PiutangListModel({
    required super.id,
    required super.nomorInvoice,
    required super.jatuhTempo,
    required super.telat,
    required super.nilai,
  });

  factory PiutangListModel.fromJson(Map<String, dynamic> json) {
    return PiutangListModel(
      id: (json['id'] as num).toInt(),
      nomorInvoice: json['nomorInvoice']?.toString() ?? '',
      jatuhTempo: DateTime.parse(json['jatuhTempo'].toString()),
      telat: json['telat']?.toString() ?? '',
      nilai: json['nilai']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nomorInvoice': nomorInvoice,
    'jatuhTempo': jatuhTempo.toIso8601String(),
    'telat': telat,
    'nilai': nilai,
  };

  static List<PiutangListModel> fromJsonList(List<dynamic> list) => list
      .map((item) => PiutangListModel.fromJson(item as Map<String, dynamic>))
      .toList();
}
