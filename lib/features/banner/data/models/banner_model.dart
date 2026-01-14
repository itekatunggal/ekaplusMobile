import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';

class BannerModel extends BannerSlider {
  const BannerModel({
    required super.name,
    required super.img,
    super.disabled,
    super.redirect,
    super.redirectType,
    super.pages,
    super.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      name: json['banner_name']?.toString() ?? '',
      img: json['image']?.toString() ?? '',
      disabled: (json['disabled'] ?? 0) == 1,
      // redirect: json['redirect'] ?? false,
      // redirectType: json['redirect_type']?.toString() ?? '',
      // pages: json['pages']?.toString() ?? '',
      // link: json['link']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'banner_name': name,
      'image': img,
      'disabled': (disabled ?? false) ? 1 : 0,
      // 'redirect': redirect,
      // 'redirect_type': redirectType,
      // 'pages': pages,
      // 'link': link,
    };
  }

  static List<BannerModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
