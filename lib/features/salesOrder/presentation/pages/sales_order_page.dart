import 'dart:async';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_model.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/branch_credential_service.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/sales_order_detail_service.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/sales_order_service.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/presentation/cubit/sales_order_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'sales_order_detail_page.dart';

class SalesOrderPage extends StatefulWidget {
  const SalesOrderPage({super.key});
  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _service = SalesOrderService();
  Timer? _debounce;
  int _section = 0;
  String? _status;
  bool _onlyOverdue = false,
      _pendingLoading = false,
      _pendingLoadingMore = false,
      _pendingHasMore = false;
  int _pendingPage = 1;
  String? _pendingError;
  List<PendingSalesOrderItem> _pendingItems = const [];
  PendingItemsSummary _pendingSummary = const PendingItemsSummary();
  BranchCredential? _credential;
  String _branchCode = '', _bcid = '';
  String? _openingOrderName;

  static const _statuses = <String, String?>{
    'Semua': null,
    'Menunggu Pengiriman': 'To Deliver',
    'Menunggu Tagihan': 'To Bill',
    'Pengiriman & Tagihan': 'To Deliver and Bill',
    'Selesai': 'Completed',
  };

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
    final active = context.read<ActiveCompanyCubit>().state;
    if (active is ActiveCompanyReady) {
      _branchCode = active.activeCompany?.branchName ?? '';
      _bcid = active.activeCompany?.branchCustomerCode ?? '';
    }
    if (_branchCode.isEmpty || _bcid.isEmpty) {
      if (mounted) {
        setState(
          () => _pendingError =
              'Pilih perusahaan aktif agar pesanan dapat dimuat.',
        );
      }
      return;
    }
    _credential = await BranchCredentialService().fetchCredential(_branchCode);
    if (!mounted) return;
    context.read<SalesOrderCubit>().loadSalesOrder(
      branchCode: _branchCode,
      bcid: _bcid,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 260) {
      return;
    }
    if (_section == 0) {
      context.read<SalesOrderCubit>().loadMore();
    } else {
      _loadMorePending();
    }
  }

  void _onSearch(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (_section == 0) {
        _loadOrders();
      } else {
        _loadPending();
      }
    });
  }

  void _loadOrders() => context.read<SalesOrderCubit>().loadSalesOrder(
    branchCode: _branchCode,
    bcid: _bcid,
    status: _status,
    search: _searchController.text,
  );

  Future<void> _loadPending({bool refresh = false}) async {
    if (_pendingLoading || _credential == null) return;
    setState(() {
      _pendingLoading = true;
      _pendingError = null;
    });
    try {
      final data = await _service.fetchPendingItems(
        baseUrl: _credential!.url,
        token: _credential!.token,
        bcid: _bcid,
        onlyOverdue: _onlyOverdue,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _pendingItems = data.items;
        _pendingPage = data.page;
        _pendingHasMore = data.hasNext;
        _pendingSummary = data.summary;
      });
    } on SalesOrderApiException catch (e) {
      if (mounted) setState(() => _pendingError = e.message);
    } finally {
      if (mounted) setState(() => _pendingLoading = false);
    }
  }

  Future<void> _loadMorePending() async {
    if (_pendingLoadingMore || !_pendingHasMore || _credential == null) return;
    setState(() => _pendingLoadingMore = true);
    try {
      final data = await _service.fetchPendingItems(
        baseUrl: _credential!.url,
        token: _credential!.token,
        bcid: _bcid,
        page: _pendingPage + 1,
        onlyOverdue: _onlyOverdue,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _pendingItems = [..._pendingItems, ...data.items];
        _pendingPage = data.page;
        _pendingHasMore = data.hasNext;
        _pendingSummary = data.summary;
      });
    } on SalesOrderApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _pendingLoadingMore = false);
    }
  }

  Future<void> _switchSection(int value) async {
    if (_section == value) return;
    setState(() {
      _section = value;
      _searchController.clear();
    });
    if (value == 0) {
      _loadOrders();
    } else if (_pendingItems.isEmpty) {
      await _loadPending();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        _buildHeader(),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            children: [
              _Segmented(value: _section, onChanged: _switchSection),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: _section == 0 ? _statusChips() : _pendingChips(),
              ),
            ],
          ),
        ),
        Expanded(child: _section == 0 ? _ordersBody() : _pendingBody()),
      ],
    ),
  );

  Widget _buildHeader() => SizedBox(
    height: 178,
    child: Stack(
      children: [
        Positioned.fill(
          child: CustomHeaderAppBar(
            title: _section == 0 ? 'Sales Order' : 'Menunggu Pengiriman',
            subtitle: _section == 0
                ? 'Pantau pesanan Anda'
                : 'Produk yang masih menunggu pengiriman',
            brandStyle: true,
            height: 178,
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: CustomHeaderSearchField(
            controller: _searchController,
            hintText: _section == 0 ? 'Cari Sales Order...' : 'Cari produk...',
            onChanged: _onSearch,
            onClear: () {
              _searchController.clear();
              _onSearch('');
            },
          ),
        ),
      ],
    ),
  );

  Widget _statusChips() => ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: _statuses.length,
    separatorBuilder: (_, _) => const SizedBox(width: 7),
    itemBuilder: (_, i) {
      final e = _statuses.entries.elementAt(i);
      return _Chip(
        label: e.key,
        selected: _status == e.value,
        onTap: () {
          setState(() => _status = e.value);
          _loadOrders();
        },
      );
    },
  );
  Widget _pendingChips() => ListView(
    scrollDirection: Axis.horizontal,
    children: [
      _Chip(
        label: 'Semua',
        selected: !_onlyOverdue,
        onTap: () {
          setState(() => _onlyOverdue = false);
          _loadPending();
        },
      ),
      const SizedBox(width: 7),
      _Chip(
        label: 'Terlambat',
        selected: _onlyOverdue,
        onTap: () {
          setState(() => _onlyOverdue = true);
          _loadPending();
        },
      ),
    ],
  );

  Widget _ordersBody() => BlocConsumer<SalesOrderCubit, SalesOrderState>(
    listener: (_, state) {
      if (state is SalesOrderLoaded && state.loadMoreError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.loadMoreError!)));
      }
    },
    builder: (_, state) {
      if (state is SalesOrderLoading || state is SalesOrderInitial) {
        return _skeleton();
      }
      if (state is SalesOrderUnauthorized) {
        return _error(state.message, _loadOrders);
      }
      if (state is SalesOrderError) return _error(state.message, _loadOrders);
      final loaded = state as SalesOrderLoaded;
      if (loaded.items.isEmpty) {
        final searching = _searchController.text.trim().isNotEmpty;
        return _empty(
          searching ? 'Sales Order tidak ditemukan.' : 'Belum ada Sales Order.',
          searching
              ? 'Coba gunakan nomor atau nama customer yang berbeda.'
              : 'Pesanan Anda akan tampil di halaman ini.',
          searchEmpty: searching,
        );
      }
      return RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: context.read<SalesOrderCubit>().refresh,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: loaded.items.length + (loaded.isLoadingMore ? 1 : 0),
          itemBuilder: (_, i) => i == loaded.items.length
              ? _bottomLoader()
              : _orderCard(loaded.items[i]),
        ),
      );
    },
  );

  Widget _pendingBody() {
    if (_pendingLoading && _pendingItems.isEmpty) return _skeleton();
    if (_pendingError != null && _pendingItems.isEmpty) {
      return _error(_pendingError!, _loadPending);
    }
    if (_pendingItems.isEmpty) {
      final searching = _searchController.text.trim().isNotEmpty;
      return _empty(
        searching
            ? 'Produk tidak ditemukan.'
            : _onlyOverdue
            ? 'Tidak ada pengiriman yang terlambat.'
            : 'Semua pesanan sudah terkirim.',
        searching
            ? 'Coba gunakan kode atau nama produk yang berbeda.'
            : _onlyOverdue
            ? 'Produk terlambat akan tampil di sini.'
            : 'Saat ada produk yang masih menunggu pengiriman, produk akan muncul di sini.',
        searchEmpty: searching,
        positive: !searching && !_onlyOverdue,
      );
    }
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => _loadPending(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: _pendingItems.length + 1 + (_pendingLoadingMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == 0) return _summary();
          if (i > _pendingItems.length) return _bottomLoader();
          return _pendingCard(_pendingItems[i - 1]);
        },
      ),
    );
  }

  Widget _summary() => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      '${_pendingSummary.totalItemRows} Item menunggu pengiriman',
      style: _textStyle(11.5, FontWeight.w600, const Color(0xFF475569)),
    ),
  );

  Widget _orderCard(SalesOrder order) => _Card(
    onTap: () => _openOrder(order),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                order.name,
                style: _textStyle(13, FontWeight.w700, const Color(0xFF1E293B)),
              ),
            ),
            if (_openingOrderName == order.name)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primaryColor,
                ),
              )
            else
              _Badge(
                label: _statusLabel(order.status),
                danger: false,
                success: order.status == 'Completed',
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _date(order.transactionDate),
          style: _textStyle(10.5, FontWeight.w400, const Color(0xFF64748B)),
        ),
        const SizedBox(height: 10),
        Text(
          _money(order.grandTotal, order.currency),
          style: _textStyle(15, FontWeight.w700, const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),
        _Progress(label: 'Pengiriman', value: order.perDelivered),
        const SizedBox(height: 9),
        _Progress(label: 'Penagihan', value: order.perBilled),
      ],
    ),
  );

  Widget _pendingCard(PendingSalesOrderItem item) => _Card(
    onTap: () => _openPendingOrder(item),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.itemName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _textStyle(
                  12.5,
                  FontWeight.w700,
                  const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_openingOrderName == item.salesOrder)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primaryColor,
                ),
              )
            else
              _Badge(
                label: item.isOverdue
                    ? 'Terlambat${item.overdueDays > 0 ? ' ${item.overdueDays} hari' : ''}'
                    : item.deliveredQty > 0
                    ? 'Sebagian Terkirim'
                    : 'Menunggu Pengiriman',
                danger: item.isOverdue,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${item.salesOrder}  •  ${item.itemCode}',
          style: _textStyle(10.5, FontWeight.w500, const Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Text(
          'Target ${_date(item.deliveryDate)}',
          style: _textStyle(10.5, FontWeight.w400, const Color(0xFF64748B)),
        ),
        const Divider(height: 20, color: Color(0xFFF1F5F9)),
        Row(
          children: [
            _Qty(label: 'Dipesan', value: item.qty, uom: item.uom),
            _Qty(label: 'Terkirim', value: item.deliveredQty, uom: item.uom),
            _Qty(
              label: 'Sisa',
              value: item.remainingQty,
              uom: item.uom,
              strong: true,
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _openOrder(SalesOrder order) async {
    await _openOrderDetail(
      salesOrderName: order.name,
      customer: order.customer,
    );
  }

  Future<void> _openPendingOrder(PendingSalesOrderItem item) async {
    await _openOrderDetail(
      salesOrderName: item.salesOrder,
      customer: item.customer,
    );
  }

  Future<void> _openOrderDetail({
    required String salesOrderName,
    required String customer,
  }) async {
    if (_openingOrderName != null) return;
    setState(() => _openingOrderName = salesOrderName);
    final credential =
        _credential ??
        await BranchCredentialService().fetchCredential(_branchCode);
    if (credential == null || !mounted) {
      if (mounted) setState(() => _openingOrderName = null);
      return;
    }

    try {
      final detail = await SalesOrderDetailService().fetchDetail(
        baseUrl: credential.url,
        token: credential.token,
        salesOrderName: salesOrderName,
        expectedCustomer: customer,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SalesOrderDetailPage(
            salesOrder: detail.toDetailMap(),
            baseUrl: credential.url,
            token: credential.token,
          ),
        ),
      );
    } on SalesOrderApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _openingOrderName = null);
    }
  }

  Widget _skeleton() => Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => Container(
        height: 142,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 124,
                  height: 12,
                  decoration: _skeletonDecoration(5),
                ),
                const Spacer(),
                Container(
                  width: 82,
                  height: 20,
                  decoration: _skeletonDecoration(10),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Container(width: 86, height: 9, decoration: _skeletonDecoration(4)),
            const SizedBox(height: 13),
            Container(
              width: 148,
              height: 15,
              decoration: _skeletonDecoration(5),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 6,
              decoration: _skeletonDecoration(4),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 6,
              decoration: _skeletonDecoration(4),
            ),
          ],
        ),
      ),
    ),
  );

  BoxDecoration _skeletonDecoration(double radius) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
  );

  Widget _error(String message, VoidCallback retry) => Center(
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
              size: 28,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pesanan belum dapat dimuat',
            textAlign: TextAlign.center,
            style: _textStyle(13, FontWeight.w700, const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: _textStyle(
              11,
              FontWeight.w400,
              const Color(0xFF64748B),
            ).copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: retry,
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
  Widget _empty(
    String title,
    String subtitle, {
    bool searchEmpty = false,
    bool positive = false,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: positive
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searchEmpty
                  ? Icons.search_off_rounded
                  : positive
                  ? Icons.check_circle_outline_rounded
                  : Icons.inventory_2_outlined,
              size: 28,
              color: positive
                  ? const Color(0xFF059669)
                  : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _textStyle(13, FontWeight.w700, const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: _textStyle(
              11,
              FontWeight.w400,
              searchEmpty ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ).copyWith(height: 1.4),
          ),
        ],
      ),
    ),
  );
  Widget _bottomLoader() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: AppColors.primaryColor,
        ),
      ),
    ),
  );
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        for (final e in const [(0, 'Sales Order'), (1, 'Item Diproses')])
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => onChanged(e.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == e.$1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: value == e.$1
                      ? const [
                          BoxShadow(color: Color(0x100F172A), blurRadius: 4),
                        ]
                      : null,
                ),
                child: Text(
                  e.$2,
                  style: _textStyle(
                    10.5,
                    FontWeight.w600,
                    value == e.$1
                        ? AppColors.primaryColor
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
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
        style: _textStyle(
          10.5,
          FontWeight.w700,
          selected ? Colors.white : const Color(0xFF334155),
        ),
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    this.danger = false,
    this.success = false,
  });
  final String label;
  final bool danger, success;
  @override
  Widget build(BuildContext context) {
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
        style: _textStyle(8.5, FontWeight.w700, color),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.label, required this.value});
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: _textStyle(10, FontWeight.w500, const Color(0xFF475569)),
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: _textStyle(10, FontWeight.w700, const Color(0xFF1E293B)),
          ),
        ],
      ),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value / 100,
          minHeight: 6,
          backgroundColor: const Color(0xFFF1F5F9),
          color: AppColors.primaryColor,
        ),
      ),
    ],
  );
}

class _Qty extends StatelessWidget {
  const _Qty({
    required this.label,
    required this.value,
    required this.uom,
    this.strong = false,
  });
  final String label, uom;
  final double value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _textStyle(9.5, FontWeight.w400, const Color(0xFF64748B)),
        ),
        const SizedBox(height: 3),
        Text(
          '${_qty(value)} $uom',
          overflow: TextOverflow.ellipsis,
          style: _textStyle(
            11,
            strong ? FontWeight.w700 : FontWeight.w600,
            strong ? AppColors.primaryColor : const Color(0xFF1E293B),
          ),
        ),
      ],
    ),
  );
}

TextStyle _textStyle(double size, FontWeight weight, Color color) => TextStyle(
  fontFamily: AppFonts.primaryFont,
  fontSize: size,
  fontWeight: weight,
  color: color,
);
String _statusLabel(String status) => switch (status) {
  'To Deliver' => 'Menunggu Pengiriman',
  'To Bill' => 'Menunggu Tagihan',
  'To Deliver and Bill' => 'Pengiriman & Tagihan',
  'Completed' => 'Selesai',
  _ => status,
};
String _date(String value) {
  final parsed = DateTime.tryParse(value);
  return parsed == null
      ? value
      : DateFormat('d MMM yyyy', 'id_ID').format(parsed);
}

String _money(double value, String currency) => NumberFormat.currency(
  locale: 'id_ID',
  symbol: currency == 'IDR' ? 'Rp' : '$currency ',
  decimalDigits: currency == 'IDR' ? 0 : 2,
).format(value);
String _qty(double value) => NumberFormat('#,##0.###', 'id_ID').format(value);
