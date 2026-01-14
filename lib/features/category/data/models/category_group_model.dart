// lib/features/category/data/models/category_group_model.dart
import '../../domain/entities/category_group.dart';

class CategorySimpleModel extends CategorySimpleEntity {
  const CategorySimpleModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.description,
    required super.image,
    required super.title,
    required super.subtitle,
  });

  factory CategorySimpleModel.fromJson(Map<String, dynamic> json) {
    return CategorySimpleModel(
      id: json['id'] ?? 0,
      name: json['category_name'] ?? '',
      icon: json['icon'],
      description: json['description'],
      image: json['image'],
      subtitle: json['subtitle'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': name,
      'icon': icon,
      'description': description,
      'image': image,
      'title': title,
      'subtitle': subtitle,
    };
  }
}

class CategoryGroupModel extends CategoryGroupEntity {
  const CategoryGroupModel({
    required super.id,
    required super.typeName,
    super.categories = const [],
  });

  factory CategoryGroupModel.fromJson(Map<String, dynamic> json) {
    return CategoryGroupModel(
      id: json['id'] ?? 0,
      typeName: json['type_name'] ?? '',
      categories: json['categories'] != null
          ? (json['categories'] as List)
                .map((e) => CategorySimpleModel.fromJson(e))
                .toList()
          : const [],
    );
  }

  static List<CategoryGroupModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data.map((e) => CategoryGroupModel.fromJson(e)).toList();
  }
}
