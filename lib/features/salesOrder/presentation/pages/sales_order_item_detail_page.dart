import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_item_detail_model.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/sales_order_item_detail_service.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/sales_order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesOrderItemDetailPage extends StatefulWidget {
  const SalesOrderItemDetailPage({
    super.key,
    required this.baseUrl,
    required this.token,
    required this.salesOrder,
    required this.salesOrderItem,
  });
  final String baseUrl, token, salesOrder, salesOrderItem;
  @override
  State<SalesOrderItemDetailPage> createState() =>
      _SalesOrderItemDetailPageState();
}

class _SalesOrderItemDetailPageState extends State<SalesOrderItemDetailPage> {
  late Future<SalesOrderItemDetail> _future;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = SalesOrderItemDetailService().fetch(
    baseUrl: widget.baseUrl,
    token: widget.token,
    salesOrder: widget.salesOrder,
    salesOrderItem: widget.salesOrderItem,
  );
  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Detail Produk',
    showBackButton: true,
    bodyPadding: EdgeInsets.zero,
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: FutureBuilder<SalesOrderItemDetail>(
          future: _future,
          builder: (_, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }
            if (snapshot.hasError) {
              final message = snapshot.error is SalesOrderApiException
                  ? (snapshot.error as SalesOrderApiException).message
                  : 'Detail produk gagal dimuat.';
              return _error(message);
            }
            return _content(snapshot.data!);
          },
        ),
      ),
    ),
  );

  Widget _error(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
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
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Detail produk belum dapat dimuat',
            textAlign: TextAlign.center,
            style: _style(13, FontWeight.w700, const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: _style(
              11,
              FontWeight.w400,
              const Color(0xFF64748B),
            ).copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => setState(_load),
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Coba Lagi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _content(SalesOrderItemDetail detail) => DefaultTabController(
    length: 3,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: _surface(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.item.itemName,
                  style: _style(14, FontWeight.w700, const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 3),
                Text(
                  detail.item.itemCode,
                  style: _style(10.5, FontWeight.w500, const Color(0xFF64748B)),
                ),
                const SizedBox(height: 5),
                Text(
                  detail.salesOrder,
                  style: _style(10.5, FontWeight.w600, AppColors.primaryColor),
                ),
                const Divider(height: 22, color: Color(0xFFF1F5F9)),
                Row(
                  children: [
                    _qty('Dipesan', detail.item.qty, detail.item.uom),
                    _qty('Terkirim', detail.item.deliveredQty, detail.item.uom),
                    _qty(
                      'Sisa',
                      detail.item.remainingQty,
                      detail.item.uom,
                      strong: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: TabBar(
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: AppColors.primaryColor,
            labelStyle: _style(10.5, FontWeight.w700, AppColors.primaryColor),
            tabs: const [
              Tab(text: 'Ringkasan'),
              Tab(text: 'Pengiriman'),
              Tab(text: 'Invoice'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _summary(detail),
              _history(detail, detail.deliveryNotes, isInvoice: false),
              _history(detail, detail.salesInvoices, isInvoice: true),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _summary(SalesOrderItemDetail d) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      _surface(
        Column(
          children: [
            _row('Target Pengiriman', _date(d.item.deliveryDate)),
            _row('Dipesan', '${_formatQty(d.item.qty)} ${d.item.uom}'),
            _row(
              'Terkirim',
              '${_formatQty(d.item.deliveredQty)} ${d.item.uom}',
            ),
            _row('Sisa', '${_formatQty(d.item.remainingQty)} ${d.item.uom}'),
            if (d.item.overDeliveredQty > 0)
              _row(
                'Lebih Kirim',
                '${_formatQty(d.item.overDeliveredQty)} ${d.item.uom}',
              ),
            _row(
              'Status',
              d.item.isOverdue
                  ? 'Terlambat${d.item.overdueDays > 0 ? ' ${d.item.overdueDays} hari' : ''}'
                  : d.item.remainingQty > 0
                  ? (d.item.deliveredQty > 0
                        ? 'Sebagian Terkirim'
                        : 'Item Diproses')
                  : 'Selesai',
              last: true,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _history(
    SalesOrderItemDetail detail,
    List<SalesOrderItemHistory> rows, {
    required bool isInvoice,
  }) {
    final restricted = isInvoice
        ? detail.invoiceHistoryRestricted
        : detail.deliveryHistoryRestricted;
    final historyNote = isInvoice
        ? detail.invoiceHistoryNote
        : detail.deliveryHistoryNote;
    if (restricted) {
      return _empty(
        'Riwayat belum tersedia untuk akun ini.',
        historyNote == '-'
            ? 'Akun ini tidak memiliki izin baca dokumen terkait.'
            : historyNote,
      );
    }
    if (rows.isEmpty) {
      return _empty(
        isInvoice
            ? 'Belum ada riwayat invoice.'
            : 'Belum ada riwayat pengiriman.',
        'Riwayat akan tampil saat dokumen terkait tersedia.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: rows.length,
      itemBuilder: (_, i) => _historyCard(rows[i], isInvoice),
    );
  }

  Widget _historyCard(SalesOrderItemHistory h, bool invoice) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: _surface(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  h.document,
                  style: _style(12, FontWeight.w700, const Color(0xFF1E293B)),
                ),
              ),
              if (h.isReturn) _badge('Retur') else _badge(h.status),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            _date(h.postingDate),
            style: _style(10, FontWeight.w400, const Color(0xFF64748B)),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          Text(
            '${_formatQty(h.qty)} ${h.uom}',
            style: _style(11, FontWeight.w700, const Color(0xFF1E293B)),
          ),
          if (invoice && h.amount != 0) ...[
            const SizedBox(height: 4),
            Text(
              _money(h.amount, h.currency),
              style: _style(11, FontWeight.w600, AppColors.primaryColor),
            ),
          ],
          if (invoice && h.updateStock) ...[
            const SizedBox(height: 6),
            Text(
              'Invoice dengan update stok',
              style: _style(9, FontWeight.w500, const Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _empty(String title, String subtitle) => Center(
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
              Icons.history_rounded,
              size: 28,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _style(13, FontWeight.w700, const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
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
  Widget _surface(Widget child) => Container(
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
    padding: const EdgeInsets.all(14),
    child: child,
  );
  Widget _qty(String label, double value, String uom, {bool strong = false}) =>
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
              '${_formatQty(value)} $uom',
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
  Widget _row(String label, String value, {bool last = false}) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: _style(10, FontWeight.w400, const Color(0xFF64748B)),
          ),
        ),
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
  Widget _badge(String label) {
    final normalized = label.toLowerCase();
    final danger = normalized == 'retur' || normalized.contains('cancel');
    final success =
        normalized.contains('complete') ||
        normalized.contains('submitted') ||
        normalized.contains('paid');
    final color = danger
        ? const Color(0xFFDC2626)
        : success
        ? const Color(0xFF059669)
        : const Color(0xFFD97706);
    final background = danger
        ? const Color(0xFFFFF1F2)
        : success
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFFF7ED);
    return Container(
      constraints: const BoxConstraints(maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
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
}

TextStyle _style(double size, FontWeight weight, Color color) => TextStyle(
  fontFamily: AppFonts.primaryFont,
  fontSize: size,
  fontWeight: weight,
  color: color,
);
String _date(String value) {
  final parsed = DateTime.tryParse(value);
  return parsed == null
      ? value
      : DateFormat('d MMM yyyy', 'id_ID').format(parsed);
}

String _formatQty(double value) =>
    NumberFormat('#,##0.###', 'id_ID').format(value);
String _money(double value, String currency) => NumberFormat.currency(
  locale: 'id_ID',
  symbol: currency == 'IDR' ? 'Rp' : '$currency ',
  decimalDigits: currency == 'IDR' ? 0 : 2,
).format(value);
