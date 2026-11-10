import 'dart:async';

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/core/theme/app_card_styles.dart';
import 'package:ekaplus_ekatunggal/features/invoice/data/models/invoice_model.dart';
import 'package:ekaplus_ekatunggal/features/invoice/data/services/invoice_detail_service.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/branch_credential_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'invoice_detail_page.dart';

enum _InvoiceGroup { all, payment, overdue, returns, paid }

enum _InvoiceSort { invoiceNumber, postingDate, dueDate }

const _groupStatuses = <_InvoiceGroup, Set<String>>{
  _InvoiceGroup.payment: {'Submitted', 'Unpaid', 'Partly Paid'},
  _InvoiceGroup.overdue: {'Overdue'},
  _InvoiceGroup.returns: {'Return', 'Credit Note Issued'},
  _InvoiceGroup.paid: {'Paid'},
};

const _allowedInvoiceStatuses = {
  'Submitted',
  'Unpaid',
  'Partly Paid',
  'Overdue',
  'Return',
  'Credit Note Issued',
  'Paid',
};

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  static const _statusOptions = [
    'Semua',
    'Submitted',
    'Unpaid',
    'Partly Paid',
    'Overdue',
    'Return',
    'Credit Note Issued',
    'Paid',
  ];

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String _searchQuery = '', _branchCode = '', _bcid = '';
  String? _configurationError, _filterStatus;
  DateTime? _filterStartDate, _filterEndDate;
  bool _openingDetail = false;
  _InvoiceGroup _selectedGroup = _InvoiceGroup.all;
  _InvoiceSort _sortBy = _InvoiceSort.postingDate;
  bool _sortAscending = false;

  bool get _hasCustomSort =>
      _sortBy != _InvoiceSort.postingDate || _sortAscending;

  bool get _hasActiveFilter =>
      _filterStartDate != null ||
      _filterEndDate != null ||
      _filterStatus != null ||
      _hasCustomSort;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(_initialize);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final state = context.read<ActiveCompanyCubit>().state;
    if (state is ActiveCompanyReady) {
      _branchCode = state.activeCompany?.branchName ?? '';
      _bcid = state.activeCompany?.branchCustomerCode ?? '';
    }
    if (_branchCode.isEmpty || _bcid.isEmpty) {
      if (mounted) {
        setState(
          () => _configurationError =
              'Pilih perusahaan aktif agar sales invoice dapat dimuat.',
        );
      }
      return;
    }
    await _reload();
  }

  Future<void> _reload() async {
    if (_branchCode.isEmpty || _bcid.isEmpty) return;
    setState(() {
      _configurationError = null;
    });
    await context.read<InvoiceCubit>().loadInvoices(
      branchCode: _branchCode,
      bcid: _bcid,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 240) {
      return;
    }
    final state = context.read<InvoiceCubit>().state;
    if (state is InvoiceLoaded &&
        state.hasMore &&
        !state.isLoadingMore &&
        !state.loadMoreFailed) {
      context.read<InvoiceCubit>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {}); // refresh clear icon immediately
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.trim().toLowerCase();
      });
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _searchQuery = '';
    });
  }

  List<Invoice> _filteredList(List<Invoice> invoices) {
    final filtered = invoices.where((item) {
      if (!_allowedInvoiceStatuses.contains(item.status)) return false;
      if (_selectedGroup != _InvoiceGroup.all &&
          !_groupStatuses[_selectedGroup]!.contains(item.status)) {
        return false;
      }
      if (_filterStatus != null && item.status != _filterStatus) return false;
      final due = DateTime.tryParse(item.dueDate);
      if (_filterStartDate != null &&
          due != null &&
          due.isBefore(_filterStartDate!)) {
        return false;
      }
      if (_filterEndDate != null && due != null) {
        final end = DateTime(
          _filterEndDate!.year,
          _filterEndDate!.month,
          _filterEndDate!.day,
          23,
          59,
          59,
        );
        if (due.isAfter(end)) return false;
      }
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery) ||
          item.customer.toLowerCase().contains(_searchQuery) ||
          item.customerName.toLowerCase().contains(_searchQuery);
    }).toList();
    filtered.sort(_compareInvoices);
    return filtered;
  }

  int _compareInvoices(Invoice a, Invoice b) {
    switch (_sortBy) {
      case _InvoiceSort.invoiceNumber:
        final left = a.name.trim().toLowerCase();
        final right = b.name.trim().toLowerCase();
        if (left.isEmpty) return right.isEmpty ? 0 : 1;
        if (right.isEmpty) return -1;
        return _sortAscending ? left.compareTo(right) : right.compareTo(left);
      case _InvoiceSort.postingDate:
        return _compareDates(a.postingDate, b.postingDate);
      case _InvoiceSort.dueDate:
        return _compareDates(a.dueDate, b.dueDate);
    }
  }

  int _compareDates(String leftValue, String rightValue) {
    final left = DateTime.tryParse(leftValue);
    final right = DateTime.tryParse(rightValue);
    if (left == null) return right == null ? 0 : 1;
    if (right == null) return -1;
    return _sortAscending ? left.compareTo(right) : right.compareTo(left);
  }

  Future<void> _openDetail(Invoice invoice) async {
    if (_openingDetail) return;
    setState(() => _openingDetail = true);
    try {
      final credential = await BranchCredentialService().fetchCredential(
        _branchCode,
      );
      if (credential == null) {
        throw Exception('Credential cabang tidak ditemukan.');
      }
      final detail = await InvoiceDetailService().fetchDetail(
        baseUrl: credential.url,
        token: credential.token,
        invoiceName: invoice.name,
      );
      if (!mounted) return;
      if (detail == null) throw Exception('Detail invoice gagal dimuat.');
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InvoiceDetailPage(invoice: detail.toDetailMap()),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: 'Detail invoice belum dapat dibuka. Silakan coba lagi.',
        type: AppSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _openingDetail = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F7F9),
    body: Column(
      children: [
        _buildHeader(),
        if (_hasActiveFilter) _buildActiveFilters(),
        Expanded(
          child: Stack(
            children: [
              BlocBuilder<InvoiceCubit, InvoiceState>(
                builder: (context, state) {
                  if (_configurationError != null) {
                    return _StateView(
                      icon: Icons.business_outlined,
                      title: 'Perusahaan belum dipilih',
                      message: _configurationError!,
                    );
                  }
                  if (state is InvoiceLoading || state is InvoiceInitial) {
                    return const _InvoiceSkeleton();
                  }
                  if (state is InvoiceUnauthorized) {
                    return _StateView(
                      icon: Icons.lock_outline_rounded,
                      title: 'Akses invoice berakhir',
                      message: state.message,
                      actionLabel: 'Coba lagi',
                      onAction: _reload,
                    );
                  }
                  if (state is InvoiceError) {
                    return _StateView(
                      icon: Icons.cloud_off_rounded,
                      title: 'Sales invoice gagal dimuat',
                      message: state.message,
                      actionLabel: 'Coba lagi',
                      onAction: _reload,
                    );
                  }
                  if (state is InvoiceLoaded) return _buildLoaded(state);
                  return const SizedBox.shrink();
                },
              ),
              if (_openingDetail)
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0x330F172A),
                    child: const Center(
                      child: _LoadingBox(label: 'Memuat detail invoice...'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildHeader() => SizedBox(
    height: 178,
    child: Stack(
      children: [
        Positioned.fill(
          child: CustomHeaderAppBar(
            title: 'Sales Invoice',
            brandStyle: true,
            showBackButton: true,
            height: 178,
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomHeaderActionButton(
                    tooltip: 'Filter invoice',
                    onPressed: _showFilterSheet,
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  if (_hasActiveFilter)
                    const Positioned(
                      right: 1,
                      top: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 8, height: 8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: CustomHeaderSearchField(
            controller: _searchController,
            hintText: 'Cari nomor invoice atau customer...',
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
        ),
      ],
    ),
  );

  Widget _buildLoaded(InvoiceLoaded state) {
    final filtered = _filteredList(state.items);
    return Column(
      children: [
        _buildStatusTabs(state),
        // _buildGroupSummary(state),
        Expanded(
          child: filtered.isEmpty
              ? _buildGroupEmptyState()
              : RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: _reload,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index < filtered.length) {
                        return _InvoiceCard(
                          invoice: filtered[index],
                          onTap: _openDetail,
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: state.isLoadingMore
                            ? const Center(
                                child: SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              )
                            : state.loadMoreFailed
                            ? TextButton.icon(
                                onPressed: () =>
                                    context.read<InvoiceCubit>().loadMore(),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 16,
                                ),
                                label: const Text('Coba muat lagi'),
                              )
                            : state.hasMore
                            ? const SizedBox(height: 20)
                            : Text(
                                'Semua ${filtered.length} invoice sudah ditampilkan',
                                textAlign: TextAlign.center,
                                style: _style(
                                  10,
                                  FontWeight.w500,
                                  const Color(0xFF94A3B8),
                                ),
                              ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusTabs(InvoiceLoaded state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: _InvoiceGroup.values.map((group) {
          final selected = group == _selectedGroup;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() {
                _selectedGroup = group;
                _filterStatus = null;
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryColor
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      _groupLabel(group),
                      style: _style(
                        10.5,
                        FontWeight.w700,
                        selected ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withOpacity(.22)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_groupCount(state, group)}',
                        style: _style(
                          9,
                          FontWeight.w700,
                          selected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget _buildGroupSummary(InvoiceLoaded state) {
  //   final count = _groupCount(state, _selectedGroup);
  //   final outstanding = _groupOutstanding(state, _selectedGroup);
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
  //     child: Row(
  //       children: [
  //         const Icon(
  //           Icons.receipt_long_outlined,
  //           size: 14,
  //           color: Color(0xFF94A3B8),
  //         ),
  //         const SizedBox(width: 6),
  //         Expanded(
  //           child: Text(
  //             '$count invoice',
  //             style: _style(10, FontWeight.w500, const Color(0xFF64748B)),
  //           ),
  //         ),
  //         Text(
  //           'Outstanding ${_money(outstanding, 'IDR')}',
  //           style: _style(
  //             10,
  //             FontWeight.w600,
  //             outstanding > 0
  //                 ? AppColors.primaryColor
  //                 : const Color(0xFF64748B),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildGroupEmptyState() {
    final searching = _searchQuery.isNotEmpty || _hasActiveFilter;
    return _StateView(
      icon: searching ? Icons.search_off_rounded : Icons.receipt_long_outlined,
      title: searching
          ? 'Invoice tidak ditemukan'
          : 'Belum ada invoice ${_groupLabel(_selectedGroup).toLowerCase()}',
      message: searching
          ? 'Coba kata kunci lain atau hapus filter yang aktif.'
          : 'Invoice pada kategori ini akan tampil saat tersedia.',
      actionLabel: searching ? 'Hapus pencarian & filter' : null,
      onAction: searching ? _resetAll : null,
    );
  }

  int _groupCount(InvoiceLoaded state, _InvoiceGroup group) {
    final statuses = group == _InvoiceGroup.all
        ? _allowedInvoiceStatuses
        : _groupStatuses[group]!;
    if (state.perStatus.isNotEmpty) {
      return statuses.fold(
        0,
        (total, status) => total + (state.perStatus[status]?.totalCount ?? 0),
      );
    }
    return state.items.where((item) => statuses.contains(item.status)).length;
  }

  // double _groupOutstanding(InvoiceLoaded state, _InvoiceGroup group) {
  //   final statuses = group == _InvoiceGroup.all
  //       ? _allowedInvoiceStatuses
  //       : _groupStatuses[group]!;
  //   if (state.perStatus.isNotEmpty) {
  //     return statuses.fold(
  //       0,
  //       (total, status) =>
  //           total + (state.perStatus[status]?.totalOutstanding ?? 0),
  //     );
  //   }
  //   return state.items
  //       .where((item) => statuses.contains(item.status))
  //       .fold(0, (total, item) => total + item.outstandingAmount);
  // }

  void _resetAll() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filterStatus = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _selectedGroup = _InvoiceGroup.all;
      _sortBy = _InvoiceSort.postingDate;
      _sortAscending = false;
    });
  }

  Widget _buildActiveFilters() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
    color: const Color(0xFFF6F7F9),
    child: Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (_filterStatus != null)
          _FilterChip(
            label: _statusLabel(_filterStatus!),
            onDeleted: () => setState(() {
              _filterStatus = null;
            }),
          ),
        if (_filterStartDate != null || _filterEndDate != null)
          _FilterChip(
            label:
                '${_shortDate(_filterStartDate ?? _filterEndDate!)} – ${_shortDate(_filterEndDate ?? _filterStartDate!)}',
            onDeleted: () => setState(() {
              _filterStartDate = null;
              _filterEndDate = null;
            }),
          ),
        if (_hasCustomSort)
          _FilterChip(
            label: _activeSortLabel(_sortBy, _sortAscending),
            onDeleted: () => setState(() {
              _sortBy = _InvoiceSort.postingDate;
              _sortAscending = false;
            }),
          ),
      ],
    ),
  );

  Future<void> _showFilterSheet() async {
    DateTime? start = _filterStartDate, end = _filterEndDate;
    String status = _filterStatus ?? 'Semua';
    _InvoiceSort sortBy = _sortBy;
    bool sortAscending = _sortAscending;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> pickDate(bool isStart) async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: (isStart ? start : end) ?? now,
              firstDate: DateTime(2020),
              lastDate: DateTime(now.year + 2),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryColor,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked == null) return;
            setSheetState(() {
              if (isStart) {
                start = picked;
                if (end != null && end!.isBefore(picked)) end = picked;
              } else {
                end = picked;
                if (start != null && start!.isAfter(picked)) start = picked;
              }
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filter Sales Invoice',
                          style: _style(
                            16,
                            FontWeight.w700,
                            const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setSheetState(() {
                          start = null;
                          end = null;
                          status = 'Semua';
                          sortBy = _InvoiceSort.postingDate;
                          sortAscending = false;
                        }),
                        child: Text(
                          'Reset',
                          style: _style(
                            11,
                            FontWeight.w600,
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _eyebrow('RENTANG JATUH TEMPO'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Dari',
                          value: start,
                          onTap: () => pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateField(
                          label: 'Sampai',
                          value: end,
                          onTap: () => pickDate(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _eyebrow('STATUS'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statusOptions.map((option) {
                      final selected = status == option;
                      return ChoiceChip(
                        label: Text(_statusLabel(option)),
                        selected: selected,
                        onSelected: (_) => setSheetState(() => status = option),
                        showCheckmark: false,
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primaryColor
                              : const Color(0xFFE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelStyle: _style(
                          10,
                          FontWeight.w600,
                          selected ? Colors.white : const Color(0xFF64748B),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _eyebrow('URUTKAN BERDASARKAN'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _InvoiceSort.values.map((option) {
                      final selected = sortBy == option;
                      return ChoiceChip(
                        label: Text(_sortLabel(option)),
                        selected: selected,
                        onSelected: (_) => setSheetState(() => sortBy = option),
                        showCheckmark: false,
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primaryColor
                              : const Color(0xFFE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelStyle: _style(
                          10,
                          FontWeight.w600,
                          selected ? Colors.white : const Color(0xFF64748B),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _SortDirectionButton(
                          label: _sortDirectionLabel(sortBy, true),
                          icon: _sortDirectionIcon(sortBy, true),
                          selected: sortAscending,
                          onTap: () =>
                              setSheetState(() => sortAscending = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SortDirectionButton(
                          label: _sortDirectionLabel(sortBy, false),
                          icon: _sortDirectionIcon(sortBy, false),
                          selected: !sortAscending,
                          onTap: () =>
                              setSheetState(() => sortAscending = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterStartDate = start;
                          _filterEndDate = end;
                          _filterStatus = status == 'Semua' ? null : status;
                          _sortBy = sortBy;
                          _sortAscending = sortAscending;
                          if (_filterStatus != null) {
                            _selectedGroup =
                                _groupForStatus(_filterStatus!) ??
                                _InvoiceGroup.all;
                          }
                        });
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Terapkan Filter',
                        style: _style(12, FontWeight.w700, Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SortDirectionButton extends StatelessWidget {
  const _SortDirectionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? AppColors.primaryColor : const Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _style(
                10,
                FontWeight.w600,
                selected ? AppColors.primaryColor : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.onTap});
  final Invoice invoice;
  final ValueChanged<Invoice> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(invoice),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: AppCardStyles.compact,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon Sales Invoice — terpisah di kiri
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama PT + nominal
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            invoice.customerName.isEmpty
                                ? invoice.customer
                                : invoice.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _style(
                              11,
                              FontWeight.w700,
                              const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 132),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.topRight,
                            child: Text(
                              _money(invoice.grandTotal, invoice.currency),
                              maxLines: 1,
                              style: _style(
                                11,
                                FontWeight.w700,
                                const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      invoice.customer.isNotEmpty &&
                              invoice.customer != invoice.customerName
                          ? invoice.customer
                          : 'Sales Invoice',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _style(
                        11,
                        FontWeight.w400,
                        const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _DashedLine(),
                    const SizedBox(height: 10),
                    // No. invoice + status (sebelahan) | tanggal
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  invoice.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _style(
                                    9,
                                    FontWeight.w500,
                                    const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _StatusBadge(label: invoice.status),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _date(
                            invoice.postingDate.isEmpty
                                ? invoice.dueDate
                                : invoice.postingDate,
                          ),
                          style: _style(
                            10,
                            FontWeight.w500,
                            const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Garis putus-putus tipis (pemisah di dalam kartu).
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const color = Color(0xFFD1D5DB);
        const dashWidth = 3.0;
        const dashGap = 3.0;
        final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: List.generate(
            count,
            (_) => Padding(
              padding: EdgeInsets.only(right: dashGap),
              child: SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(decoration: BoxDecoration(color: color)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final visual = _statusVisual(label);
    return Container(
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: visual.border),
      ),
      child: Text(
        _statusLabel(label),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _style(8, FontWeight.w700, visual.foreground),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onDeleted});
  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(9, 5, 5, 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _style(9.5, FontWeight.w600, AppColors.primaryColor),
          ),
        ),
        const SizedBox(width: 3),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onDeleted,
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 17,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: _style(9.5, FontWeight.w400, const Color(0xFF94A3B8)),
                ),
                Text(
                  value == null ? 'Pilih tanggal' : _shortDate(value!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _style(10.5, FontWeight.w600, const Color(0xFF334155)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _style(14, FontWeight.w700, const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: _style(11, FontWeight.w400, const Color(0xFF64748B)),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(actionLabel!),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                textStyle: _style(
                  10.5,
                  FontWeight.w600,
                  AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Color(0x1F0F172A), blurRadius: 12)],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: _style(10.5, FontWeight.w600, const Color(0xFF334155)),
        ),
      ],
    ),
  );
}

class _InvoiceSkeleton extends StatelessWidget {
  const _InvoiceSkeleton();
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFE2E8F0),
    highlightColor: const Color(0xFFF8FAFC),
    child: ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 112,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

class _StatusVisual {
  const _StatusVisual(this.foreground, this.background, this.border);
  final Color foreground, background, border;
}

_StatusVisual _statusVisual(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'completed':
      return const _StatusVisual(
        Color(0xFF15803D),
        Color(0xFFE8F8EE),
        Color(0xFFBBF7D0),
      );
    case 'overdue':
    case 'unpaid':
      return const _StatusVisual(
        Color(0xFFB91C1C),
        Color(0xFFFDECEC),
        Color(0xFFFECACA),
      );
    case 'partly paid':
      return const _StatusVisual(
        Color(0xFF1D4ED8),
        Color(0xFFE8F0FE),
        Color(0xFFBFDBFE),
      );
    case 'submitted':
    case 'draft':
      return const _StatusVisual(
        Color(0xFFA16207),
        Color(0xFFFEF9C3),
        Color(0xFFFDE68A),
      );
    case 'return':
    case 'credit note issued':
      return const _StatusVisual(
        Color(0xFF7C3AED),
        Color(0xFFF5F3FF),
        Color(0xFFDDD6FE),
      );
    default:
      return const _StatusVisual(
        Color(0xFF475569),
        Color(0xFFF8FAFC),
        Color(0xFFE2E8F0),
      );
  }
}

String _statusLabel(String status) => switch (status) {
  'Submitted' => 'Diajukan',
  'Paid' => 'Lunas',
  'Unpaid' => 'Belum dibayar',
  'Partly Paid' => 'Dibayar sebagian',
  'Overdue' => 'Jatuh tempo',
  'Return' => 'Retur',
  'Credit Note Issued' => 'Nota kredit',
  'Completed' => 'Selesai',
  _ => status,
};

String _groupLabel(_InvoiceGroup group) => switch (group) {
  _InvoiceGroup.all => 'Semua',
  _InvoiceGroup.payment => 'Proses Bayar',
  _InvoiceGroup.overdue => 'Terlambat',
  _InvoiceGroup.returns => 'Retur',
  _InvoiceGroup.paid => 'Lunas',
};

_InvoiceGroup? _groupForStatus(String status) {
  for (final entry in _groupStatuses.entries) {
    if (entry.value.contains(status)) return entry.key;
  }
  return null;
}

String _sortLabel(_InvoiceSort sort) => switch (sort) {
  _InvoiceSort.invoiceNumber => 'Nomor Invoice',
  _InvoiceSort.postingDate => 'Tanggal Invoice',
  _InvoiceSort.dueDate => 'Jatuh Tempo',
};

String _sortDirectionLabel(_InvoiceSort sort, bool ascending) {
  if (sort == _InvoiceSort.invoiceNumber) {
    return ascending ? 'A ke Z' : 'Z ke A';
  }
  if (sort == _InvoiceSort.dueDate) {
    return ascending ? 'Terdekat' : 'Terjauh';
  }
  return ascending ? 'Terlama' : 'Terbaru';
}

IconData _sortDirectionIcon(_InvoiceSort sort, bool ascending) {
  if (sort == _InvoiceSort.invoiceNumber) {
    return ascending ? Icons.sort_by_alpha_rounded : Icons.sort_rounded;
  }
  return ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
}

String _activeSortLabel(_InvoiceSort sort, bool ascending) =>
    '${_sortLabel(sort)}: ${_sortDirectionLabel(sort, ascending)}';

Widget _eyebrow(String text) => Text(
  text,
  style: _style(
    9.5,
    FontWeight.w700,
    const Color(0xFF94A3B8),
  ).copyWith(letterSpacing: .45),
);
String _shortDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
String _date(String value) {
  final parsed = DateTime.tryParse(value);
  return parsed == null
      ? (value.isEmpty ? '-' : value)
      : DateFormat('d MMM yyyy', 'id_ID').format(parsed);
}

String _money(double value, String currency) => NumberFormat.currency(
  locale: 'id_ID',
  symbol: currency == 'IDR' || currency.isEmpty ? 'Rp' : '$currency ',
  decimalDigits: currency == 'IDR' || currency.isEmpty ? 0 : 2,
).format(value);

TextStyle _style(double size, FontWeight weight, Color color) => TextStyle(
  fontFamily: AppFonts.primaryFont,
  fontSize: size,
  fontWeight: weight,
  color: color,
);
