import 'package:equatable/equatable.dart';

class ActiveMemberCompanyDetail extends Equatable {
  final int bcidId;
  final String? bcidCode;
  final String? branchCustomerName;
  final int? gcidId;
  final String? gcName;
  final int? gpidId;
  final String? gpCode;
  final String? gpName;
  final int? nbidId;
  final String? nbName;
  final int? branchId;
  final String? branchName;
  final String? branchCity;
  final String? ownerFullName;
  final String? ownerPhone;
  final String? ownerEmail;
  final String? ownerPlaceOfBirth;
  final String? ownerDateOfBirth;
  final String? companyType;
  final String? companyTitle;
  final String? companyName;
  final String? productNeed;
  final bool memberIsOwner;
  final bool memberIsSharing;
  final List<ActiveCompanyAddress> addresses;
  final List<ActiveCompanyContact> contacts;

  const ActiveMemberCompanyDetail({
    required this.bcidId,
    this.bcidCode,
    this.branchCustomerName,
    this.gcidId,
    this.gcName,
    this.gpidId,
    this.gpCode,
    this.gpName,
    this.nbidId,
    this.nbName,
    this.branchId,
    this.branchName,
    this.branchCity,
    this.ownerFullName,
    this.ownerPhone,
    this.ownerEmail,
    this.ownerPlaceOfBirth,
    this.ownerDateOfBirth,
    this.companyType,
    this.companyTitle,
    this.companyName,
    this.productNeed,
    this.memberIsOwner = false,
    this.memberIsSharing = false,
    this.addresses = const [],
    this.contacts = const [],
  });

  String get displayName {
    final gc = (gcName ?? '').trim();
    final city = (branchCity ?? '').trim();
    if (gc.isNotEmpty && city.isNotEmpty) return '$gc - $city';
    if (gc.isNotEmpty) return gc;
    if ((bcidCode ?? '').trim().isNotEmpty) return bcidCode!;
    return 'BCID #$bcidId';
  }

  @override
  List<Object?> get props => [
    bcidId,
    bcidCode,
    branchCustomerName,
    gcidId,
    gcName,
    gpidId,
    gpCode,
    gpName,
    nbidId,
    nbName,
    branchId,
    branchName,
    branchCity,
    ownerFullName,
    ownerPhone,
    ownerEmail,
    ownerPlaceOfBirth,
    ownerDateOfBirth,
    companyType,
    companyTitle,
    companyName,
    productNeed,
    memberIsOwner,
    memberIsSharing,
    addresses,
    contacts,
  ];
}

class ActiveCompanyAddress extends Equatable {
  final int id;
  final String? type;
  final String? label;
  final String? address;
  final String? city;
  final String? district;
  final String? province;
  final String? postalCode;
  final bool isDefault;
  final int? picContactId;
  final String? picName;
  final String? picPhone;
  final int? idxRow;

  const ActiveCompanyAddress({
    required this.id,
    this.type,
    this.label,
    this.address,
    this.city,
    this.district,
    this.province,
    this.postalCode,
    this.isDefault = false,
    this.picContactId,
    this.picName,
    this.picPhone,
    this.idxRow,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    label,
    address,
    city,
    district,
    province,
    postalCode,
    isDefault,
    picContactId,
    picName,
    picPhone,
    idxRow,
  ];
}

class ActiveCompanyContact extends Equatable {
  final int customerContactId;
  final int contactId;
  final String? name;
  final String? fullName;
  final String? phone;
  final String? email;
  final int? positionId;
  final String? positionName;
  final String? title;
  final bool isPrimary;
  final int? idxRow;
  final List<ActiveCompanyContactIdentity> identities;

  const ActiveCompanyContact({
    required this.customerContactId,
    required this.contactId,
    this.name,
    this.fullName,
    this.phone,
    this.email,
    this.positionId,
    this.positionName,
    this.title,
    this.isPrimary = false,
    this.idxRow,
    this.identities = const [],
  });

  @override
  List<Object?> get props => [
    customerContactId,
    contactId,
    name,
    fullName,
    phone,
    email,
    positionId,
    positionName,
    title,
    isPrimary,
    idxRow,
    identities,
  ];
}

class ActiveCompanyContactIdentity extends Equatable {
  final int id;
  final int contactId;
  final String? channel;
  final String? handle;
  final String? externalId;
  final bool isVerified;

  const ActiveCompanyContactIdentity({
    required this.id,
    required this.contactId,
    this.channel,
    this.handle,
    this.externalId,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [id, contactId, channel, handle, externalId, isVerified];
}

