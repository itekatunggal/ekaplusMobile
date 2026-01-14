import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';

class Identity extends Equatable {
  final int id;
  final String name;

  const Identity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class MemberRegistration extends Equatable {
  final int id;
  final String name;
  final String businessName;
  final String type;
  final String entity;
  final String status;
  final int docstatus;

  final String address;
  final String province;
  final String city;
  final String district;
  final String village;
  final String rt;
  final String rw;
  final String postalCode;

  final String? factoryAddress;
  final String? email;
  final String? fax;
  final String? contactPerson;

  final String nik;
  final String? npwp;
  final String? ktpImage;
  final String? npwpImage;

  final Branch branch;
  final User user;

  final Identity? gpid;
  final Identity? gcid;
  final Identity? bcid;

  final int owner;
  final int? createdBy;
  final int? updatedBy;

  final DateTime createdAt;
  final DateTime updatedAt;

  const MemberRegistration({
    required this.id,
    required this.name,
    required this.businessName,
    required this.type,
    required this.entity,
    required this.status,
    required this.docstatus,
    required this.address,
    required this.province,
    required this.city,
    required this.district,
    required this.village,
    required this.rt,
    required this.rw,
    required this.postalCode,
    this.factoryAddress,
    this.email,
    this.fax,
    this.contactPerson,
    required this.nik,
    this.npwp,
    this.ktpImage,
    this.npwpImage,
    required this.branch,
    required this.user,
    required this.gpid,
    required this.gcid,
    required this.bcid,
    required this.owner,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    businessName,
    type,
    entity,
    status,
    docstatus,
    address,
    province,
    city,
    district,
    village,
    rt,
    rw,
    postalCode,
    factoryAddress,
    email,
    fax,
    contactPerson,
    nik,
    npwp,
    ktpImage,
    npwpImage,
    branch,
    user,
    gpid,
    gcid,
    bcid,
    owner,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];
}
