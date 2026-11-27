import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';

class BannerModel extends BannerSlider {
  const BannerModel({
    required super.name,
    required super.img,
    super.disabled,
    super.type,
    super.typeValue,
    super.sortBy,
    super.showButton,
    super.buttonDisplay,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      name: json['banner_name']?.toString() ?? '',
      img: json['image']?.toString() ?? '',
      disabled: (json['disabled'] ?? 0) == 1,
      type: json['type']?.toString().trim().toLowerCase() ?? 'non',
      typeValue: json['type_value']?.toString().trim() ?? '',
      sortBy: _parseInt(json['sort_by']),
      showButton: _parseBool(json['show_button']),
      buttonDisplay: json['button_display']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'banner_name': name,
      'image': img,
      'disabled': (disabled ?? false) ? 1 : 0,
      'type': type,
      'type_value': typeValue,
      'sort_by': sortBy,
      'show_button': showButton ? 1 : 0,
      'button_display': buttonDisplay,
    };
  }

  static List<BannerModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    final banners = data
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
    banners.sort((a, b) => a.sortBy.compareTo(b.sortBy));
    return banners;
  }

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == '1' || normalized == 'true';
  }
}
