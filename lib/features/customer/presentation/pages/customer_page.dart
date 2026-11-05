import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/customer/presentation/widgets/customer_company_card.dart';
import 'package:ekaplus_ekatunggal/features/customer/presentation/widgets/customer_menu_section.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/pages/invoice_page.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/customer_point_summary_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/customer_loyalty_point_card.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/presentation/cubit/sales_order_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/presentation/pages/sales_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  // Fitur pengajuan perusahaan disiapkan untuk update berikutnya.
  // Ubah menjadi true saat fitur akan ditampilkan kembali.
  final bool _showCompanyRegistrationFeatures = false;

  int _creditReloadKey = 0;
  late final CustomerPointSummaryCubit _pointSummaryCubit;
  String? _loyaltyBcid;
  int? _loyaltyGpid;
  ActiveCompanyReady? _lastReadyState;

  @override
  void initState() {
    super.initState();
    _pointSummaryCubit = CustomerPointSummaryCubit(LoyaltyService());
  }

  @override
  void dispose() {
    _pointSummaryCubit.close();
    super.dispose();
  }

  String? _customerBcid(ActiveMemberCompany? company) {
    if (company == null) return null;
    final code = company.branchCustomerCode?.trim() ?? '';
    if (code.isNotEmpty) return code;
    final id = company.branchCustomerId;
    return id == null || id <= 0 ? null : id.toString();
  }

  void _syncPointSummary(ActiveMemberCompany? company) {
    final bcid = _customerBcid(company);
    final gpid = company?.gpidId;
    if (bcid == _loyaltyBcid && gpid == _loyaltyGpid) return;
    _loyaltyBcid = bcid;
    _loyaltyGpid = gpid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pointSummaryCubit.load(gpid);
    });
  }

  void _showComingSoon(BuildContext context, String feature) {
    AppSnackbar.show(
      context,
      message: '$feature akan segera tersedia',
      type: AppSnackbarType.info,
    );
  }

  void _openSalesOrder(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => SalesOrderCubit(),
          child: const SalesOrderPage(),
        ),
      ),
    );
  }

  void _openInvoice(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => InvoiceCubit(),
          child: const InvoicePage(),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final companyCubit = context.read<ActiveCompanyCubit>();
    await companyCubit.refreshCompanies();
    if (!mounted) return;
    final state = companyCubit.state;
    if (state is ActiveCompanyReady) _lastReadyState = state;
    final company = state is ActiveCompanyReady
        ? state.activeCompany
        : _lastReadyState?.activeCompany;
    await _pointSummaryCubit.load(company?.gpidId);
    if (!mounted) return;
    setState(() => _creditReloadKey++);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveCompanyCubit, ActiveCompanyState>(
      listener: (context, state) {
        if (state is ActiveCompanyError) {
          AppSnackbar.show(
            context,
            message: 'Data perusahaan belum dapat diperbarui',
            type: AppSnackbarType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is ActiveCompanyReady) _lastReadyState = state;
        final readyState = state is ActiveCompanyReady
            ? state
            : _lastReadyState;

        final activeCompany = readyState?.activeCompany;
        _syncPointSummary(activeCompany);

        return BlocProvider<CustomerPointSummaryCubit>.value(
          value: _pointSummaryCubit,
          child: CustomHeaderScaffold(
            title: 'Customer',
            showBackButton: false,

            actions: [
              CustomHeaderActionButton(
                tooltip: 'Bantuan',
                onPressed: () => _showComingSoon(context, 'Panduan customer'),
                icon: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),

              CustomHeaderActionButton(
                tooltip: 'Notifikasi',
                onPressed: () => _showComingSoon(context, 'Notifikasi'),
                icon: const Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    Positioned(
                      right: -1,
                      top: -1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 7, height: 7),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: () => _refresh(context),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      activeCompany != null
                          ? CustomerCompanyCard(
                              company: activeCompany,
                              reloadKey: _creditReloadKey,
                              onChangeCompany: () => context.pushNamed(
                                'memberList',
                                extra: {'initialTabIndex': 1},
                              ),
                            )
                          : state is ActiveCompanyError
                          ? _CompanyErrorCard(
                              onRetry: () => context
                                  .read<ActiveCompanyCubit>()
                                  .loadCompaniesAndResolveActive(force: true),
                            )
                          : _NoCompanyCard(
                              isLoading:
                                  state is ActiveCompanyInitial ||
                                  state is ActiveCompanyLoading,
                              onAddCompany: () =>
                                  context.pushNamed('companySelection'),
                            ),

                      const SizedBox(height: 14),

                      CustomerMenuSection(
                        title: 'Entitas & Cabang Perusahaan',
                        items: [
                          CustomerMenuItem(
                            icon: Icons.apartment_rounded,
                            iconColor: const Color(0xFF64748B),
                            iconBackground: const Color(0xFFF1F5F9),
                            title: 'Daftar Perusahaan & Cabang',
                            subtitle: readyState == null
                                ? 'Kelola entitas bisnis terhubung'
                                : '${readyState.companies.length} entitas bisnis terhubung',
                            badge: readyState == null
                                ? null
                                : '${readyState.companies.length} Entitas',
                            onTap: () => context.pushNamed(
                              'memberList',
                              extra: {'initialTabIndex': 1},
                            ),
                          ),

                          if (_showCompanyRegistrationFeatures)
                            CustomerMenuItem(
                              icon: Icons.add_rounded,
                              iconColor: AppColors.primaryColor,
                              iconBackground: const Color(0xFFFEF2F2),
                              title: 'Tambah / Gabung Perusahaan Baru',
                              subtitle:
                                  'Registrasi cabang atau gabung kode entitas',
                              onTap: () =>
                                  context.pushNamed('companySelection'),
                            ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      if (activeCompany != null &&
                          _loyaltyBcid != null &&
                          _loyaltyGpid != null) ...[
                        CustomerLoyaltyPointCard(
                          onCatalogTap: () => context.pushNamed(
                            'loyalty-rewards',
                            extra: {'bcid': _loyaltyBcid},
                          ),
                          onDetailTap: () => context.pushNamed(
                            'loyalty-calculation-detail',
                            extra: {
                              'gpid': _loyaltyGpid,
                              'bcid': _loyaltyBcid,
                              'groupParentCode': activeCompany.gpCode,
                              'groupParentName': activeCompany.gpName,
                            },
                          ),
                          onRetry: () => _pointSummaryCubit.load(_loyaltyGpid),
                        ),
                        const SizedBox(height: 14),
                      ],

                      CustomerMenuSection(
                        title: 'Transaksi',
                        items: [
                          CustomerMenuItem(
                            icon: Icons.assignment_outlined,
                            iconColor: const Color(0xFF2563EB),
                            iconBackground: const Color(0xFFEFF6FF),
                            title: 'Sales Order',
                            subtitle: 'Riwayat & status pesanan berjalan',
                            enabled: activeCompany != null,
                            onTap: activeCompany == null
                                ? () => _showComingSoon(
                                    context,
                                    'Pilih perusahaan terlebih dahulu',
                                  )
                                : () => _openSalesOrder(context),
                          ),

                          CustomerMenuItem(
                            icon: Icons.receipt_long_outlined,
                            iconColor: const Color(0xFF059669),
                            iconBackground: const Color(0xFFECFDF5),
                            title: 'Sales Invoice',
                            subtitle: 'Tagihan, faktur & status pembayaran',
                            enabled: activeCompany != null,
                            onTap: activeCompany == null
                                ? () => _showComingSoon(
                                    context,
                                    'Pilih perusahaan terlebih dahulu',
                                  )
                                : () => _openInvoice(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NoCompanyCard extends StatelessWidget {
  const _NoCompanyCard({required this.isLoading, required this.onAddCompany});

  final bool isLoading;
  final VoidCallback onAddCompany;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFF1F5F9)),

        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: isLoading
          ? const _CompanyCardSkeleton()
          : Column(
              children: [
                const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFF94A3B8),
                  size: 32,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Belum ada perusahaan aktif',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Tambahkan atau hubungkan perusahaan untuk mulai bertransaksi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: onAddCompany,
                    icon: const Icon(Icons.add_rounded, size: 17),
                    label: const Text('Hubungkan Perusahaan'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CompanyCardSkeleton extends StatelessWidget {
  const _CompanyCardSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 110,
                height: 9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CompanyErrorCard extends StatelessWidget {
  const _CompanyErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF1F5F9)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D0F172A),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF1F2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Perusahaan Belum Dapat Dimuat',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Periksa koneksi lalu coba kembali.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 11, height: 1.4),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
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
  );
}
