// lib/features/category/domain/entities/category_group.dart
import 'package:equatable/equatable.dart';

class CategorySimpleEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String image;
  final String subtitle;
  final String title;

  const CategorySimpleEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.image,
    required this.subtitle,
    required this.title,
  });

  @override
  List<Object?> get props => [id, name];
}

class CategoryGroupEntity extends Equatable {
  final int id;
  final String typeName;
  final List<CategorySimpleEntity> categories;

  const CategoryGroupEntity({
    required this.id,
    required this.typeName,
    this.categories = const [],
  });

  @override
  List<Object?> get props => [id, typeName, categories];
}
