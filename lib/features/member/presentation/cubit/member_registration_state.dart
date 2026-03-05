// lib/features/member/presentation/cubit/member_registration_state.dart
part of 'member_registration_cubit.dart';

abstract class MemberRegistrationState {
  const MemberRegistrationState();
}

// Initial State
class MemberRegistrationInitial extends MemberRegistrationState {
  const MemberRegistrationInitial();
}

// Loading State
class MemberRegistrationLoading extends MemberRegistrationState {
  const MemberRegistrationLoading();
}

// Error State
class MemberRegistrationError extends MemberRegistrationState {
  final String message;

  const MemberRegistrationError(this.message);
}

// Success State
class MemberRegistrationSuccess extends MemberRegistrationState {
  const MemberRegistrationSuccess();
}

class MemberRegistrationDraftSaved extends MemberRegistrationState {
  final MemberRegistration registration;

  const MemberRegistrationDraftSaved(this.registration);
}

class MemberRegistrationDraftDeleted extends MemberRegistrationState {
  final int registrationId;

  const MemberRegistrationDraftDeleted(this.registrationId);
}

// Branches Loaded
class MemberRegistrationBranchesLoaded extends MemberRegistrationState {
  final List<BranchModel> branches;

  const MemberRegistrationBranchesLoaded(this.branches);
}

// Provinces Loaded
class MemberRegistrationProvincesLoaded extends MemberRegistrationState {
  final List<ProvinceModel> provinces;

  const MemberRegistrationProvincesLoaded(this.provinces);
}

// Regencies Loaded
class MemberRegistrationRegenciesLoaded extends MemberRegistrationState {
  final List<RegencyModel> regencies;

  const MemberRegistrationRegenciesLoaded(this.regencies);
}

// Districts Loaded
class MemberRegistrationDistrictsLoaded extends MemberRegistrationState {
  final List<DistrictModel> districts;

  const MemberRegistrationDistrictsLoaded(this.districts);
}

// Villages Loaded
class MemberRegistrationVillagesLoaded extends MemberRegistrationState {
  final List<VillageModel> villages;

  const MemberRegistrationVillagesLoaded(this.villages);
}

// User Registrations Loaded
class MemberRegistrationUserRegistrationsLoaded extends MemberRegistrationState {
  final List<MemberRegistration> registrations;

  const MemberRegistrationUserRegistrationsLoaded(this.registrations);
}

// Approved GCIDs Loaded
class MemberRegistrationApprovedGCIDsLoaded extends MemberRegistrationState {
  final List<MemberRegistration> gcids;

  const MemberRegistrationApprovedGCIDsLoaded(this.gcids);
}

// All Registrations Loaded
class MemberRegistrationAllRegistrationsLoaded extends MemberRegistrationState {
  final List<MemberRegistration> registrations;

  const MemberRegistrationAllRegistrationsLoaded(this.registrations);
}

class MemberRegistrationActiveCompaniesLoading extends MemberRegistrationState {
  const MemberRegistrationActiveCompaniesLoading();
}

class MemberRegistrationActiveCompaniesLoaded extends MemberRegistrationState {
  final List<ActiveMemberCompany> companies;

  const MemberRegistrationActiveCompaniesLoaded(this.companies);
}

class MemberRegistrationActiveCompaniesError extends MemberRegistrationState {
  final String message;

  const MemberRegistrationActiveCompaniesError(this.message);
}

// === SHIPPING ADDRESS STATES ===

// Shipping Provinces Loaded
class MemberRegistrationShippingProvincesLoaded extends MemberRegistrationState {
  final String addressId;
  final List<ProvinceModel> provinces;

  const MemberRegistrationShippingProvincesLoaded(this.addressId, this.provinces);
}

// Shipping Regencies Loaded
class MemberRegistrationShippingRegenciesLoaded extends MemberRegistrationState {
  final String addressId;
  final List<RegencyModel> regencies;

  const MemberRegistrationShippingRegenciesLoaded(this.addressId, this.regencies);
}

// Shipping Districts Loaded
class MemberRegistrationShippingDistrictsLoaded extends MemberRegistrationState {
  final String addressId;
  final List<DistrictModel> districts;

  const MemberRegistrationShippingDistrictsLoaded(this.addressId, this.districts);
}
