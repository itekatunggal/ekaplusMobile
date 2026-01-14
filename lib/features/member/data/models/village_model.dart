// lib/features/member/data/models/village_model.dart

class VillageModel {
  final String code;
  final String name;
  final String districtId;

  VillageModel({
    required this.code,
    required this.name,
    required this.districtId,
  });

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      code: json['code'].toString(),
      name: json['name'] as String,
      districtId: json['district_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'district_id': districtId,
    };
  }
}
