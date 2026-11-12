import 'package:equatable/equatable.dart';

class SalesProfile extends Equatable {
  const SalesProfile({
    required this.id,
    required this.name,
    required this.position,
    required this.division,
    required this.branchId,
    this.photoUrl,
    this.workWhatsapp,
    this.workPhone,
    required this.description,
    this.isDemo = false,
  });

  final int id;
  final String name;
  final String position;
  final String division;
  final int branchId;
  final String? photoUrl;
  final String? workWhatsapp;
  final String? workPhone;
  final String description;
  final bool isDemo;

  @override
  List<Object?> get props => [
    id,
    name,
    position,
    division,
    branchId,
    photoUrl,
    workWhatsapp,
    workPhone,
    description,
    isDemo,
  ];
}
