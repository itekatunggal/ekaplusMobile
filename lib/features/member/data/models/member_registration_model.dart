import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';

class IdentityModel {
  static Identity? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    final id = json['id'];
    if (id == null) return null;

    return Identity(
      id: id is int ? id : int.tryParse(id.toString()) ?? 0,
      name: json['name'] ?? json['gpid_name'] ?? json['gcid_name'] ?? '',
    );
  }
}

class BranchModel {
  static Branch fromJson(Map<String, dynamic> json) {
    return Branch(id: json['id'], branchName: json['branch_name']);
  }
}

class MemberRegistrationModel {
  static MemberRegistration fromJson(Map<String, dynamic> json) {
    return MemberRegistration(
      id: json['id'],
      name: json['name'],
      businessName: json['business_name'],
      type: json['type'],
      entity: json['entity'],
      status: json['status'],
      docstatus: json['docstatus'],
      address: json['address'],
      province: json['province'],
      city: json['city'],
      district: json['district'],
      village: json['village'],
      rt: json['rt'],
      rw: json['rw'],
      postalCode: json['postal_code'],
      factoryAddress: json['factory_address'],
      email: json['email'],
      fax: json['fax'],
      contactPerson: json['contact_person'],
      nik: json['nik'],
      npwp: json['npwp'],
      ktpImage: json['ktp_image'],
      npwpImage: json['npwp_image'],
      branch: BranchModel.fromJson(json['branch']),
      user: UserModel.fromApiJson(json['user']),
      gpid: IdentityModel.fromJson(json['gpid']),
      gcid: IdentityModel.fromJson(json['gcid']),
      bcid: IdentityModel.fromJson(json['bcid']),
      owner: json['owner'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static List<MemberRegistration> fromJsonList(List<dynamic> list) {
    return list.map((e) => fromJson(e)).toList();
  }

  static Map<String, dynamic> toCreateJson(MemberRegistration entity) {
    return {
      'name': entity.name,
      'business_name': entity.businessName,
      'type': entity.type,
      'entity': entity.entity,
      'address': entity.address,
      'province': entity.province,
      'city': entity.city,
      'district': entity.district,
      'village': entity.village,
      'rt': entity.rt,
      'rw': entity.rw,
      'postal_code': entity.postalCode,
      'nik': entity.nik,
      'npwp': entity.npwp,
      'branch_id': entity.branch.id,
      'gpid_id': entity.gpid?.id,
      'gcid_id': entity.gcid?.id,
      'bcid_id': entity.bcid?.id,
      'contact_person': entity.contactPerson,
      'factory_address': entity.factoryAddress,
      'email': entity.email,
      'fax': entity.fax,
    };
  }

  static Map<String, dynamic> toUpdateJson(MemberRegistration entity) {
    return {
      'business_name': entity.businessName,
      'address': entity.address,
      'province': entity.province,
      'city': entity.city,
      'district': entity.district,
      'village': entity.village,
      'rt': entity.rt,
      'rw': entity.rw,
      'postal_code': entity.postalCode,
      'branch_id': entity.branch.id,
      'contact_person': entity.contactPerson,
      'factory_address': entity.factoryAddress,
      'email': entity.email,
      'fax': entity.fax,
    };
  }
}
