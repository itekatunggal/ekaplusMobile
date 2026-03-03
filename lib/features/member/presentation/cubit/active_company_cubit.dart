import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_active_member_companies_by_user_id.dart';

abstract class ActiveCompanyState {
  const ActiveCompanyState();
}

class ActiveCompanyInitial extends ActiveCompanyState {
  const ActiveCompanyInitial();
}

class ActiveCompanyLoading extends ActiveCompanyState {
  const ActiveCompanyLoading();
}

class ActiveCompanyReady extends ActiveCompanyState {
  final List<ActiveMemberCompany> companies;
  final ActiveMemberCompany? activeCompany;
  final int? activeBcid;

  const ActiveCompanyReady({
    required this.companies,
    required this.activeCompany,
    required this.activeBcid,
  });
}

class ActiveCompanyError extends ActiveCompanyState {
  final String message;

  const ActiveCompanyError(this.message);
}

class ActiveCompanyCubit extends Cubit<ActiveCompanyState> {
  final GetActiveMemberCompaniesByUserId getActiveMemberCompaniesByUserId;

  ActiveCompanyCubit({required this.getActiveMemberCompaniesByUserId})
    : super(const ActiveCompanyInitial());

  Future<void> loadCompaniesAndResolveActive({bool force = false}) async {
    if (!force && state is ActiveCompanyLoading) return;
    emit(const ActiveCompanyLoading());

    try {
      final result = await getActiveMemberCompaniesByUserId.execute();
      await result.fold((failure) async {
        emit(ActiveCompanyError(failure.message ?? 'Gagal memuat perusahaan aktif'));
      }, (companies) async {
        if (companies.isEmpty) {
          await SessionManager.clearActiveBranchCustomerId();
          emit(const ActiveCompanyReady(companies: [], activeCompany: null, activeBcid: null));
          return;
        }

        final storedBcid = await SessionManager.getActiveBranchCustomerId();
        ActiveMemberCompany? selected;
        if (storedBcid != null && storedBcid > 0) {
          for (final company in companies) {
            if (company.branchCustomerId == storedBcid) {
              selected = company;
              break;
            }
          }
        }
        selected ??= companies.first;
        final resolvedBcid = selected.branchCustomerId;
        if (resolvedBcid != null && resolvedBcid > 0) {
          await SessionManager.saveActiveBranchCustomerId(resolvedBcid);
        } else {
          await SessionManager.clearActiveBranchCustomerId();
        }
        emit(
          ActiveCompanyReady(
            companies: companies,
            activeCompany: selected,
            activeBcid: resolvedBcid,
          ),
        );
      });
    } catch (e) {
      emit(ActiveCompanyError('Gagal memuat perusahaan aktif: $e'));
    }
  }

  Future<void> refreshCompanies() async {
    await loadCompaniesAndResolveActive(force: true);
  }

  Future<void> reset() async {
    await SessionManager.clearActiveBranchCustomerId();
    emit(const ActiveCompanyInitial());
  }

  Future<bool> setActiveCompany(ActiveMemberCompany company) async {
    final bcid = company.branchCustomerId;
    if (bcid == null || bcid <= 0) return false;

    final current = state;
    List<ActiveMemberCompany> companies;
    if (current is ActiveCompanyReady) {
      companies = current.companies;
    } else {
      final result = await getActiveMemberCompaniesByUserId.execute();
      companies = result.fold((_) => <ActiveMemberCompany>[], (data) => data);
    }

    await SessionManager.saveActiveBranchCustomerId(bcid);
    emit(
      ActiveCompanyReady(
        companies: companies,
        activeCompany: company,
        activeBcid: bcid,
      ),
    );
    return true;
  }
}
