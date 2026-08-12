import 'package:flutter/material.dart';
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

  bool _isLoadingSales = false;
  List<Map<String, dynamic>> _salesList = [];
  bool _salesLoaded = false;

  bool _isLoadingDelivery = false;
  List<Map<String, dynamic>> _deliveryNoteList = [];
  bool _deliveryLoaded = false;


  static const Color kRed   = Color(0xFFC0392B);
  static const Color kGreen = Color(0xFF27AE60);
  static const Color kBg    = Color(0xFFF2F2F7);

  // ── Null-safe helpers ─────────────────────────────────────────────────────
  String _s(String key, [String fallback = '-']) =>
      widget.invoice[key]?.toString() ?? fallback;

  int _i(String key, [int fallback = 0]) =>
      widget.invoice[key] is int ? widget.invoice[key] as int : fallback;

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
  // ─────────────────────────────────────────────────────────────────────────

  String _rupiah(int v) {
    if (v == 0) return 'Rp 0';
    final s = v.toString();
    String r = '';
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) r = '.$r';
      r = s[i] + r;
      c++;
    }
    return 'Rp $r';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Reset payment detail saat pindah tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedPayment = null;
          _selectedDelivery = null; 
          _selectedSales = null;
        });
        if (_tabController.index == 2) {
          _loadPaymentEntry();
        }
        if (_tabController.index == 3) {
          _loadDeliveryNotes();
        }
        if (_tabController.index == 4) {
          _loadSales();
        }
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
    final bool isBelumBayar = _s('status') == 'Belum Bayar';

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildHeader(context, isBelumBayar),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              // Matikan swipe saat di payment detail agar back di header bisa berfungsi
              physics: (_selectedPayment != null || _selectedDelivery != null || _selectedSales != null)
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
    );
  }

  Future<void> _loadPaymentEntry() async {
    if (_paymentLoaded) return;

    setState(() => _isLoadingPayment = true);

    final soName      = _s('series');
    final invoiceName = _s('name');

    if (soName.isEmpty || soName == '-') {
      setState(() {
        _isLoadingPayment = false;
        _paymentLoaded = true;
      });
      return;
    }

    final activeState = context.read<ActiveCompanyCubit>().state as ActiveCompanyReady?;
    final branchName  = activeState?.activeCompany?.branchName ?? '';
    final bcid        = activeState?.activeCompany?.branchCustomerCode ?? '';
    final credential  = await BranchCredentialService().fetchCredential(branchName);

    if (credential == null || !mounted) {
      setState(() => _isLoadingPayment = false);
      return;
    }

    final results = await PaymentEntryService().fetchBySOName(
      baseUrl:     credential.url,
      token:       credential.token,
      bcid:        bcid,
      soName:      soName,
      invoiceName: invoiceName,
    );

    if (!mounted) return;

    setState(() {
      _paymentList = results ?? [];
      _isLoadingPayment = false;
      _paymentLoaded = true;
    });
  }

  Future<void> _loadDeliveryNotes() async {
    if (_deliveryLoaded) return;

    setState(() => _isLoadingDelivery = true);

    final soName      = _s('series');  
    final invoiceName = _s('name');  

    if (soName.isEmpty || soName == '-') {
      setState(() {
        _isLoadingDelivery = false;
        _deliveryLoaded = true;
      });
      return;
    }

    final activeState = context.read<ActiveCompanyCubit>().state as ActiveCompanyReady?;
    final branchName  = activeState?.activeCompany?.branchName ?? '';
    final bcid        = activeState?.activeCompany?.branchCustomerCode ?? '';
    final credential  = await BranchCredentialService().fetchCredential(branchName);

    if (credential == null || !mounted) {
      setState(() => _isLoadingDelivery = false);
      return;
    }

    final results = await DeliveryNoteService().fetchBySOName(
      baseUrl:     credential.url,
      token:       credential.token,
      bcid:        bcid,
      invoiceName: invoiceName,
      soName:      soName,       // SO-... → body
      refName: invoiceName,  // SJ-... → URL
    );

    if (!mounted) return;

    setState(() {
      _deliveryNoteList = results ?? [];
      _isLoadingDelivery = false;
      _deliveryLoaded = true;
    });
  }

  Future<void> _loadSales() async {
    if (_salesLoaded) return;

    setState(() => _isLoadingSales = true);

    final soName      = _s('series');
    final invoiceName = _s('name');

    if (soName.isEmpty || soName == '-') {
      setState(() {
        _isLoadingSales = false;
        _salesLoaded = true;
      });
      return;
    }

    final activeState = context.read<ActiveCompanyCubit>().state as ActiveCompanyReady?;
    final branchName  = activeState?.activeCompany?.branchName ?? '';
    final bcid        = activeState?.activeCompany?.branchCustomerCode ?? '';
    final credential  = await BranchCredentialService().fetchCredential(branchName);

    if (credential == null || !mounted) {
      setState(() => _isLoadingSales = false);
      return;
    }

    final results = await SalesOrderService().fetchBySOName(
      baseUrl:     credential.url,
      token:       credential.token,
      bcid:        bcid,
      soName:      soName,
      invoiceName: invoiceName,
    );

    if (!mounted) return;

    setState(() {
      _salesList = results ?? [];
      _isLoadingSales = false;
      _salesLoaded = true;
    });
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isBelumBayar) {
    return Container(
      color: kRed,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Back + title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_selectedPayment != null) {
                        setState(() => _selectedPayment = null);
                      } else if (_selectedDelivery != null) {
                        setState(() => _selectedDelivery = null);
                      } else if (_selectedSales != null){
                        setState(() => _selectedSales = null);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedPayment != null
                          ? 'Detail Pembayaran'
                          : _selectedDelivery != null 
                          ? 'Detail Delivery' : 'Detail Invoice',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.white, size: 22),
                ],
              ),
            ),

            // Series / status / total — disembunyikan saat payment detail
            if (_selectedPayment != null) ...[
              // ── Info ringkas payment di header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedPayment!['name']?.toString() ?? '-',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: Text(
                            _selectedPayment!['status']?.toString() ?? '-',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: Colors.white60),
                          const SizedBox(width: 4),
                          Text(
                            _selectedPayment!['posting_date']?.toString() ?? '-',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.person_outline,
                              size: 12, color: Colors.white60),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _selectedPayment!['party_name']?.toString() ?? '-',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.payments_outlined,
                              size: 12, color: Colors.white60),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _selectedPayment!['outstanding_amount']?.toString() ?? '-',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (_selectedDelivery != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDelivery!['name']?.toString() ?? '-',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: Text(
                            _selectedDelivery!['status']?.toString() ?? '-',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white60),
                          const SizedBox(width: 4),
                          Text(
                            _selectedDelivery!['date']?.toString() ?? '-',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.person_outline, size: 12, color: Colors.white60),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _selectedDelivery!['customer']?.toString() ?? '-',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_s('series'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_s('date'),
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isBelumBayar ? Colors.white24 : kGreen,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isBelumBayar
                                ? Colors.white38
                                : Colors.transparent),
                      ),
                      child: Text(_s('status'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Tagihan',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(_rupiah(_i('nilai')),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              tabs: const [
                Tab(text: 'Detail'),
                Tab(text: 'Item'),
                Tab(text: 'Payment'),
                Tab(text: 'Delivery Note'),
                Tab(text: 'Sales Order'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabDetail() {
    final addr     = _map('address');
    final po       = _map('customerPO');
    final taxes    = _list('taxes');
    final int taxTotal = _i('taxTotal');
    final discount = _map('discount');

    String _stripHtml(String? html, [String fallback = '-']) {
      if (html == null || html.isEmpty) return fallback;
      return html
          .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();
    }

    final ScrollController scrollController = ScrollController(); 

    return Scrollbar(                                             
      controller: scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _card(
                    title: 'INFORMASI INVOICE',
                    child: Column(children: [
                      _row(Icons.tag,                     'Name',             _s('series')),
                      _row(Icons.calendar_today_outlined, 'Date',             _s('date')),
                      _row(Icons.person_outline,          'Customer',         _s('customer')),
                      _row(Icons.event_outlined,          'Payment Due Date', _s('dueDate')),
                    ]),
                  ),
                  // _card(
                  //   title: 'CUSTOMER PO DETAILS',
                  //   child: Column(children: [
                  //     _row(Icons.receipt_long_outlined,   "Customer's Purchase Order",
                  //         po['number']?.toString() ?? '-'),
                  //     _row(Icons.calendar_today_outlined, "Customer's PO Date",
                  //         po['date']?.toString() ?? '-'),
                  //   ]),
                  // ),
                  _card(
                    title: 'ADDRESS AND CONTACT',
                    child: Column(children: [
                      _row(Icons.location_on_outlined,    'Customer Address',
                          _stripHtml(addr['addressDisplay']?.toString() ?? '-')),
                      // _row(Icons.local_shipping_outlined, 'Shipping Address Name',
                      //     addr['shippingAddressName']?.toString() ?? '-'),
                      // _row(Icons.person_outline,          'Contact Person',
                      //     addr['contactPerson']?.toString() ?? '-'),
                    ]),
                  ),
                  _card(
                    title: 'SALES TAXES AND CHARGES',
                    child: Column(children: [
                      Row(children: const [
                        Expanded(flex: 2, child: _ColHeader('Type')),
                        Expanded(flex: 3, child: _ColHeader('Account Head')),
                        SizedBox(width: 46, child: _ColHeader('Rate', center: true)),
                        Expanded(flex: 2, child: _ColHeader('Amount', right: true)),
                      ]),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      if (taxes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text('Tidak ada pajak',
                                style: TextStyle(fontSize: 12, color: Colors.black38)),
                          ),
                        )
                      else
                        ...taxes.map((t) {
                          final rate = t['rate'] is num ? (t['rate'] as num).toDouble() : 0.0;
                          final amt  = t['amount'] is int ? t['amount'] as int : 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(children: [
                              Expanded(flex: 2, child: Text(t['type']?.toString() ?? '-', style: const TextStyle(fontSize: 12))),
                              Expanded(flex: 3, child: Text(t['accountHead']?.toString() ?? '-', style: const TextStyle(fontSize: 12))),
                              SizedBox(width: 46, child: Text('${rate.toStringAsFixed(0)}%', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                              Expanded(flex: 2, child: Text(_rupiah(amt), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                            ]),
                          );
                        }),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text(_rupiah(taxTotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ]),
                  ),
                  if ((discount['baseDiscountAmount'] ?? 0) != 0)
                  _card(
                    title: 'ADDITIONAL DISCOUNT',
                    child: Column(children: [
                      _row(Icons.tune,      'Apply Additional Discount On',
                          discount['applyOn']?.toString() ?? '-'),
                      _row(Icons.percent,   'Additional Discount %',
                          '${discount['discountPercent']?.toString() ?? '0'}%'),
                      _row(Icons.money_off, 'Additional Discount Amount',
                          _rupiah(discount['discountAmount'] is int
                              ? discount['discountAmount'] as int
                              : 0)),
                    ]),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem() {
    final items = _list('items');
    final int grandTotal = _i('nilai');
    final displayItems = items.isNotEmpty
        ? items
        : [
            {'itemCode': 'Paket Pemeriksaan Lengkap', 'itemName': 'Paket Pemeriksaan Lengkap', 'qty': 3, 'date': '12 Apr 2024', 'amount': 4500000},
            {'itemCode': 'Paket Pemeriksaan Lengkap', 'itemName': 'Paket Pemeriksaan Lengkap', 'qty': 3, 'date': '12 Apr 2024', 'amount': 4500000},
            {'itemCode': 'Paket Pemeriksaan Lengkap', 'itemName': 'Paket Pemeriksaan Lengkap', 'qty': 3, 'date': '12 Apr 2024', 'amount': 4500000},
          ];

    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          overscroll: false,
        ),
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _card(
                    title: 'RINCIAN ITEM',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...displayItems.map((item) {
                          final code = item['itemCode']?.toString() ?? '-';
                          final nama = item['itemName']?.toString() ?? '-';
                          final qty  = item['qty'];
                          final date = item['date'];
                          final amt  = item['amount'];
                          final rate = item['rate'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Item Code'),
                                _valueBold(code),
                                const SizedBox(height: 10),
                                _label('Item Name'),
                                _valueBold(nama),
                                const SizedBox(height: 10),
                                _label('Qty'),
                                _value('${qty}x'),
                                const SizedBox(height: 10),
                                _label('Date'),
                                _value(date),
                                const SizedBox(height: 10),
                                _label('Rate'),
                                _value(_rupiah(rate)),
                                const SizedBox(height: 10),
                                _label('Amount'),
                                _value(_rupiah(amt)),
                                const Divider(height: 24),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 3 — PAYMENT  (list ↔ detail)
  Widget _tabPembayaran() {
    return _selectedPayment == null
        ? _paymentList_()
        : _paymentDetail(_selectedPayment!);
  }

  // ── Payment List ──────────────────────────────────────────────────────────
  Widget _paymentList_() {
    if (_isLoadingPayment) {
      return const Center(child: CircularProgressIndicator());
    }

    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_paymentList.isEmpty)
                    _card(
                      title: 'DAFTAR PAYMENT',
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Belum ada payment',
                            style: TextStyle(fontSize: 12, color: Colors.black38),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_paymentList.length, (i) {
                      final p = _paymentList[i];
                      final paidAmount = (p['paid_amount'] as num?)?.toInt() ?? 0;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPayment = p),
                        child: _card(
                          title: i == 0 ? 'DAFTAR PAYMENT' : '',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.payments_outlined,
                                    size: 20,
                                    color: kGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p['name']?.toString() ?? '-',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _chip(p['status']?.toString() ?? '-'),
                                          Text(
                                            p['posting_date']?.toString() ?? '-',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            const Icon(Icons.person_outline,
                                                size: 12, color: Colors.black38),
                                            const SizedBox(width: 4),
                                            Text(
                                              p['party_name']?.toString() ?? '-',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ]),
                                          Text(
                                            _rupiah(paidAmount),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: kGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.chevron_right,
                                    color: Colors.black26, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Payment Detail ────────────────────────────────────────────────────────
  Widget _paymentDetail(Map<String, dynamic> p) {
    final paidAmount        = (p['paid_amount'] as num?)?.toInt() ?? 0;
    final outstandingAmount = (p['outstanding_amount'] as num?)?.toInt() ?? 0;
    final allocatedAmount   = (p['allocated_amount'] as num?)?.toInt() ?? 0;
    final status            = p['status']?.toString() ?? '-';
    final bool isBelumLunas = status == 'Unpaid' || status == 'Belum Lunas';
    final Color statusColor = isBelumLunas ? kRed : kGreen;
    final Color statusBg    = isBelumLunas
        ? const Color(0xFFFDEDED)
        : const Color(0xFFE8F5E9);

    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _card(
                    title: 'RINCIAN PEMBAYARAN',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Name + Status sejajar ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                p['name']?.toString() ?? '-',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(status,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF5F5F5)),

                        // ── Detail rows ──
                        _row(Icons.calendar_today_outlined,  'Posting Date',       p['posting_date']?.toString() ?? '-'),
                        _row(Icons.person_outline,           'Customer',           p['party_name']?.toString() ?? '-'),
                        _row(Icons.receipt_outlined,         'Outstanding Amount', _rupiah(outstandingAmount)),
                        _row(Icons.monetization_on_outlined, 'Grand Total',        _rupiah(paidAmount)),
                        _row(Icons.monetization_on_outlined, 'Allocated Amount',   _rupiah(allocatedAmount)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _valueBold(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _value(String text, {Color color = Colors.black}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: color,
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0))),
    );
  }

  // TAB 4 — DELIVERY (placeholder)
  Widget _tabDelivery() {
    return _selectedDelivery == null
        ? _deliveryList_()
        : _deliveryDetail(_selectedDelivery!);
  }

  Widget _deliveryList_() {
    if (_isLoadingDelivery) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayDelivery = _deliveryNoteList; // ← dari API, bukan _list('delivery')

    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (displayDelivery.isEmpty)
                    _card(
                      title: 'DAFTAR DELIVERY',
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Belum ada delivery',
                              style: TextStyle(fontSize: 12, color: Colors.black38)),
                        ),
                      ),
                    )
                  else
                    ...List.generate(displayDelivery.length, (i) {
                      final p = displayDelivery[i];

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDelivery = p),
                        child: _card(
                          title: i == 0 ? 'DAFTAR DELIVERY' : '',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.local_shipping_outlined,
                                      size: 20, color: kGreen),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p['name']?.toString() ?? '-',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _chip(p['status']?.toString() ?? '-'),
                                          Text(
                                            p['posting_date']?.toString() ?? '-', // ← fix: posting_date bukan date
                                            style: const TextStyle(
                                                fontSize: 11, color: Colors.black38),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.person_outline,
                                            size: 12, color: Colors.black38),
                                        const SizedBox(width: 4),
                                        Text(
                                          p['customer_name']?.toString() ?? '-', // ← fix: customer_name sesuai API
                                          style: const TextStyle(
                                              fontSize: 11, color: Colors.black54),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.chevron_right,
                                    color: Colors.black26, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryDetail(Map<String, dynamic> p) {
    final grandTotal1 =
        p['grandTotal'] is int ? p['grandTotal'] as int : 0;
    final items = _list('items');
    final displayItems = items.isNotEmpty
        ? items
        : [
            {
              'itemCode': 'D-004',
              'itemName': 'Paket Pemeriksaan Lengkap',
              'qty': '12',
              'date': "12 Apr 2024",
              'amount': 'Gudang Utama'
            },
            {
              'itemCode': 'D-005',
              'itemName': 'Paket Pemeriksaan Lengkap',
              'qty': '12',
              'date': "12 Apr 2024",
              'amount': 'Gudang Utama'
            },
            {
              'itemCode': 'D-006',
              'itemName': 'Paket Pemeriksaan Lengkap',
              'qty': '12',
              'date': "12 Apr 2024",
              'amount': 'Gudang Utama'
            },
          ];

    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          overscroll: false,
        ),
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _card(
                    title: 'RINCIAN DELIVERY',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...displayItems.map((item) {
                          final itemCode =
                              item['itemCode']?.toString() ?? '-';
                          final itemName =
                              item['itemName']?.toString() ?? '-';
                          final qty =
                              item['qty']?.toString() ?? '-';
                          final date =
                              item['date']?.toString() ?? '-';
                          final amount =
                              item['amount']?.toString() ?? '-';
                          final rate =
                              item['rate']?.toString() ?? '-';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Item Code'),
                                _valueBold(itemCode),
                                const SizedBox(height: 10),
                                _label('Item Name'),
                                _value(itemName),
                                const SizedBox(height: 10),
                                _label('Qty'),
                                _value(qty),
                                const SizedBox(height: 10),
                                _label('Date'),
                                _value(date),
                                const SizedBox(height: 10),
                                _label('Rate'),
                                _value(rate),
                                const SizedBox(height: 10),
                                _label('Amount'),
                                _value(amount),
                                const Divider(height: 24),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabSales() {
    return _selectedSales == null
        ? _salesList_()
        : _salesDetail(_selectedSales!);
  }

  Widget _salesList_() {
    if (_isLoadingSales) {
      return const Center(child: CircularProgressIndicator());
    }

    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_salesList.isEmpty)
                    _card(
                      title: 'DAFTAR SALES INVOICE',
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Belum ada sales invoice',
                            style: TextStyle(fontSize: 12, color: Colors.black38),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_salesList.length, (i) {
                      final p = _salesList[i];
                      final grandTotal = (p['grand_total'] as num?)?.toInt() ?? 0;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSales = p),
                        child: _card(
                          title: i == 0 ? 'DAFTAR SALES INVOICE' : '',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_outlined,
                                    size: 20,
                                    color: Color(0xFFF57C00),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p['name']?.toString() ?? '-',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _chip(p['status']?.toString() ?? '-'),
                                          Text(
                                            p['posting_date']?.toString() ?? '-',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            const Icon(Icons.person_outline,
                                                size: 12, color: Colors.black38),
                                            const SizedBox(width: 4),
                                            Text(
                                              p['customer_name']?.toString() ?? '-',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ]),
                                          Text(
                                            _rupiah(grandTotal),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFF57C00),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.chevron_right,
                                    color: Colors.black26, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _salesDetail(Map<String, dynamic> p) {
    final grandTotal = (p['grand_total'] as num?)?.toInt() ?? 0;
    final outstanding = (p['outstanding_amount'] as num?)?.toInt() ?? 0;
    final ScrollController scrollController = ScrollController();
    final items = _list('items');
    final displayItems = items.isNotEmpty
        ? items
        : [];

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _card(
                    title: 'INFO SALES INVOICE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...displayItems.map((item) {
                          final itemCode =
                              item['itemCode']?.toString() ?? '-';
                          final itemName =
                              item['itemName']?.toString() ?? '-';
                          final qty =
                              item['qty']?.toString() ?? '-';
                          final date =
                              item['date']?.toString() ?? '-';
                          final amount =
                              item['amount']?.toString() ?? '-';
                          final rate =
                              item['rate']?.toString() ?? '-';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Item Code'),
                                _valueBold(itemCode),
                                const SizedBox(height: 10),
                                _label('Item Name'),
                                _value(itemName),
                                const SizedBox(height: 10),
                                _label('Qty'),
                                _value(qty),
                                const SizedBox(height: 10),
                                _label('Date'),
                                _value(date),
                                const SizedBox(height: 10),
                                _label('Rate'),
                                _value(rate),
                                const SizedBox(height: 10),
                                _label('Amount'),
                                _value(amount),
                                const Divider(height: 24),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ─── SHARED WIDGETS ───────────────────────────────────────────────────────
  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value, {
    Color valueColor = Colors.black87,
    bool valueBold = false,
    bool multiline = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.black26),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,                          
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black45)),
              ),
              Expanded(
                flex: 3,                          
                child: Text(value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 13,
                        color: valueColor,
                        fontWeight: valueBold
                            ? FontWeight.bold
                            : FontWeight.w500)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
      ],
    );
  }

  }

  Widget _rowMultiline(
    IconData icon,
    String label,
    String value, {
    Color valueColor = Colors.black87,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: Colors.black26),
              const SizedBox(width: 10),
              SizedBox(
                width: 120,
                child: Text(label,
                    style: const TextStyle(fontSize: 13, color: Colors.black45)),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 13,
                      color: valueColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
      ],
    );
  }

class _ColHeader extends StatelessWidget {
  final String text;
  final bool center;
  final bool right;
  const _ColHeader(this.text, {this.center = false, this.right = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center
          ? TextAlign.center
          : right
              ? TextAlign.right
              : TextAlign.left,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.black38),
    );
  }
}
