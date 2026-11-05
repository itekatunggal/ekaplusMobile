enum MemberRegistrationIntent {
  newCompany,
  addBranchToExistingGroupCustomer,
}

extension MemberRegistrationIntentX on MemberRegistrationIntent {
  String get routeValue {
    switch (this) {
      case MemberRegistrationIntent.newCompany:
        return 'new_company';
      case MemberRegistrationIntent.addBranchToExistingGroupCustomer:
        return 'add_branch_existing_gcid';
    }
  }
}

MemberRegistrationIntent? memberRegistrationIntentFromRouteValue(dynamic value) {
  final raw = value?.toString();
  switch (raw) {
    case 'new_company':
      return MemberRegistrationIntent.newCompany;
    case 'add_branch_existing_gcid':
      return MemberRegistrationIntent.addBranchToExistingGroupCustomer;
    default:
      return null;
  }
}
