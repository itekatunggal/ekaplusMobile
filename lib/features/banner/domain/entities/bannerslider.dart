// lib/features/banner/domain/entities/bannerslider.dart
import 'package:equatable/equatable.dart';

class BannerSlider extends Equatable {
  final String name;
  final String img;
  final bool? disabled;
  final bool? redirect;
  final String? redirectType;
  final String? pages;
  final String? link;

  const BannerSlider({
    required this.name,
    required this.img,
    this.disabled = true,
    this.redirect = false,
    this.redirectType = "",
    this.pages = "",
    this.link = "",
  });

  @override
  List<Object?> get props => [
        name,
        img,
        disabled,
        redirect,
        redirectType,
        pages,
        link,
      ];
}
