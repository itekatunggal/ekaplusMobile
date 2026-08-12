// lib/features/wishlist/data/models/wishlist_item_model.dart
import 'package:ekaplus_ekatunggal/features/report/domain/entities/piutang_list.dart';

class PiutangItemModel extends PiutangItem {
  const PiutangItemModel({
    required super.id,
    required super.nomorInvoice,
    required super.jatuhTempo,
    required super.total,
    required super.nilai,
  });

  factory PiutangItemModel.fromJson(Map<String, dynamic> json) {
    return PiutangItemModel(
      id: json['id'],
      item: PiutangItemProduct(
        id: json['item']['id'],
        nomorInvoice: json['item']['nomorInvoice'],
        jatuhTempo: json['item']['jatuhTempo'] ?? '',
        telat: json['item']['telat'],
        nilai: json['item']['nilai'] ?? '',
      ),
    );
  }

  static List<PiutangItemModel> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => PiutangItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': item.id,
      'item': {
        'id': item.id,
        'nomorInvoice': item.nomorInvoice,
        'jatuhTempo': item.jatuh\,
        'telat': item.telat,
        'nilai': item.nilai,
      },
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<PiutangItemModel> items) {
    return items.map((e) => e.toJson()).toList();
  }
}
