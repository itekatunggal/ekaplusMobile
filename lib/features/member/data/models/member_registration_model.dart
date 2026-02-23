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
  static int _branchSafeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static Branch fromJson(Map<String, dynamic> json) {
    final branchId = _branchSafeInt(json['id']);
    return Branch(
      id: branchId,
      branchName: (json['branch_name'] ?? json['name'] ?? 'Cabang $branchId')
          .toString(),
      city: json['city']?.toString(),
      area: json['area']?.toString(),
    );
  }
}

class MemberRegistrationModel {
  static int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _safeNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static String _safeString(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    final s = v.toString();
    return s;
  }

  static DateTime _safeDate(dynamic v) {
    if (v == null) return DateTime.now();
    final s = v.toString().trim();
    if (s.isEmpty) return DateTime.now();
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  static Branch _branchFromJson(Map<String, dynamic> json) {
    final branchJson = json['branch'];
    final branchIdJson = json['branch_id'];

    if (branchJson is Map<String, dynamic>) {
      return BranchModel.fromJson(branchJson);
    }

    if (branchIdJson is Map<String, dynamic>) {
      return BranchModel.fromJson({
        'id': branchIdJson['id'] ?? branchIdJson['value'] ?? json['branch_id'],
        'branch_name': branchIdJson['branch_name'] ?? json['branch_id.branch_name'],
        'city': branchIdJson['city'] ?? json['branch_id.city'],
        'area': branchIdJson['area'] ?? json['branch_id.area'],
      });
    }

    final branchId = _safeInt(json['branch_id']);
    final branchName = _safeString(json['branch_id.branch_name']);
    final branchCity = _safeString(json['branch_id.city']);
    return Branch(
      id: branchId,
      branchName: branchName.isEmpty
          ? (branchId == 0 ? '-' : 'Cabang $branchId')
          : branchName,
      city: branchCity.isEmpty ? null : branchCity,
    );
  }

  static UserModel _emptyUser(Map<String, dynamic> json) {
    return UserModel(
      id: _safeInt(json['owner']),
      firstName: '',
      lastName: '',
      fullName: _safeString(json['owner_full_name']),
      username: '',
      email: _safeString(json['owner_email']),
      phone: _safeString(json['owner_phone']),
      isEmailVerified: false,
      isPhoneVerified: false,
      isSystem: false,
      gender: '',
      password: '',
      dateOfBirth: DateTime.tryParse(_safeString(json['owner_date_of_birth'])),
      placeOfBirth: _safeString(json['owner_place_of_birth']),
      profilePic: '',
      referralCode: '',
      referredBy: null,
      address: _safeString(json['company_address']),
      city: _safeString(json['company_city']),
      province: _safeString(json['company_province']),
      postalCode: _safeString(json['company_postal_code']),
      country: 'ID',
      googleId: '',
      googleAccessToken: '',
      googleRefreshToken: '',
      googleTokenExpiry: null,
      role: '',
      status: 1,
      workflowState: '',
      tokenVersion: 0,
      lastLogin: null,
      createdBy: _safeNullableInt(json['created_by']),
      updatedBy: _safeNullableInt(json['updated_by']),
      createdAt: _safeDate(json['created_at']),
      updatedAt: _safeDate(json['updated_at']),
    );
  }

  static MemberRegistration fromJson(Map<String, dynamic> json) {
    final isNewCustomerRegisterSchema =
        json.containsKey('company_name') || json.containsKey('owner_full_name');

    return MemberRegistration(
      id: _safeInt(json['id']),
      name: _safeString(json['name']),
      businessName: _safeString(
        isNewCustomerRegisterSchema ? json['company_name'] : json['business_name'],
      ),
      type: _safeString(isNewCustomerRegisterSchema ? json['source'] : json['type']),
      entity: _safeString(
        isNewCustomerRegisterSchema ? json['company_type'] : json['entity'],
      ),
      companyTitle: _safeString(json['company_title']).isEmpty
          ? null
          : _safeString(json['company_title']),
      productNeed: _safeString(json['product_need']).isEmpty
          ? null
          : _safeString(json['product_need']),
      status: _safeString(json['status'], fallback: 'Draft'),
      docstatus: _safeInt(json['docstatus']),
      address: _safeString(
        isNewCustomerRegisterSchema ? json['company_address'] : json['address'],
      ),
      province: _safeString(
        isNewCustomerRegisterSchema ? json['company_province'] : json['province'],
      ),
      city: _safeString(isNewCustomerRegisterSchema ? json['company_city'] : json['city']),
      district: _safeString(
        isNewCustomerRegisterSchema ? json['company_district'] : json['district'],
      ),
      village: _safeString(json['village']),
      rt: _safeString(json['rt']),
      rw: _safeString(json['rw']),
      postalCode: _safeString(
        isNewCustomerRegisterSchema ? json['company_postal_code'] : json['postal_code'],
      ),
      factoryAddress: _safeString(json['factory_address']).isEmpty
          ? null
          : _safeString(json['factory_address']),
      email: _safeString(json['email']).isEmpty
          ? (_safeString(json['owner_email']).isEmpty ? null : _safeString(json['owner_email']))
          : _safeString(json['email']),
      fax: _safeString(json['fax']).isEmpty ? null : _safeString(json['fax']),
      contactPerson: _safeString(json['contact_person']).isEmpty
          ? (_safeString(json['owner_full_name']).isEmpty
              ? null
              : _safeString(json['owner_full_name']))
          : _safeString(json['contact_person']),
      nik: _safeString(json['nik']),
      npwp: _safeString(json['npwp']).isEmpty ? null : _safeString(json['npwp']),
      ktpImage: _safeString(json['ktp_image']).isEmpty ? null : _safeString(json['ktp_image']),
      npwpImage: _safeString(json['npwp_image']).isEmpty
          ? null
          : _safeString(json['npwp_image']),
      branch: _branchFromJson(json),
      user: (json['user'] is Map<String, dynamic>)
          ? UserModel.fromApiJson(json['user'] as Map<String, dynamic>)
          : _emptyUser(json),
      gpid: json['gpid'] is Map<String, dynamic>
          ? IdentityModel.fromJson(json['gpid'] as Map<String, dynamic>)
          : null,
      gcid: json['gcid'] is Map<String, dynamic>
          ? IdentityModel.fromJson(json['gcid'] as Map<String, dynamic>)
          : null,
      bcid: json['bcid'] is Map<String, dynamic>
          ? IdentityModel.fromJson(json['bcid'] as Map<String, dynamic>)
          : null,
      owner: _safeInt(json['owner']),
      createdBy: _safeNullableInt(json['created_by']),
      updatedBy: _safeNullableInt(json['updated_by']),
      createdAt: _safeDate(json['created_at']),
      updatedAt: _safeDate(json['updated_at']),
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
