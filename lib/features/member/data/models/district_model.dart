// lib/features/member/data/models/district_model.dart

class DistrictModel {
  final String code;
  final String name;
  final String regencyId;

  DistrictModel({
    required this.code,
    required this.name,
    required this.regencyId,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      code: json['code'].toString(),
      name: json['name'] as String,
      regencyId: json['regency_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'regency_id': regencyId,
    };
  }
}
