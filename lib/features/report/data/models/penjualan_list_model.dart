import 'package:ekaplus_ekatunggal/features/report/domain/entities/penjualan_list.dart';

class PenjualanListModel extends PenjualanList {
  const PenjualanListModel({
    required super.id,
    required super.date,
    required super.nilai,
  });

  factory PenjualanListModel.fromJson(Map<String, dynamic> json) {
    return PenjualanListModel(
      id: (json['id'] as num).toInt(),
      date: DateTime.parse(json['date'].toString()),
      nilai: json['nilai']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'nilai': nilai,
  };

  static List<PenjualanListModel> fromJsonList(List<dynamic> list) => list
      .map((item) => PenjualanListModel.fromJson(item as Map<String, dynamic>))
      .toList();
}
