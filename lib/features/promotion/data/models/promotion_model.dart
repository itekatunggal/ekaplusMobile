import 'package:ekaplus_ekatunggal/features/promotion/domain/entities/promotion.dart';

class PromotionModel extends Promotion {
  const PromotionModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.content,
    required super.status,
    super.coverImage,
    super.startAt,
    super.endAt,
    super.branchId,
    super.targetAudience,
    super.isDemo,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) => PromotionModel(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    summary: json['summary']?.toString() ?? '',
    content: json['content']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    coverImage: _text(json['cover_image']),
    startAt: DateTime.tryParse(json['start_at']?.toString() ?? ''),
    endAt: DateTime.tryParse(json['end_at']?.toString() ?? ''),
    branchId: int.tryParse(json['branch_id']?.toString() ?? ''),
    targetAudience: _text(json['target_audience']),
    isDemo: json['is_demo'] == true || json['is_demo'] == 1,
  );

  static String? _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
