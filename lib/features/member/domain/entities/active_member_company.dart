import 'package:equatable/equatable.dart';

class ActiveMemberCompany extends Equatable {
  final int memberOfId;
  final String refType;
  final int refId;
  final int userId;
  final String? memberOfStatus;
  final bool memberIsOwner;
  final bool memberIsSharing;
  final int? shareFromUserId;

  final int? branchCustomerId;
  final String? branchCustomerCode;
  final int? branchId;
  final String? branchName;
  final String? branchCity;
  final String? branchOwnerName;
  final String? branchOwnerPhone;
  final String? branchOwnerEmail;
  final String? branchOwnerPlaceOfBirth;
  final String? branchOwnerDateOfBirth;

  final int? gcidId;
  final String? gcName;

  final int? gpidId;
  final String? gpCode;
  final String? gpName;

  final int? nbidId;
  final String? nbName;

  final int? customerRegisterId;
  final String? customerRegisterStatus;
  final String? customerOwnerName;
  final String? customerOwnerEmail;
  final String? customerOwnerPhone;
  final String? customerOwnerPlaceOfBirth;
  final String? customerOwnerDateOfBirth;
  final String? customerCompanyName;
  final String? customerCompanyType;
  final String? customerCompanyTitle;
  final String? customerProductNeed;
  final String? customerCompanyAddress;
  final String? customerCompanyProvince;
  final String? customerCompanyCity;
  final String? customerCompanyDistrict;
  final String? customerCompanyPostalCode;

  final DateTime? createdAt;

  const ActiveMemberCompany({
    required this.memberOfId,
    required this.refType,
    required this.refId,
    required this.userId,
    this.memberOfStatus,
    this.memberIsOwner = false,
    this.memberIsSharing = false,
    this.shareFromUserId,
    this.branchCustomerId,
    this.branchCustomerCode,
    this.branchId,
    this.branchName,
    this.branchCity,
    this.branchOwnerName,
    this.branchOwnerPhone,
    this.branchOwnerEmail,
    this.branchOwnerPlaceOfBirth,
    this.branchOwnerDateOfBirth,
    this.gcidId,
    this.gcName,
    this.gpidId,
    this.gpCode,
    this.gpName,
    this.nbidId,
    this.nbName,
    this.customerRegisterId,
    this.customerRegisterStatus,
    this.customerOwnerName,
    this.customerOwnerEmail,
    this.customerOwnerPhone,
    this.customerOwnerPlaceOfBirth,
    this.customerOwnerDateOfBirth,
    this.customerCompanyName,
    this.customerCompanyType,
    this.customerCompanyTitle,
    this.customerProductNeed,
    this.customerCompanyAddress,
    this.customerCompanyProvince,
    this.customerCompanyCity,
    this.customerCompanyDistrict,
    this.customerCompanyPostalCode,
    this.createdAt,
  });

  String get displayName {
    final gc = (gcName ?? '').trim();
    final city = (branchCity ?? '').trim();
    if (gc.isNotEmpty && city.isNotEmpty) return '$gc - $city';
    if (gc.isNotEmpty) return gc;
    if ((branchCustomerCode ?? '').trim().isNotEmpty) return branchCustomerCode!;
    return 'BCID #$refId';
  }

  String get bcidDisplayLabel {
    final code = (branchCustomerCode ?? '').trim();
    if (code.isNotEmpty) return code;
    final id = branchCustomerId;
    if (id != null && id > 0) return 'BCID #$id';
    return 'BCID';
  }

  @override
  List<Object?> get props => [
    memberOfId,
    refType,
    refId,
    userId,
    memberOfStatus,
    memberIsOwner,
    memberIsSharing,
    shareFromUserId,
    branchCustomerId,
    branchCustomerCode,
    branchId,
    branchName,
    branchCity,
    branchOwnerName,
    branchOwnerPhone,
    branchOwnerEmail,
    branchOwnerPlaceOfBirth,
    branchOwnerDateOfBirth,
    gcidId,
    gcName,
    gpidId,
    gpCode,
    gpName,
    nbidId,
    nbName,
    customerRegisterId,
    customerRegisterStatus,
    customerOwnerName,
    customerOwnerEmail,
    customerOwnerPhone,
    customerOwnerPlaceOfBirth,
    customerOwnerDateOfBirth,
    customerCompanyName,
    customerCompanyType,
    customerCompanyTitle,
    customerProductNeed,
    customerCompanyAddress,
    customerCompanyProvince,
    customerCompanyCity,
    customerCompanyDistrict,
    customerCompanyPostalCode,
    createdAt,
  ];
}
