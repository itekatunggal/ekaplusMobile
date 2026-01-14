// lib/features/category/domain/entities/category.dart
import 'package:equatable/equatable.dart';

class TypeEntity extends Equatable {
  final int id;
  final String name;

  const TypeEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class UserEntity extends Equatable {
  final int id;
  final String name;

  const UserEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class Category extends Equatable {
  final int id;
  final String name;

  final String? icon;
  final String? image;
  final String? description;
  final String? title;
  final String? subtitle;

  final TypeEntity? type;

  final int docstatus;
  final String status;
  final int disabled;

  final DateTime? updatedAt;
  final UserEntity? updatedBy;

  final DateTime? createdAt;
  final UserEntity? createdBy;
  final UserEntity? owner;

  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.image,
    this.description,
    this.title,
    this.subtitle,
    this.type,
    this.docstatus = 0,
    this.status = '',
    this.disabled = 0,
    this.updatedAt,
    this.updatedBy,
    this.createdAt,
    this.createdBy,
    this.owner,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    image,
    description,
    title,
    subtitle,
    type,
    docstatus,
    status,
    disabled,
    updatedAt,
    updatedBy,
    createdAt,
    createdBy,
    owner,
  ];
}
