// lib/features/member/data/models/province_model.dart

class ProvinceModel {
  final String code;
  final String name;

  ProvinceModel({
    required this.code,
    required this.name,
  });

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(
      code: json['code'].toString(),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }
}
