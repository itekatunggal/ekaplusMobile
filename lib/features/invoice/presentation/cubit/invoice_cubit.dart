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
  final Map<String, InvoiceStatusSummary> perStatus;
  final bool isLoadingMore;
  final bool hasMore;
  final bool loadMoreFailed;

  InvoiceLoaded(
    this.items, {
    this.perStatus = const {},
    this.isLoadingMore = false,
    this.hasMore = false,
    this.loadMoreFailed = false,
  });

  InvoiceLoaded copyWith({
    List<Invoice>? items,
    Map<String, InvoiceStatusSummary>? perStatus,
    bool? isLoadingMore,
    bool? hasMore,
    bool? loadMoreFailed,
  }) => InvoiceLoaded(
    items ?? this.items,
    perStatus: perStatus ?? this.perStatus,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );
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
  }) : _credentialService = credentialService ?? BranchCredentialService(),
       _invoiceService = invoiceService ?? InvoiceService(),
       super(InvoiceInitial());

  int _currentPage = 1;
  String? _baseUrl;
  String? _token;
  String? _bcid;

  Future<void> loadInvoices({
    required String branchCode,
    required String bcid,
  }) async {
    emit(InvoiceLoading());
    _currentPage = 1;

    // Step 1: ambil token + url
    final credential = await _credentialService.fetchCredential(branchCode);

    if (credential == null || credential.token.isEmpty) {
      emit(InvoiceUnauthorized('Credential tidak ditemukan untuk branch ini.'));
      return;
    }

    _baseUrl = credential.url;
    _token = credential.token;
    _bcid = bcid;

    // Step 2: fetch invoices pakai bcid dari activeCompany
    final result = await _invoiceService.fetchInvoices(
      baseUrl: credential.url,
      token: credential.token,
      bcid: bcid,
      doctype: 'Sales Invoice',
      page: _currentPage,
    );

    if (result.status == InvoiceFetchStatus.success) {
      emit(
        InvoiceLoaded(
          result.items,
          perStatus: result.perStatus,
          hasMore: _hasMore(result.items, result.perStatus),
        ),
      );
    } else if (result.status == InvoiceFetchStatus.unauthorized) {
      emit(InvoiceUnauthorized(result.message ?? 'Token tidak valid.'));
    } else {
      emit(InvoiceError(result.message ?? 'Terjadi kesalahan.'));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    final baseUrl = _baseUrl;
    final token = _token;
    final bcid = _bcid;
    if (current is! InvoiceLoaded ||
        current.isLoadingMore ||
        !current.hasMore ||
        baseUrl == null ||
        token == null ||
        bcid == null) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    final nextPage = _currentPage + 1;
    final result = await _invoiceService.fetchInvoices(
      baseUrl: baseUrl,
      token: token,
      bcid: bcid,
      doctype: 'Sales Invoice',
      page: nextPage,
    );

    if (result.status != InvoiceFetchStatus.success) {
      emit(current.copyWith(isLoadingMore: false, loadMoreFailed: true));
      return;
    }

    final merged = <String, Invoice>{
      for (final item in current.items) item.name: item,
      for (final item in result.items) item.name: item,
    };
    final addedCount = merged.length - current.items.length;
    final perStatus = result.perStatus.isEmpty
        ? current.perStatus
        : result.perStatus;
    _currentPage = nextPage;
    emit(
      InvoiceLoaded(
        merged.values.toList(),
        perStatus: perStatus,
        hasMore: addedCount > 0 && _hasMore(merged.values, perStatus),
      ),
    );
  }

  bool _hasMore(
    Iterable<Invoice> items,
    Map<String, InvoiceStatusSummary> perStatus,
  ) {
    final total = perStatus.values.fold<int>(
      0,
      (sum, summary) => sum + summary.totalCount,
    );
    return total > items.length;
  }
}
