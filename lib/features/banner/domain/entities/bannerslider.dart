// lib/features/banner/domain/entities/bannerslider.dart
import 'package:equatable/equatable.dart';

class BannerSlider extends Equatable {
  final String name;
  final String img;
  final bool? disabled;
  final String type;
  final String typeValue;

  const BannerSlider({
    required this.name,
    required this.img,
    this.disabled = true,
    this.type = 'non',
    this.typeValue = '',
  });

  bool get hasAction =>
      (type == 'url' || type == 'internal_route') && typeValue.isNotEmpty;

  @override
  List<Object?> get props => [name, img, disabled, type, typeValue];
}
