import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/invoice/data/services/invoice_detail_service.dart';
import 'package:ekaplus_ekatunggal/features/invoice/data/models/invoice_model.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/branch_credential_service.dart';
import 'invoice_detail_page.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  String _searchQuery = '';

  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterStatus;

  static const Color kRed   = Color(0xFFC0392B);
  static const Color kGreen = Color(0xFF27AE60);

  static const List<String> _statusOptions = [
    'Semua', 'Paid', 'Unpaid', 'Overdue'
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed': return kGreen;
      case 'Cancelled': return Colors.grey;
      case 'Draft':     return Colors.orange;
      default:          return kRed;
    }
  }

  bool get _hasActiveFilter =>
      _filterStartDate != null ||
      _filterEndDate   != null ||
      (_filterStatus != null && _filterStatus != 'Semua');

  @override
  void initState() {
    super.initState();
    final activeCompanyCubit = context.read<ActiveCompanyCubit>();
    final invoiceCubit = context.read<InvoiceCubit>();
    Future.microtask(() {
      final activeState = activeCompanyCubit.state;
      final branchCode  = (activeState as ActiveCompanyReady?)?.activeCompany?.branchName         ?? '';
      final bcid        = (activeState as ActiveCompanyReady?)?.activeCompany?.branchCustomerCode ?? '';
      if (branchCode.isNotEmpty || bcid.isNotEmpty) {
        invoiceCubit.loadInvoices(branchCode: branchCode, bcid: bcid);
      }
    });
  }

  List<Invoice> _filteredList(List<Invoice> all) {
    List<Invoice> filtered = all;

    if (_filterStatus != null && _filterStatus != 'Semua') {
      filtered = filtered.where((i) => i.status == _filterStatus).toList();
    }

    if (_filterStartDate != null || _filterEndDate != null) {
      filtered = filtered.where((i) {
        DateTime? invoiceDate;
        try { invoiceDate = DateTime.parse(i.dueDate); } catch (_) { return true; }

        if (_filterStartDate != null && invoiceDate.isBefore(
            DateTime(_filterStartDate!.year, _filterStartDate!.month, _filterStartDate!.day))) {
          return false;
        }
        if (_filterEndDate != null && invoiceDate.isAfter(
            DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day, 23, 59, 59))) {
          return false;
        }
        return true;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((i) =>
          i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.customer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.customerName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  List<Invoice> _pagedList(List<Invoice> filtered) {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end   = (start + _itemsPerPage).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  int _totalPages(int totalItems) =>
      (totalItems / _itemsPerPage).ceil().clamp(1, 999);

  void _goToPage(int page, int total) {
    if (page < 1 || page > total) return;
    setState(() => _currentPage = page);
  }

  List<int> _visiblePages(int totalPages) {
    if (totalPages <= 5) return List.generate(totalPages, (i) => i + 1);
    int start = (_currentPage - 2).clamp(1, totalPages - 4);
    int end   = (start + 4).clamp(5, totalPages);
    start     = (end - 4).clamp(1, totalPages);
    return List.generate(end - start + 1, (i) => start + i);
  }

  void _showFilterSheet() {
    DateTime? tempStart  = _filterStartDate;
    DateTime? tempEnd    = _filterEndDate;
    String    tempStatus = _filterStatus ?? 'Semua';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            String fmt(DateTime? d) =>
                d == null ? '—' : '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

            Future<void> pickDate({required bool isStart}) async {
              final now    = DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                initialDate: (isStart ? tempStart : tempEnd) ?? now,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year + 2),
                builder: (c, child) => Theme(
                  data: Theme.of(c).copyWith(
                    colorScheme: const ColorScheme.light(primary: kRed),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setSheetState(() {
                  if (isStart) {
                    tempStart = picked;
                  } else {
                    tempEnd   = picked;
                  }
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Invoice',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (_hasActiveFilter)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filterStartDate = null;
                              _filterEndDate   = null;
                              _filterStatus    = null;
                              _currentPage     = 1;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset',
                              style: TextStyle(color: kRed, fontSize: 13)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Rentang Tanggal',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerButton(
                          label: 'Dari', value: fmt(tempStart),
                          onTap: () => pickDate(isStart: true),
                          hasValue: tempStart != null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerButton(
                          label: 'Sampai', value: fmt(tempEnd),
                          onTap: () => pickDate(isStart: false),
                          hasValue: tempEnd != null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Status',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _statusOptions.map((s) {
                      final selected = tempStatus == s;
                      return GestureDetector(
                        onTap: () => setSheetState(() => tempStatus = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? kRed : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? kRed : Colors.black12),
                          ),
                          child: Text(s,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: selected ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterStartDate = tempStart;
                          _filterEndDate   = tempEnd;
                          _filterStatus    = tempStatus == 'Semua' ? null : tempStatus;
                          _currentPage     = 1;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Terapkan Filter',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openDetail(Invoice invoice) async {
    final activeState = context.read<ActiveCompanyCubit>().state as ActiveCompanyReady?;
    final branchName  = activeState?.activeCompany?.branchName ?? '';
    final credential  = await BranchCredentialService().fetchCredential(branchName);
    if (credential == null || !mounted) return;

    final detail = await InvoiceDetailService().fetchDetail(
      baseUrl: credential.url,
      token: credential.token,
      invoiceName: invoice.name,
    );
    if (detail == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceDetailPage(invoice: detail.toDetailMap()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          if (_hasActiveFilter) _buildActiveFilterChips(),
          Expanded(
            child: BlocConsumer<InvoiceCubit, InvoiceState>(
              listener: (context, state) {
                if (state is InvoiceError) debugPrint("ERROR: ${state.message}");
              },
              builder: (context, state) {
                if (state is InvoiceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is InvoiceUnauthorized) {
                  return _buildAnnouncement(state.message);
                }
                if (state is InvoiceError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(state.message),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            final s = context.read<ActiveCompanyCubit>().state;
                            context.read<InvoiceCubit>().loadInvoices(
                              branchCode: (s as ActiveCompanyReady?)?.activeCompany?.branchName ?? '',
                              bcid: (s as ActiveCompanyReady?)?.activeCompany?.branchCustomerCode ?? '',
                            );
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is InvoiceLoaded) {
                  final filtered   = _filteredList(state.items);
                  final totalPages = _totalPages(filtered.length);
                  final paged      = _pagedList(filtered);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.black26),
                          const SizedBox(height: 12),
                          const Text('Tidak ada invoice ditemukan',
                              style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: paged.length + 1, 
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      if (i == paged.length) {
                        return _buildPagination(totalPages, filtered.length);
                      }
                      return _buildInvoiceCard(paged[i]);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: kRed,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Laporan Pelanggan',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
              GestureDetector(
                onTap: _showFilterSheet,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.tune, color: Colors.white, size: 22),
                    if (_hasActiveFilter)
                      Positioned(
                        top: -3, right: -3,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
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

  Widget _buildSearchBar() {
    return Container(
      color: kRed,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          onChanged: (v) => setState(() {
            _searchQuery = v;
            _currentPage = 1;
          }),
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Cari nama, perusahaan...',
            hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.black38, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 14, color: kRed),
          const SizedBox(width: 6),
          Expanded(
            child: Wrap(
              spacing: 6,
              children: [
                if (_filterStatus != null)
                  _buildChip(_filterStatus!,
                      onDelete: () => setState(() { _filterStatus = null; _currentPage = 1; })),
                if (_filterStartDate != null || _filterEndDate != null)
                  _buildChip(
                    '${fmt(_filterStartDate ?? _filterEndDate!)} → ${fmt(_filterEndDate ?? _filterStartDate!)}',
                    onDelete: () => setState(() {
                      _filterStartDate = null;
                      _filterEndDate   = null;
                      _currentPage     = 1;
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {required VoidCallback onDelete}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEDED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRed.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: kRed)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 13, color: kRed),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice inv) {
    final bool isBelumBayar = inv.status == 'To Deliver and Bill' ||
        inv.status == 'To Bill' ||
        inv.status == 'Draft';

    return GestureDetector(
      onTap: () => _openDetail(inv),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isBelumBayar
                              ? const Color(0xFFFDEDED)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.receipt_outlined, size: 18,
                            color: isBelumBayar ? kRed : kGreen),
                      ),
                      const SizedBox(width: 10),
                      Text(inv.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(inv.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      inv.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(inv.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      icon: Icons.business_outlined,
                      label: 'Perusahaan',
                      value: inv.customer,
                    ),
                  ),
                  Expanded(
                    child: _buildField(
                      icon: Icons.calendar_today_outlined,
                      label: 'Tanggal',
                      value: inv.dueDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildField(
                icon: Icons.person_outline,
                label: 'Customer',
                value: inv.customerName,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black87,
    bool valueBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.black38),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(
                  fontSize: 10, color: Colors.black38, letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                    fontSize: 12,
                    color: valueColor,
                    fontWeight: valueBold ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(int totalPages, int totalItems) {
    final startItem  = ((_currentPage - 1) * _itemsPerPage) + 1;
    final endItem    = (_currentPage * _itemsPerPage).clamp(0, totalItems);
    final pageNumbers = _visiblePages(totalPages);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: [
          Text(
            '$startItem–$endItem dari $totalItems data',
            style: const TextStyle(fontSize: 11, color: Colors.black38, letterSpacing: 0.2),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _currentPage > 1
                    ? () => _goToPage(_currentPage - 1, totalPages)
                    : null,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 22,
                  color: _currentPage > 1 ? kRed : Colors.black12,
                ),
              ),
              const SizedBox(width: 8),

              if (pageNumbers.first > 1) ...[
                _paginationItem(1, totalPages),
                if (pageNumbers.first > 2)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('·····', style: TextStyle(color: Colors.black26, fontSize: 10, letterSpacing: 1)),
                  ),
              ],
              ...pageNumbers.map((p) => _paginationItem(p, totalPages)),
              if (pageNumbers.last < totalPages) ...[
                if (pageNumbers.last < totalPages - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('·····', style: TextStyle(color: Colors.black26, fontSize: 10, letterSpacing: 1)),
                  ),
                _paginationItem(totalPages, totalPages),
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _currentPage < totalPages
                    ? () => _goToPage(_currentPage + 1, totalPages)
                    : null,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: _currentPage < totalPages ? kRed : Colors.black12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paginationItem(int page, int totalPages) {
    final isActive = page == _currentPage;
    return GestureDetector(
      onTap: () => _goToPage(page, totalPages),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: isActive ? 32 : 28,
        height: isActive ? 32 : 28,
        decoration: BoxDecoration(
          color: isActive ? kRed : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: isActive ? 13 : 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : Colors.black38,
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncement(String message) => Center(child: Text(message));
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool hasValue;

  const _DatePickerButton({
    required this.label,
    required this.value,
    required this.onTap,
    required this.hasValue,
  });

  @override
  Widget build(BuildContext context) {
    const kRed = Color(0xFFC0392B);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: hasValue ? const Color(0xFFFDEDED) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasValue ? kRed.withOpacity(0.4) : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, size: 16,
                color: hasValue ? kRed : Colors.black38),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 10, color: hasValue ? kRed : Colors.black38)),
                  Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: hasValue ? kRed : Colors.black45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
