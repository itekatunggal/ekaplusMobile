// lib/features/type/domain/entities/type.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;

  const UserEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class Type extends Equatable {
  final int id;
  final String name;
  final String? image;
  final String? description;
  final int? docstatus;
  final String? status;
  final int? disabled;
  final String? typeName;
  final DateTime? updatedAt;
  final UserEntity? updatedBy;
  final DateTime createdAt;
  final UserEntity? createdBy;
  final UserEntity? owner;

  const Type({
    required this.id,
    required this.name,
    this.image = "",
    this.description = "",
    this.docstatus = 0,
    this.status = "",
    this.disabled = 0,
    this.typeName = "",
    required this.updatedAt,
    this.updatedBy,
    required this.createdAt,
    this.createdBy,
    this.owner,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    description,
    disabled,
    docstatus,
    status,
    typeName,
    updatedAt,
    updatedBy,
    createdAt,
    createdBy,
    owner,
  ];
}
