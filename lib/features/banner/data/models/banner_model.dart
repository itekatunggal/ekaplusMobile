import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';

class BannerModel extends BannerSlider {
  const BannerModel({
    required super.name,
    required super.img,
    super.disabled,
    super.type,
    super.typeValue,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      name: json['banner_name']?.toString() ?? '',
      img: json['image']?.toString() ?? '',
      disabled: (json['disabled'] ?? 0) == 1,
      type: json['type']?.toString().trim().toLowerCase() ?? 'non',
      typeValue: json['type_value']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'banner_name': name,
      'image': img,
      'disabled': (disabled ?? false) ? 1 : 0,
      'type': type,
      'type_value': typeValue,
    };
  }

  static List<BannerModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
