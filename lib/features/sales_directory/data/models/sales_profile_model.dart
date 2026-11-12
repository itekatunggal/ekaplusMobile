import 'package:ekaplus_ekatunggal/features/sales_directory/domain/entities/sales_profile.dart';

class SalesProfileModel extends SalesProfile {
  const SalesProfileModel({
    required super.id,
    required super.name,
    required super.position,
    required super.division,
    required super.branchId,
    super.photoUrl,
    super.workWhatsapp,
    super.workPhone,
    required super.description,
    super.isDemo,
  });

  factory SalesProfileModel.fromJson(Map<String, dynamic> json) {
    return SalesProfileModel(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      division: json['division']?.toString() ?? '',
      branchId: _asInt(json['branch_id']),
      photoUrl: _textOrNull(json['photo_url']),
      workWhatsapp: _textOrNull(json['work_whatsapp']),
      workPhone: _textOrNull(json['work_phone']),
      description: json['description']?.toString() ?? '',
      isDemo: json['is_demo'] == true || json['is_demo'] == 1,
    );
  }

  static int _asInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static String? _textOrNull(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
