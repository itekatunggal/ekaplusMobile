import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/branch_credential_service.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/sales_order_service.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_model.dart';

// ── State ──────────────────────────────────────────────────────────────────
abstract class SalesOrderState {}
class SalesOrderInitial extends SalesOrderState {}
class SalesOrderLoading extends SalesOrderState {}
class SalesOrderLoaded extends SalesOrderState {
  final List<SalesOrder> items;
  SalesOrderLoaded(this.items);
}
class SalesOrderUnauthorized extends SalesOrderState {
  final String message;
  SalesOrderUnauthorized(this.message);
}
class SalesOrderError extends SalesOrderState {
  final String message;
  SalesOrderError(this.message);
}

// ── Cubit ──────────────────────────────────────────────────────────────────
class SalesOrderCubit extends Cubit<SalesOrderState> {
  final BranchCredentialService _credentialService;
  final SalesOrderService _salesOrderService;

  SalesOrderCubit({
    BranchCredentialService? credentialService,
    SalesOrderService? salesOrderService,
  })  : _credentialService = credentialService ?? BranchCredentialService(),
        _salesOrderService = salesOrderService ?? SalesOrderService(),
        super(SalesOrderInitial());

  Future<void> loadSalesOrder({
    required String branchCode,
    required String bcid,
  }) async {
    emit(SalesOrderLoading());

    // Step 1: ambil token + url
    final credential = await _credentialService.fetchCredential(branchCode);
    print("📡 Step 1 - url=${credential?.url}, token=${credential?.token}");

    if (credential == null || credential.token.isEmpty) {
      emit(SalesOrderUnauthorized('Credential tidak ditemukan untuk branch ini.'));
      return;
    }

    // Step 2: fetch invoices pakai bcid dari activeCompany
    final result = await _salesOrderService.fetchSalesOrder(
      baseUrl: credential.url,
      token: credential.token,
      bcid: bcid,
      doctype: 'Sales Order',
    );
    print("📦 Step 2 - status: ${result.status}, items: ${result.items.length}");

    if (result.status == SalesOrderFetchStatus.success) {
      emit(SalesOrderLoaded(result.items));
    } else if (result.status == SalesOrderFetchStatus.unauthorized) {
      emit(SalesOrderUnauthorized(result.message ?? 'Token tidak valid.'));
    } else {
      emit(SalesOrderError(result.message ?? 'Terjadi kesalahan.'));
    }
  }
}