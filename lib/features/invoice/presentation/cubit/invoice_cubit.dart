import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/branch_credential_service.dart';
import 'package:ekaplus_ekatunggal/features/invoice/data/services/invoice_service.dart';
import 'package:ekaplus_ekatunggal/features/invoice/data/models/invoice_model.dart';

// ── State ──────────────────────────────────────────────────────────────────
abstract class InvoiceState {}
class InvoiceInitial extends InvoiceState {}
class InvoiceLoading extends InvoiceState {}
class InvoiceLoaded extends InvoiceState {
  final List<Invoice> items;
  InvoiceLoaded(this.items);
}
class InvoiceUnauthorized extends InvoiceState {
  final String message;
  InvoiceUnauthorized(this.message);
}
class InvoiceError extends InvoiceState {
  final String message;
  InvoiceError(this.message);
}

// ── Cubit ──────────────────────────────────────────────────────────────────
class InvoiceCubit extends Cubit<InvoiceState> {
  final BranchCredentialService _credentialService;
  final InvoiceService _invoiceService;

  InvoiceCubit({
    BranchCredentialService? credentialService,
    InvoiceService? invoiceService,
  })  : _credentialService = credentialService ?? BranchCredentialService(),
        _invoiceService = invoiceService ?? InvoiceService(),
        super(InvoiceInitial());

  Future<void> loadInvoices({
    required String branchCode,
    required String bcid,
  }) async {
    emit(InvoiceLoading());

    // Step 1: ambil token + url
    final credential = await _credentialService.fetchCredential(branchCode);
    print("📡 Step 1 - url=${credential?.url}, token=${credential?.token}");

    if (credential == null || credential.token.isEmpty) {
      emit(InvoiceUnauthorized('Credential tidak ditemukan untuk branch ini.'));
      return;
    }

    // Step 2: fetch invoices pakai bcid dari activeCompany
    final result = await _invoiceService.fetchInvoices(
      baseUrl: credential.url,
      token: credential.token,
      bcid: bcid,
      doctype: 'Sales Invoice',
    );
    print("📦 Step 2 - status: ${result.status}, items: ${result.items.length}");

    if (result.status == InvoiceFetchStatus.success) {
      emit(InvoiceLoaded(result.items));
    } else if (result.status == InvoiceFetchStatus.unauthorized) {
      emit(InvoiceUnauthorized(result.message ?? 'Token tidak valid.'));
    } else {
      emit(InvoiceError(result.message ?? 'Terjadi kesalahan.'));
    }
  }
}