// lib/features/member/data/models/regency_model.dart

class RegencyModel {
  final String code;
  final String name;
  final String provinceId;

  RegencyModel({
    required this.code,
    required this.name,
    required this.provinceId,
  });

  factory RegencyModel.fromJson(Map<String, dynamic> json) {
    return RegencyModel(
      code: json['code'].toString(),
      name: json['name'] as String,
      provinceId: json['province_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'province_id': provinceId,
    };
  }
}
