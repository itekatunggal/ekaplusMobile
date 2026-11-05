import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sales_order_item_detail_page.dart';

class SalesOrderDetailPage extends StatefulWidget {
  const SalesOrderDetailPage({
    super.key,
    required this.salesOrder,
    this.baseUrl = '',
    this.token = '',
  });
  final Map<String, dynamic> salesOrder;
  final String baseUrl, token;
  @override
  State<SalesOrderDetailPage> createState() => _SalesOrderDetailPageState();
}

class _SalesOrderDetailPageState extends State<SalesOrderDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _onlyPending = false;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _s(String key) => widget.salesOrder[key]?.toString() ?? '-';
  double _n(String key) {
    final value = widget.salesOrder[key];
    return value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<Map<String, dynamic>> get _items =>
      (widget.salesOrder['items'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Detail Sales Order',
    showBackButton: true,
    bodyPadding: EdgeInsets.zero,
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: _hero(),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              color: Colors.white,
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: AppColors.primaryColor,
                labelStyle: _style(
                  10.5,
                  FontWeight.w700,
                  AppColors.primaryColor,
                ),
                tabs: const [
                  Tab(text: 'Ringkasan'),
                  Tab(text: 'Produk'),
                  Tab(text: 'Pengiriman'),
                  Tab(text: 'Invoice'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _summary(),
                  _products(),
                  _historyHint('pengiriman'),
                  _historyHint('invoice'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _hero() => _surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _s('name'),
                    style: _style(14, FontWeight.w700, const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _date(_s('transactionDate')),
                    style: _style(
                      10.5,
                      FontWeight.w400,
                      const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            _badge(_status(_s('status')), success: _s('status') == 'Completed'),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _money(_n('grandTotal'), _s('currency')),
          style: _style(18, FontWeight.w700, const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 14),
        _progress('Pengiriman', _n('perDelivered'), 'Terkirim'),
        const SizedBox(height: 10),
        _progress('Penagihan', _n('perBilled'), 'Ditagihkan'),
      ],
    ),
  );

  Widget _summary() => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      _surface(
        child: Column(
          children: [
            _row('Nomor Sales Order', _s('name')),
            _row('Tanggal Pesanan', _date(_s('transactionDate'))),
            _row('Target Pengiriman', _date(_s('deliveryDate'))),
            _row('Customer PO', _s('customerPoNo')),
            _row('Tanggal PO', _date(_s('customerPoDate'))),
            _row('Termin', _s('paymentTermsTemplate')),
            _row(
              'Grand Total',
              _money(_n('grandTotal'), _s('currency')),
              last: true,
            ),
          ],
        ),
      ),
      if (_s('shippingAddress') != '-') ...[
        const SizedBox(height: 12),
        _surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alamat Pengiriman',
                style: _style(11, FontWeight.w700, const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 7),
              Text(
                _s('shippingAddress'),
                style: _style(10.5, FontWeight.w400, const Color(0xFF475569)),
              ),
            ],
          ),
        ),
      ],
    ],
  );

  Widget _products() {
    final summary = widget.salesOrder['itemSummary'] is Map
        ? Map<String, dynamic>.from(widget.salesOrder['itemSummary'])
        : <String, dynamic>{};
    final shown = _onlyPending
        ? _items.where((e) => _num(e['pendingDeliveryQty']) > 0).toList()
        : _items;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _surface(
          child: Row(
            children: [
              _metric('${summary['totalRows'] ?? _items.length}', 'Produk'),
              _metric('${summary['remainingRows'] ?? 0}', 'Belum Terkirim'),
              _metric('${summary['overdueRows'] ?? 0}', 'Terlambat'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _filter(
              'Semua',
              !_onlyPending,
              () => setState(() => _onlyPending = false),
            ),
            const SizedBox(width: 7),
            _filter(
              'Belum Terkirim',
              _onlyPending,
              () => setState(() => _onlyPending = true),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (shown.isEmpty)
          _empty('Tidak ada produk pada filter ini.')
        else
          ...shown.map(_product),
      ],
    );
  }

  Widget _product(Map<String, dynamic> item) {
    final overdue = item['isOverdue'] == true;
    final overdueDays = _num(item['overdueDays']).toInt();
    return _surface(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () => _openItem(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item['itemName']?.toString() ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _style(12, FontWeight.w700, const Color(0xFF1E293B)),
                ),
              ),
              if (overdue)
                _badge(
                  'Terlambat${overdueDays > 0 ? ' $overdueDays hari' : ''}',
                  danger: true,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item['itemCode']?.toString() ?? '-',
            style: _style(10, FontWeight.w500, const Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            'Target ${_date(item['date']?.toString() ?? '-')}',
            style: _style(10, FontWeight.w400, const Color(0xFF64748B)),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              _qty('Dipesan', _num(item['qty']), item['uom']),
              _qty('Terkirim', _num(item['deliveredQty']), item['uom']),
              _qty(
                'Sisa',
                _num(item['remainingQty']),
                item['uom'],
                strong: true,
              ),
            ],
          ),
          if (_num(item['overDeliveredQty']) > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Lebih Kirim ${_formatQty(_num(item['overDeliveredQty']))} ${item['uom']}',
              style: _style(10, FontWeight.w600, const Color(0xFFD97706)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _historyHint(String type) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 28,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Riwayat $type tersedia per produk.',
            textAlign: TextAlign.center,
            style: _style(13, FontWeight.w700, const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 5),
          Text(
            'Buka tab Produk lalu pilih produk untuk melihat riwayat yang tepat tanpa menghitung ganda.',
            textAlign: TextAlign.center,
            style: _style(
              11,
              FontWeight.w400,
              const Color(0xFF64748B),
            ).copyWith(height: 1.4),
          ),
        ],
      ),
    ),
  );

  Future<void> _openItem(Map<String, dynamic> item) async {
    final rowId = item['rowId']?.toString() ?? '';
    if (rowId.isEmpty || rowId == '-' || widget.baseUrl.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalesOrderItemDetailPage(
          baseUrl: widget.baseUrl,
          token: widget.token,
          salesOrder: _s('name'),
          salesOrderItem: rowId,
        ),
      ),
    );
  }

  Widget _surface({
    required Widget child,
    EdgeInsets margin = EdgeInsets.zero,
    VoidCallback? onTap,
  }) => Container(
    margin: margin,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF1F5F9)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D0F172A),
          blurRadius: 9,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    ),
  );
  Widget _progress(String label, double value, String caption) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: _style(10, FontWeight.w500, const Color(0xFF475569)),
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: _style(10, FontWeight.w700, const Color(0xFF1E293B)),
          ),
        ],
      ),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value.clamp(0, 100) / 100,
          minHeight: 6,
          color: AppColors.primaryColor,
          backgroundColor: const Color(0xFFF1F5F9),
        ),
      ),
      const SizedBox(height: 4),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          caption,
          style: _style(9, FontWeight.w400, const Color(0xFF94A3B8)),
        ),
      ),
    ],
  );
  Widget _row(String label, String value, {bool last = false}) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: _style(10, FontWeight.w400, const Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: _style(10.5, FontWeight.w600, const Color(0xFF1E293B)),
          ),
        ),
      ],
    ),
  );
  Widget _metric(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(value, style: _style(15, FontWeight.w700, AppColors.primaryColor)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: _style(9, FontWeight.w400, const Color(0xFF64748B)),
        ),
      ],
    ),
  );
  Widget _filter(String label, bool selected, VoidCallback tap) => InkWell(
    onTap: tap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: _style(
          10.5,
          FontWeight.w700,
          selected ? Colors.white : const Color(0xFF334155),
        ),
      ),
    ),
  );
  Widget _qty(String label, double value, Object? uom, {bool strong = false}) =>
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: _style(9, FontWeight.w400, const Color(0xFF64748B)),
            ),
            const SizedBox(height: 3),
            Text(
              '${_formatQty(value)} ${uom ?? '-'}',
              overflow: TextOverflow.ellipsis,
              style: _style(
                10.5,
                strong ? FontWeight.w700 : FontWeight.w600,
                strong ? AppColors.primaryColor : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      );
  Widget _empty(String text) => Padding(
    padding: const EdgeInsets.all(30),
    child: Center(
      child: Text(
        text,
        style: _style(11, FontWeight.w500, const Color(0xFF64748B)),
      ),
    ),
  );
}

Widget _badge(String label, {bool danger = false, bool success = false}) {
  final color = danger
      ? const Color(0xFFDC2626)
      : success
      ? const Color(0xFF059669)
      : const Color(0xFFD97706);
  return Container(
    constraints: const BoxConstraints(maxWidth: 145),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(.09),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _style(8.5, FontWeight.w700, color),
    ),
  );
}

TextStyle _style(double size, FontWeight weight, Color color) => TextStyle(
  fontFamily: AppFonts.primaryFont,
  fontSize: size,
  fontWeight: weight,
  color: color,
);
double _num(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _status(String value) => switch (value) {
  'To Deliver' => 'Menunggu Pengiriman',
  'To Bill' => 'Menunggu Tagihan',
  'To Deliver and Bill' => 'Pengiriman & Tagihan',
  'Completed' => 'Selesai',
  _ => value,
};
String _date(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? value : DateFormat('d MMM yyyy', 'id_ID').format(date);
}

String _money(double value, String currency) => NumberFormat.currency(
  locale: 'id_ID',
  symbol: currency == 'IDR' ? 'Rp' : '$currency ',
  decimalDigits: currency == 'IDR' ? 0 : 2,
).format(value);
String _formatQty(double value) =>
    NumberFormat('#,##0.###', 'id_ID').format(value);
