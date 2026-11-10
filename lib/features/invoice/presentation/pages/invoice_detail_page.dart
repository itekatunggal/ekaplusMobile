import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/core/theme/app_card_styles.dart';
import 'package:ekaplus_ekatunggal/features/invoice/data/services/payment_entry_service.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/branch_credential_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/invoice/data/services/sales_order_service.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/delivery_note_service.dart';

class InvoiceDetailPage extends StatefulWidget {
  final Map<String, dynamic> invoice;
  const InvoiceDetailPage({super.key, required this.invoice});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // null = tampil list, isi = tampil detail
  Map<String, dynamic>? _selectedPayment;
  Map<String, dynamic>? _selectedDelivery;
  Map<String, dynamic>? _selectedSales;

  bool _isLoadingPayment = false;
  List<Map<String, dynamic>> _paymentList = [];
  bool _paymentLoaded = false;
  String? _paymentError;

  bool _isLoadingSales = false;
  List<Map<String, dynamic>> _salesList = [];
  bool _salesLoaded = false;
  String? _salesError;

  bool _isLoadingDelivery = false;
  List<Map<String, dynamic>> _deliveryNoteList = [];
  bool _deliveryLoaded = false;
  String? _deliveryError;

  static const Color kRed = AppColors.primaryColor;
  static const Color kGreen = Color(0xFF059669);
  static const Color kBg = Color(0xFFF6F7F9);

  static const Color kInk = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kFaint = Color(0xFF94A3B8);
  static const Color kLine = Color(0xFFF1F5F9);
  static const Color kOrange = Color(0xFFF57C00);

  // ── Null-safe helpers ─────────────────────────────────────────────────────
  String _s(String key, [String fallback = '-']) =>
      widget.invoice[key]?.toString() ?? fallback;

  int _i(String key, [int fallback = 0]) {
    final v = widget.invoice[key];
    return v is num ? v.toInt() : fallback;
  }

  List<Map<String, dynamic>> _list(String key) {
    final raw = widget.invoice[key];
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Map<String, dynamic> _map(String key) {
    final raw = widget.invoice[key];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  String _rupiah(int v) {
    if (v == 0) return 'Rp 0';
    final neg = v < 0;
    final s = v.abs().toString();
    String r = '';
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) r = '.$r';
      r = s[i] + r;
      c++;
    }
    return '${neg ? '-' : ''}Rp $r';
  }

  /// Format rupiah dari nilai dinamis (num / String / null).
  String _money(dynamic v) {
    if (v is num) return _rupiah(v.toInt());
    final n = num.tryParse(v?.toString() ?? '');
    return n == null ? '-' : _rupiah(n.toInt());
  }

  String _rupiahDigits(int value) {
    return _rupiah(value).replaceFirst('-Rp ', '-').replaceFirst('Rp ', '');
  }

  bool _isPaidLike(String status) {
    final l = status.toLowerCase();
    if (l.contains('unpaid') || l.contains('belum') || l.contains('overdue')) {
      return false;
    }
    return l.contains('paid') ||
        l.contains('lunas') ||
        l.contains('completed') ||
        l.contains('closed');
  }

  bool _isUnpaidLike(String status) {
    final l = status.toLowerCase();
    return l.contains('unpaid') || l.contains('belum') || l.contains('overdue');
  }

  String _stripHtml(String? html, [String fallback = '-']) {
    if (html == null || html.isEmpty) return fallback;
    final out = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
    return out.isEmpty ? fallback : out;
  }

  /// '2026-10-07' → '07 Okt 2026'. Jika gagal parse, kembalikan teks asli.
  String _fmtDate(String raw) {
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${bulan[d.month - 1]} ${d.year}';
  }

  /// Ubah teks KAPITAL jadi Title Case, singkatan umum tetap kapital.
  String _titleCase(String input) {
    const keep = {'PT', 'CV', 'KM', 'RT', 'RW', 'NO', 'UD', 'TBK'};
    return input
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          final letters = word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
          if (keep.contains(letters)) return word.toUpperCase();
          return word.toLowerCase().replaceAllMapped(
            RegExp(r'(^|[\/\.\-\(])([a-z])'),
            (m) => '${m[1]}${m[2]!.toUpperCase()}',
          );
        })
        .join(' ');
  }

  /// Rapikan alamat: buang baris kosong & baris yang sudah termuat di baris lain.
  List<String> _tidyAddress(String? html) {
    final raw = _stripHtml(html, '');
    if (raw.isEmpty) return [];
    final parts = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final result = <String>[];
    for (final p in parts) {
      final lower = p.toLowerCase();
      if (result.any((r) => r.toLowerCase().contains(lower))) continue;
      result.add(p);
    }
    return result.map(_titleCase).toList();
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label disalin'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Reset detail saat pindah tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedPayment = null;
          _selectedDelivery = null;
          _selectedSales = null;
        });
        if (_tabController.index == 2) _loadPaymentEntry();
        if (_tabController.index == 3) _loadDeliveryNotes();
        if (_tabController.index == 4) _loadSales();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _s('status').toLowerCase();
    final bool isBelumBayar =
        status == 'belum bayar' || status == 'unpaid' || status == 'overdue';

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(
          context,
        ).textTheme.apply(fontFamily: AppFonts.primaryFont),
      ),
      child: CustomHeaderScaffold(
        title: _headerTitle,
        showBackButton: true,
        onBackPressed: _handleBack,
        backgroundColor: kBg,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                _buildSummarySection(isBelumBayar),
                _buildTabs(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics:
                        (_selectedPayment != null ||
                            _selectedDelivery != null ||
                            _selectedSales != null)
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    children: [
                      _tabDetail(),
                      _tabItem(),
                      _tabPembayaran(),
                      _tabDelivery(),
                      _tabSales(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    if (_selectedPayment != null) {
      setState(() => _selectedPayment = null);
    } else if (_selectedDelivery != null) {
      setState(() => _selectedDelivery = null);
    } else if (_selectedSales != null) {
      setState(() => _selectedSales = null);
    } else {
      Navigator.pop(context);
    }
  }

  // ─── DATA LOADERS ─────────────────────────────────────────────────────────
  Future<void> _loadPaymentEntry() async {
    if (_paymentLoaded) return;

    setState(() {
      _isLoadingPayment = true;
      _paymentError = null;
    });

    final soName = _s('series');
    final invoiceName = _s('name');

    if (soName.isEmpty || soName == '-') {
      setState(() {
        _isLoadingPayment = false;
        _paymentLoaded = true;
      });
      return;
    }

    final activeState =
        context.read<ActiveCompanyCubit>().state as ActiveCompanyReady?;
    final branchName = activeState?.activeCompany?.branchName ?? '';
    final bcid = activeState?.activeCompany?.branchCustomerCode ?? '';
    final credential = await BranchCredentialService().fetchCredential(
      branchName,
    );

    if (!mounted) return;
    if (credential == null) {
      setState(() {
        _isLoadingPayment = false;
        _paymentError = 'Credential cabang tidak tersedia.';
      });
      return;
    }

    final results = await PaymentEntryService().fetchBySOName(
      baseUrl: credential.url,
      token: credential.token,
      bcid: bcid,
      soName: soName,
      invoiceName: invoiceName,
    );

    if (!mounted) return;

    setState(() {
      _paymentList = results ?? [];
      _isLoadingPayment = false;
      _paymentLoaded = results != null;
      _paymentError = results == null
          ? 'Data payment belum dapat dimuat.'
          : null;
    });
  }

  Future<void> _loadDeliveryNotes() async {
    if (_deliveryLoaded) return;

    setState(() {
      _isLoadingDelivery = true;
      _deliveryError = null;
    });

    final soName = _s('series');
    final invoiceName = _s('name');

    if (soName.isEmpty || soName == '-') {
      setState(() {
        _isLoadingDelivery = false;
        _deliveryLoaded = true;
      });
      return;
    }

    final activeState =
        context.read<ActiveCompanyCubit>().state as ActiveCompanyReady?;
    final branchName = activeState?.activeCompany?.branchName ?? '';
    final bcid = activeState?.activeCompany?.branchCustomerCode ?? '';
    final credential = await BranchCredentialService().fetchCredential(
      branchName,
    );

    if (!mounted) return;
    if (credential == null) {
      setState(() {
        _isLoadingDelivery = false;
        _deliveryError = 'Credential cabang tidak tersedia.';
      });
      return;
    }

    final results = await DeliveryNoteService().fetchBySOName(
      baseUrl: credential.url,
      token: credential.token,
      bcid: bcid,
      invoiceName: invoiceName,
      soName: soName, // SO-... → body
      refName: invoiceName, // SJ-... → URL
    );

    if (!mounted) return;

    setState(() {
      _deliveryNoteList = results ?? [];
      _isLoadingDelivery = false;
      _deliveryLoaded = results != null;
      _deliveryError = results == null
          ? 'Data delivery note belum dapat dimuat.'
          : null;
    });
  }

  Future<void> _loadSales() async {
    if (_salesLoaded) return;

    setState(() {
      _isLoadingSales = true;
      _salesError = null;
    });

    final soName = _s('series');
    final invoiceName = _s('name');

    if (soName.isEmpty || soName == '-') {
      setState(() {
        _isLoadingSales = false;
        _salesLoaded = true;
      });
      return;
    }

    final activeState =
        context.read<ActiveCompanyCubit>().state as ActiveCompanyReady?;
    final branchName = activeState?.activeCompany?.branchName ?? '';
    final bcid = activeState?.activeCompany?.branchCustomerCode ?? '';
    final credential = await BranchCredentialService().fetchCredential(
      branchName,
    );

    if (!mounted) return;
    if (credential == null) {
      setState(() {
        _isLoadingSales = false;
        _salesError = 'Credential cabang tidak tersedia.';
      });
      return;
    }

    final results = await SalesOrderService().fetchBySOName(
      baseUrl: credential.url,
      token: credential.token,
      bcid: bcid,
      soName: soName,
      invoiceName: invoiceName,
    );

    if (!mounted) return;

    setState(() {
      _salesList = results ?? [];
      _isLoadingSales = false;
      _salesLoaded = results != null;
      _salesError = results == null
          ? 'Data sales order belum dapat dimuat.'
          : null;
    });
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────
  String get _headerTitle {
    if (_selectedPayment != null) return 'Detail Pembayaran';
    if (_selectedDelivery != null) return 'Detail Delivery';
    if (_selectedSales != null) return 'Detail Sales Order';
    return 'Detail Sales Invoice';
  }

  Widget _buildSummarySection(bool isBelumBayar) {
    final Widget summary;
    if (_selectedPayment != null) {
      final p = _selectedPayment!;
      summary = _detailSummary(
        title: p['name']?.toString() ?? '-',
        status: p['status']?.toString() ?? '-',
        metas: [
          (Icons.calendar_today_outlined, p['posting_date']?.toString() ?? '-'),
          (Icons.person_outline, p['party_name']?.toString() ?? '-'),
          (
            Icons.account_balance_wallet_outlined,
            'Sisa ${_money(p['outstanding_amount'])}',
          ),
        ],
      );
    } else if (_selectedDelivery != null) {
      final p = _selectedDelivery!;
      summary = _detailSummary(
        title: p['name']?.toString() ?? '-',
        status: p['status']?.toString() ?? '-',
        metas: [
          (
            Icons.calendar_today_outlined,
            (p['posting_date'] ?? p['date'])?.toString() ?? '-',
          ),
          (
            Icons.person_outline,
            (p['customer_name'] ?? p['customer'])?.toString() ?? '-',
          ),
        ],
      );
    } else if (_selectedSales != null) {
      final p = _selectedSales!;
      summary = _detailSummary(
        title: p['name']?.toString() ?? '-',
        status: p['status']?.toString() ?? '-',
        metas: [
          (Icons.calendar_today_outlined, p['posting_date']?.toString() ?? '-'),
          (Icons.person_outline, p['customer_name']?.toString() ?? '-'),
          (Icons.receipt_long_outlined, _money(p['grand_total'])),
        ],
      );
    } else {
      summary = _invoiceSummary(isBelumBayar);
    }

    return SizedBox(width: double.infinity, child: summary);
  }

  /// Ringkasan invoice: nomor, status, total tagihan, jatuh tempo + countdown.
  Widget _invoiceSummary(bool isBelumBayar) {
    final dueRaw = _s('dueDate');
    final totalAmount = _rupiahDigits(_i('nilai'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.major,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: ikon + nomor invoice + status
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 19,
                  color: kRed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SALES INVOICE',
                      style: TextStyle(
                        color: kFaint,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _s('series'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kInk,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _invoiceStatusPill(_s('status'), paid: !isBelumBayar),
            ],
          ),
          const SizedBox(height: 16),

          // Total tagihan
          const Text(
            'Total Tagihan',
            style: TextStyle(
              color: kMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Rp ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: totalAmount,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              style: const TextStyle(color: kInk),
            ),
          ),
          const SizedBox(height: 14),

          // Strip jatuh tempo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kLine),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_outlined, size: 16, color: kMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jatuh Tempo',
                        style: TextStyle(fontSize: 10, color: kFaint),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _fmtDate(dueRaw),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: kInk,
                        ),
                      ),
                    ],
                  ),
                ),
                _dueChip(dueRaw, paid: !isBelumBayar),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chip countdown hanya untuk invoice yang belum lunas.
  Widget _dueChip(String dueRaw, {required bool paid}) {
    if (paid) return const SizedBox.shrink();

    final due = DateTime.tryParse(dueRaw);
    if (due == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final diff = DateTime(
      due.year,
      due.month,
      due.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;

    final String text;
    final Color fg;
    final Color bg;
    final IconData icon;
    if (diff < 0) {
      text = 'Lewat ${-diff} hari';
      fg = kRed;
      bg = const Color(0xFFFFF1F2);
      icon = Icons.error_outline;
    } else if (diff == 0) {
      text = 'Hari ini';
      fg = kOrange;
      bg = const Color(0xFFFFF3E0);
      icon = Icons.schedule;
    } else if (diff <= 7) {
      text = '$diff hari lagi';
      fg = kOrange;
      bg = const Color(0xFFFFF3E0);
      icon = Icons.schedule;
    } else {
      text = '$diff hari lagi';
      fg = const Color(0xFF1565C0);
      bg = const Color(0xFFE3F2FD);
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceStatusPill(String text, {required bool paid}) {
    final foreground = paid ? const Color(0xFF15803D) : AppColors.primaryColor;
    final background = paid ? const Color(0xFFE8F8EE) : const Color(0xFFFFF1F2);
    final border = paid ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Ringkasan untuk halaman detail (payment / delivery / sales order).
  Widget _detailSummary({
    required String title,
    required String status,
    required List<(IconData, String)> metas,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppCardStyles.major,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: kInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _chip(status),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [for (final m in metas) _metaLine(m.$1, m.$2)],
          ),
        ],
      ),
    );
  }

  Widget _metaLine(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: kFaint),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: kMuted, fontSize: 11.5),
          ),
        ),
      ],
    );
  }

  // ─── TAB BAR (pill style) ─────────────────────────────────────────────────
  Widget _buildTabs() {
    const labels = ['Detail', 'Item', 'Bayar', 'Kirim', 'Order'];
    return Container(
      color: kBg,
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: kRed,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33D52A2F),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        labelPadding: EdgeInsets.zero,
        labelColor: Colors.white,
        unselectedLabelColor: kMuted,
        labelStyle: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          for (final l in labels)
            Tab(
              height: 34,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(l),
              ),
            ),
        ],
      ),
    );
  }

  // ─── TAB 1 — DETAIL ───────────────────────────────────────────────────────
  Widget _tabDetail() {
    final addr = _map('address');
    final taxes = _list('taxes');
    final int taxTotal = _i('taxTotal');
    final discount = _map('discount');

    return _ScrollPage(
      children: [
        _invoiceInfoCard(),
        _addressCard(addr),
        _card(
          title: 'PAJAK & BIAYA',
          child: Column(
            children: [
              if (taxes.isEmpty)
                const _InlineEmpty(
                  icon: Icons.percent,
                  message: 'Tidak ada pajak',
                )
              else
                ...taxes.map((t) {
                  final rate = t['rate'] is num
                      ? (t['rate'] as num).toDouble()
                      : 0.0;
                  final amt = t['amount'] is num
                      ? (t['amount'] as num).toInt()
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['type']?.toString() ?? '-',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kInk,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t['accountHead']?.toString() ?? '-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: kLine,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${rate.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _rupiah(amt),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kInk,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const Divider(height: 20, color: kLine),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pajak',
                    style: TextStyle(fontSize: 12, color: kMuted),
                  ),
                  Text(
                    _rupiah(taxTotal),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if ((discount['baseDiscountAmount'] ?? 0) != 0)
          _card(
            title: 'DISKON TAMBAHAN',
            child: _infoGroup([
              (
                Icons.tune,
                'Diskon Diterapkan Pada',
                discount['applyOn']?.toString() ?? '-',
              ),
              (
                Icons.percent,
                'Diskon (%)',
                '${discount['discountPercent']?.toString() ?? '0'}%',
              ),
              (
                Icons.money_off,
                'Jumlah Diskon',
                _money(discount['discountAmount']),
              ),
            ]),
          ),
      ],
    );
  }

  /// Informasi invoice dalam satu section tanpa box/border per field.
  Widget _invoiceInfoCard() {
    final customer = _s('customer');
    final initial = customer == '-' || customer.isEmpty
        ? '?'
        : customer.trim()[0].toUpperCase();

    return _card(
      title: 'INFORMASI INVOICE',
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kRed,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer',
                      style: TextStyle(fontSize: 10, color: kMuted),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      customer,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _plainInvoiceInfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal Terbit',
                  value: _fmtDate(_s('date')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _plainInvoiceInfoTile(
                  icon: Icons.event_outlined,
                  label: 'Jatuh Tempo',
                  value: _fmtDate(_s('dueDate')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _plainInvoiceInfoRow(
            icon: Icons.tag,
            label: 'Nomor Invoice',
            value: _s('series'),
            onCopy: () => _copy(_s('series'), 'Nomor invoice'),
          ),
        ],
      ),
    );
  }

  Widget _plainInvoiceInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 13, color: kRed),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: kMuted),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _plainInvoiceInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 17, color: kRed),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: kMuted)),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            tooltip: 'Salin nomor invoice',
            onPressed: onCopy,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            icon: const Icon(Icons.copy_rounded, size: 16, color: kFaint),
          ),
      ],
    );
  }

  /// Kartu "Alamat & Kontak": alamat dirapikan (title case, tanpa baris
  /// duplikat), kode pos jadi chip, plus tombol salin.
  Widget _addressCard(Map<String, dynamic> addr) {
    final lines = _tidyAddress(addr['addressDisplay']?.toString());
    final joined = lines.join(', ');
    final postal = RegExp(r'\b\d{5}\b').firstMatch(joined)?.group(0);

    return _card(
      title: 'ALAMAT & KONTAK',
      child: lines.isEmpty
          ? const _InlineEmpty(
              icon: Icons.location_off_outlined,
              message: 'Alamat belum tersedia',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: kRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        size: 19,
                        color: kRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alamat Customer',
                            style: TextStyle(fontSize: 10, color: kMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lines.first,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: kInk,
                            ),
                          ),
                          for (final l in lines.skip(1)) ...[
                            const SizedBox(height: 2),
                            Text(
                              l,
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.4,
                                color: kMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: kLine),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (postal != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: kLine,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.markunread_mailbox_outlined,
                              size: 12,
                              color: kMuted,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Kode Pos $postal',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _copy(joined, 'Alamat'),
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Salin'),
                      style: TextButton.styleFrom(
                        foregroundColor: kRed,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  // ─── TAB 2 — ITEM ─────────────────────────────────────────────────────────
  Widget _tabItem() {
    final items = _list('items');

    return _ScrollPage(
      children: [
        _sectionHeader(
          'RINCIAN ITEM',
          count: items.isEmpty ? null : items.length,
        ),
        if (items.isEmpty)
          _card(
            title: '',
            child: const _InlineEmpty(
              icon: Icons.inventory_2_outlined,
              message: 'Belum ada item invoice.',
            ),
          )
        else
          ...List.generate(items.length, (i) => _itemCard(items[i], i + 1)),
      ],
    );
  }

  // ─── TAB 3 — PAYMENT (list ↔ detail) ──────────────────────────────────────
  Widget _tabPembayaran() {
    return _selectedPayment == null
        ? _paymentListView()
        : _paymentDetail(_selectedPayment!);
  }

  Widget _paymentListView() {
    if (_isLoadingPayment) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_paymentError != null) {
      return _relatedDataError(_paymentError!, _loadPaymentEntry);
    }

    return _ScrollPage(
      children: [
        _sectionHeader(
          'DAFTAR PAYMENT',
          count: _paymentList.isEmpty ? null : _paymentList.length,
        ),
        if (_paymentList.isEmpty)
          _card(
            title: '',
            child: const _InlineEmpty(
              icon: Icons.payments_outlined,
              message: 'Belum ada payment',
            ),
          )
        else
          ..._paymentList.map((p) {
            return _listTile(
              icon: Icons.payments_outlined,
              iconColor: kGreen,
              iconBg: const Color(0xFFE8F5E9),
              title: p['name']?.toString() ?? '-',
              status: p['status']?.toString() ?? '-',
              date: p['posting_date']?.toString() ?? '-',
              subtitle: p['party_name']?.toString() ?? '-',
              amount: _money(p['paid_amount']),
              amountColor: kGreen,
              onTap: () => setState(() => _selectedPayment = p),
            );
          }),
      ],
    );
  }

  Widget _paymentDetail(Map<String, dynamic> p) {
    final status = p['status']?.toString() ?? '-';

    return _ScrollPage(
      children: [
        // Hero jumlah dibayar
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payments_outlined, color: kGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jumlah Dibayar',
                      style: TextStyle(fontSize: 11.5, color: kMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _money(p['paid_amount']),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kGreen,
                      ),
                    ),
                  ],
                ),
              ),
              _chip(status),
            ],
          ),
        ),
        _card(
          title: 'RINCIAN PEMBAYARAN',
          child: _infoGroup([
            (Icons.tag, 'Nomor Payment', p['name']?.toString() ?? '-'),
            (
              Icons.calendar_today_outlined,
              'Tanggal Posting',
              p['posting_date']?.toString() ?? '-',
            ),
            (
              Icons.person_outline,
              'Customer',
              p['party_name']?.toString() ?? '-',
            ),
            (
              Icons.receipt_outlined,
              'Outstanding',
              _money(p['outstanding_amount']),
            ),
            (
              Icons.monetization_on_outlined,
              'Allocated Amount',
              _money(p['allocated_amount']),
            ),
          ]),
        ),
      ],
    );
  }

  // ─── TAB 4 — DELIVERY NOTE (list ↔ detail) ────────────────────────────────
  Widget _tabDelivery() {
    return _selectedDelivery == null
        ? _deliveryListView()
        : _deliveryDetail(_selectedDelivery!);
  }

  Widget _deliveryListView() {
    if (_isLoadingDelivery) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_deliveryError != null) {
      return _relatedDataError(_deliveryError!, _loadDeliveryNotes);
    }

    return _ScrollPage(
      children: [
        _sectionHeader(
          'DAFTAR DELIVERY',
          count: _deliveryNoteList.isEmpty ? null : _deliveryNoteList.length,
        ),
        if (_deliveryNoteList.isEmpty)
          _card(
            title: '',
            child: const _InlineEmpty(
              icon: Icons.local_shipping_outlined,
              message: 'Belum ada delivery',
            ),
          )
        else
          ..._deliveryNoteList.map((p) {
            return _listTile(
              icon: Icons.local_shipping_outlined,
              iconColor: kGreen,
              iconBg: const Color(0xFFE8F5E9),
              title: p['name']?.toString() ?? '-',
              status: p['status']?.toString() ?? '-',
              date: p['posting_date']?.toString() ?? '-',
              subtitle: p['customer_name']?.toString() ?? '-',
              onTap: () => setState(() => _selectedDelivery = p),
            );
          }),
      ],
    );
  }

  Widget _deliveryDetail(Map<String, dynamic> p) {
    final items = _list('items');

    return _ScrollPage(
      children: [
        _sectionHeader(
          'RINCIAN DELIVERY',
          count: items.isEmpty ? null : items.length,
        ),
        if (items.isEmpty)
          _card(
            title: '',
            child: const _InlineEmpty(
              icon: Icons.inventory_2_outlined,
              message: 'Belum ada item delivery.',
            ),
          )
        else
          ...List.generate(items.length, (i) => _itemCard(items[i], i + 1)),
      ],
    );
  }

  // ─── TAB 5 — SALES ORDER (list ↔ detail) ──────────────────────────────────
  Widget _tabSales() {
    return _selectedSales == null
        ? _salesListView()
        : _salesDetail(_selectedSales!);
  }

  Widget _salesListView() {
    if (_isLoadingSales) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_salesError != null) {
      return _relatedDataError(_salesError!, _loadSales);
    }

    return _ScrollPage(
      children: [
        _sectionHeader(
          'DAFTAR SALES ORDER',
          count: _salesList.isEmpty ? null : _salesList.length,
        ),
        if (_salesList.isEmpty)
          _card(
            title: '',
            child: const _InlineEmpty(
              icon: Icons.receipt_outlined,
              message: 'Belum ada sales order',
            ),
          )
        else
          ..._salesList.map((p) {
            return _listTile(
              icon: Icons.receipt_outlined,
              iconColor: kOrange,
              iconBg: const Color(0xFFFFF3E0),
              title: p['name']?.toString() ?? '-',
              status: p['status']?.toString() ?? '-',
              date: p['posting_date']?.toString() ?? '-',
              subtitle: p['customer_name']?.toString() ?? '-',
              amount: _money(p['grand_total']),
              amountColor: kOrange,
              onTap: () => setState(() => _selectedSales = p),
            );
          }),
      ],
    );
  }

  Widget _salesDetail(Map<String, dynamic> p) {
    final items = _list('items');

    return _ScrollPage(
      children: [
        _sectionHeader(
          'INFO SALES ORDER',
          count: items.isEmpty ? null : items.length,
        ),
        if (items.isEmpty)
          _card(
            title: '',
            child: const _InlineEmpty(
              icon: Icons.inventory_2_outlined,
              message: 'Belum ada item.',
            ),
          )
        else
          ...List.generate(items.length, (i) => _itemCard(items[i], i + 1)),
      ],
    );
  }

  // ─── SHARED WIDGETS ───────────────────────────────────────────────────────
  Widget _relatedDataError(String message, Future<void> Function() onRetry) {
    return _ScrollPage(
      children: [
        _card(
          title: '',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kMuted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Coba Lagi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, {int? count}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppFonts.primaryFont,
              color: kFaint,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.45,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: kRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kRed,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppCardStyles.major,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: kFaint,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.45,
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }

  /// Daftar info: ikon dalam kotak tint, label kecil di atas, nilai di bawah.
  /// Nilai panjang (alamat, nama PT) otomatis wrap rapi di kiri.
  Widget _infoGroup(List<(IconData, String, String)> rows) {
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: kRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(rows[i].$1, size: 16, color: kRed),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rows[i].$2,
                        style: const TextStyle(fontSize: 10, color: kMuted),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        rows[i].$3,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: kInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (i != rows.length - 1) const Divider(height: 1, color: kLine),
        ],
      ],
    );
  }

  /// Kartu item (dipakai di tab Item, Delivery detail, Sales detail).
  Widget _itemCard(Map<String, dynamic> item, int index) {
    final code = item['itemCode']?.toString() ?? '-';
    final name = item['itemName']?.toString() ?? '-';
    final qty = item['qty']?.toString() ?? '-';
    final date = item['date']?.toString() ?? '-';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AppCardStyles.compact,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: kInk,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: kInk,
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
                          _money(item['amount']),
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kInk,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: kMuted),
                ),
                const SizedBox(height: 10),
                const _DashedLine(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Qty ${qty}x  •  Harga ${_money(item['rate'])}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: kMuted,
                        ),
                      ),
                    ),
                    if (date != '-') ...[
                      const SizedBox(width: 8),
                      Text(
                        _fmtDate(date),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: kMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Baris list yang bisa di-tap (payment / delivery / sales order).
  Widget _listTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String status,
    required String date,
    required String subtitle,
    required VoidCallback onTap,
    String? amount,
    Color amountColor = kInk,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: AppCardStyles.compact,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 21, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: kInk,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _chip(status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 12,
                              color: kFaint,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                subtitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: kMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 11,
                                color: kFaint,
                              ),
                            ),
                            if (amount != null)
                              Text(
                                amount,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: amountColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.black26,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    final Color fg;
    final Color bg;
    if (_isPaidLike(label)) {
      fg = kGreen;
      bg = const Color(0xFFE8F5E9);
    } else if (_isUnpaidLike(label)) {
      fg = kRed;
      bg = const Color(0xFFFDEDED);
    } else {
      fg = const Color(0xFF1565C0);
      bg = const Color(0xFFE3F2FD);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 3.0;
        const dashGap = 3.0;
        final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();

        return Row(
          children: List.generate(
            count,
            (_) => const Padding(
              padding: EdgeInsets.only(right: dashGap),
              child: SizedBox(
                width: dashWidth,
                height: 1,
                child: ColoredBox(color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Halaman scroll dengan ScrollController milik sendiri
/// (tidak lagi membuat controller baru di setiap build).
class _ScrollPage extends StatefulWidget {
  final List<Widget> children;
  const _ScrollPage({required this.children});

  @override
  State<_ScrollPage> createState() => _ScrollPageState();
}

class _ScrollPageState extends State<_ScrollPage> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          controller: _controller,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(top: 10, bottom: 28),
          children: widget.children,
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({
    required this.message,
    this.icon = Icons.inventory_2_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: const Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    ),
  );
}
