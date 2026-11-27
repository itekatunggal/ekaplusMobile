// lib/features/banner/domain/entities/bannerslider.dart
import 'package:equatable/equatable.dart';

class BannerSlider extends Equatable {
  final String name;
  final String img;
  final bool? disabled;
  final String type;
  final String typeValue;
  final int sortBy;
  final bool showButton;
  final String buttonDisplay;

  const BannerSlider({
    required this.name,
    required this.img,
    this.disabled = true,
    this.type = 'non',
    this.typeValue = '',
    this.sortBy = 0,
    this.showButton = false,
    this.buttonDisplay = '',
  });

  bool get hasAction =>
      (type == 'url' || type == 'internal_route') && typeValue.isNotEmpty;

  bool get shouldShowButton => hasAction;

  String get buttonLabel {
    final customLabel = buttonDisplay.trim();
    return showButton && customLabel.isNotEmpty ? customLabel : 'Selengkapnya';
  }

  @override
  List<Object?> get props => [
    name,
    img,
    disabled,
    type,
    typeValue,
    sortBy,
    showButton,
    buttonDisplay,
  ];
}
