import 'package:equatable/equatable.dart';

class ActiveMemberCompany extends Equatable {
  final int memberOfId;
  final String refType;
  final int refId;
  final int userId;
  final String? memberOfStatus;

  final int? branchCustomerId;
  final String? branchCustomerCode;
  final int? branchId;
  final String? branchName;
  final String? branchCity;

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
    this.branchCustomerId,
    this.branchCustomerCode,
    this.branchId,
    this.branchName,
    this.branchCity,
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

  @override
  List<Object?> get props => [
    memberOfId,
    refType,
    refId,
    userId,
    memberOfStatus,
    branchCustomerId,
    branchCustomerCode,
    branchId,
    branchName,
    branchCity,
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
