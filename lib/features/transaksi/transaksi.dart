import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/pages/invoice_page.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/presentation/pages/sales_order_page.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/presentation/cubit/sales_order_cubit.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/branch_credential_service.dart';
import 'package:ekaplus_ekatunggal/features/transaksi/transaksi_summary_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  static const Color kRed   = Color(0xFFC0392B);
  static const Color kGreen = Color(0xFF27AE60);
  static const Color kBg    = Color(0xFFF2F2F7);

  final _service = TransaksiSummaryService();

  bool _isLoading = true;

  int _paid    = 0;
  int _unpaid  = 0;
  int _overdue = 0;

  int _soPaid    = 0;
  int _soUnpaid  = 0;
  int _soOverdue = 0;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() => _isLoading = true);
    try {
      final activeState = context.read<ActiveCompanyCubit>().state as ActiveCompanyReady?;
      final branchName  = activeState?.activeCompany?.branchName ?? '';
      final bcid        = activeState?.activeCompany?.branchCustomerCode ?? '';

      final credential = await BranchCredentialService().fetchCredential(branchName);
      if (credential == null || !mounted) {
        setState(() => _isLoading = false);
        return;
      }

      final invoiceResult = await _service.fetchInvoiceSummary(
        baseUrl: credential.url,
        token:   credential.token,
        bcid:    bcid,
      );
      final soResult = await _service.fetchSalesOrderSummary(
        baseUrl: credential.url,
        token:   credential.token,
        bcid:    bcid,
      );

      if (!mounted) return;
      setState(() {
        _paid      = invoiceResult['paid']    ?? 0;
        _unpaid    = invoiceResult['unpaid']  ?? 0;
        _overdue   = invoiceResult['overdue'] ?? 0;
        _soPaid    = soResult['paid']         ?? 0;
        _soUnpaid  = soResult['unpaid']       ?? 0;
        _soOverdue = soResult['overdue']      ?? 0;
      });
    } catch (e) {
      debugPrint('Error fetchSummary: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchSummary,
              color: kRed,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('MENU TRANSAKSI'),
                    const SizedBox(height: 10),
                    _ringkasanInvoiceCard(
                      icon: Icons.receipt_long_outlined,
                      iconBg: const Color(0xFFFDEDED),
                      iconColor: kRed,
                      borderColor: kRed,
                      title: 'Sales Invoice',
                      paid: _paid,
                      unpaid: _unpaid,
                      overdue: _overdue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => InvoiceCubit(),
                            child: InvoicePage(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ringkasanInvoiceCard(
                      icon: Icons.monitor_outlined,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: kGreen,
                      borderColor: kGreen,
                      title: 'Sales Order',
                      paid: _soPaid,
                      unpaid: _soUnpaid,
                      overdue: _soOverdue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => SalesOrderCubit(),
                            child: SalesOrderPage(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ringkasanInvoiceCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color borderColor,
    required String title,
    required int paid,
    required int unpaid,
    required int overdue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.chevron_right, color: iconColor),
              ],
            ),

            const SizedBox(height: 12),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ringkasanItem(
                        icon: Icons.check,
                        value: paid,
                        label: 'Paid',
                        iconColor: const Color(0xFF3B6D11),
                        iconBg: const Color(0xFFEAF3DE),
                        valueColor: const Color(0xFF3B6D11),
                      ),
                      _ringkasanItem(
                        icon: Icons.error_outline,
                        value: unpaid,
                        label: 'Unpaid',
                        iconColor: const Color(0xFFA32D2D),
                        iconBg: const Color(0xFFFCEBEB),
                        valueColor: const Color(0xFFA32D2D),
                      ),
                      _ringkasanItem(
                        icon: Icons.access_time,
                        value: overdue,
                        label: 'Overdue',
                        iconColor: const Color(0xFF854F0B),
                        iconBg: const Color(0xFFFAEEDA),
                        valueColor: const Color(0xFF854F0B),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _ringkasanItem({
    required IconData icon,
    required int value,
    required String label,
    required Color iconColor,
    required Color iconBg,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 12),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: valueColor),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: kRed,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Transaksi',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  // Icon(Icons.search, color: Colors.white, size: 22),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Kelola semua transaksi penjualan kamu' ,
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8));
  }
}
