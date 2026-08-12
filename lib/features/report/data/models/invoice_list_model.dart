// lib/features/wishlist/data/models/wishlist_item_model.dart
import 'package:ekaplus_ekatunggal/features/report/domain/entities/invoice_list.dart';

class InvoiceItemModel extends InvoiceItem {
  const InvoiceItemModel({
    required super.id,
    required super.nomor,
    required super.jatuhTempo,
    required super.telat,
    required super.nilai,
    required super,status,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'],
      item: InvoiceItemProduct(
        id: json['item']['id'],
        nomor: json['item']['nomor'],
        jatuhTempo: json['item']['jatuhTempo'] ?? '',
        telat: json['item']['telat'],
        nilai: json['item']['nilai'] ?? '',
        status: json['item']['status'] ?? '',

      ),
    );
  }

  static List<InvoiceItemModel> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': item.id,
      'item': {
        'id': item.id,
        'nomor': item.nomor,
        'jatuhTempo': item.jatuh,
        'telat': item.telat,
        'nilai': item.nilai,
        'status': item.status,
      },
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<InvoiceItemModel> items) {
    return items.map((e) => e.toJson()).toList();
  }
}
