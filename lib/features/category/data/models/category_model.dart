// lib/features/category/data/models/category_model.dart
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';

class TypeModel extends TypeEntity {
  const TypeModel({required super.id, required super.name});

  factory TypeModel.fromJson(Map<String, dynamic> json) {
    return TypeModel(id: json['id'] ?? 0, name: json['category_name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'category_name': name};
  }

  static List<TypeEntity> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data
        .map((singleDataItem) => TypeModel.fromJson(singleDataItem))
        .toList();
  }
}

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'] ?? 0, name: json['category_name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'category_name': name};
  }
}

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.icon,
    super.image,
    super.description,
    super.title,
    super.subtitle,
    required super.type,
    super.docstatus = 0,
    super.status,
    super.disabled = 0,
    required super.updatedAt,
    super.updatedBy,
    required super.createdAt,
    super.createdBy,
    super.owner,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> dataJson) {
    Map<String, dynamic> data = dataJson;

    return CategoryModel(
      id: data['id'] ?? 0,
      name: data['category_name'] ?? '',
      icon: data['icon'],
      image: data['image'],
      description: data['description'],
      title: data['title'],
      subtitle: data['subtitle'],
      type: data['type'] != null ? TypeModel.fromJson(data['type']) : null,
      docstatus: data['docstatus'] ?? 0,
      status: data['status'] ?? '',
      disabled: data['disabled'] ?? 0,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
      updatedBy: data['updated_by'] != null
          ? UserModel.fromJson(data['updated_by'])
          : null,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      createdBy: data['created_by'] != null
          ? UserModel.fromJson(data['created_by'])
          : null,
      owner: data['owner'] != null ? UserModel.fromJson(data['owner']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "category_name": name,
      "icon": icon,
      "image": image,
      "description": description,
      "title": title,
      "subtitle": subtitle,
      "type": type != null ? (type as TypeModel).toJson() : null,
      "docstatus": docstatus,
      "status": status,
      "disabled": disabled,
      "updated_at": updatedAt?.toIso8601String(),
      "updated_by": updatedBy != null
          ? (updatedBy as UserModel).toJson()
          : null,
      "created_at": createdAt?.toIso8601String(),
      "created_by": createdBy != null
          ? (createdBy as UserModel).toJson()
          : null,
      "owner": owner != null ? (owner as UserModel).toJson() : null,
    };
  }

  static List<CategoryModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data
        .map((singleDataItem) => CategoryModel.fromJson(singleDataItem))
        .toList();
  }
}
