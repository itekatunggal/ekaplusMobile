// lib/features/type/data/models/type_model.dart
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class TypeModel extends Type {
  const TypeModel({
    required super.id,
    required super.name,
    super.image,
    super.description,
    super.docstatus = 0,
    super.status,
    super.typeName,
    super.disabled = 0,
    required super.updatedAt,
    // super.updatedBy,
    required super.createdAt,
    // super.createdBy,
    // super.owner,
  });

  factory TypeModel.fromJson(Map<String, dynamic> dataJson) {
    Map<String, dynamic> data = dataJson;

    return TypeModel(
      id: data['id'] ?? 0,
      name: data['type_name'] ?? '',
      image: data['image'],
      description: data['description'],
      docstatus: data['docstatus'] ?? 0,
      status: data['status'] ?? '',
      typeName: data['type_name'],
      disabled: data['disabled'] ?? 0,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
      // updatedBy: data['updated_by'] != null
      //     ? UserModel.fromJson(data['updated_by'])
      //     : null,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      // createdBy: data['created_by'] != null
      //     ? UserModel.fromJson(data['created_by'])
      //     : null,
      // owner: data['owner'] != null ? UserModel.fromJson(data['owner']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image": image,
      "description": description,
      "docstatus": docstatus,
      "status": status,
      "type_name": typeName,
      "disabled": disabled,
      "updated_at": updatedAt?.toIso8601String(),
      // "updated_by": updatedBy != null
      //     ? (updatedBy as UserModel).toJson()
      //     : null,
      "created_at": createdAt.toIso8601String(),
      // "created_by": createdBy != null
      //     ? (createdBy as UserModel).toJson()
      //     : null,
      // "owner": owner != null ? (owner as UserModel).toJson() : null,
    };
  }

  static List<TypeModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data
        .map((singleDataItem) => TypeModel.fromJson(singleDataItem))
        .toList();
  }
}
