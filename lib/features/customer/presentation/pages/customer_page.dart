import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/customer/presentation/widgets/customer_company_card.dart';
import 'package:ekaplus_ekatunggal/features/customer/presentation/widgets/customer_menu_section.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/pages/invoice_page.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/presentation/cubit/sales_order_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/presentation/pages/sales_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<ActiveCompanyCubit, ActiveCompanyState>(
        builder: (context, state) {
          final readyState = state is ActiveCompanyReady ? state : null;
          final activeCompany = readyState?.activeCompany;

          return RefreshIndicator(
            color: AppColors.primaryColor,
            edgeOffset: 92,
            onRefresh: () =>
                context.read<ActiveCompanyCubit>().refreshCompanies(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _CustomerHeader(
                    onHelp: () => _showComingSoon(context, 'Panduan customer'),
                    onNotification: () =>
                        _showComingSoon(context, 'Notifikasi'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.list(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -38),
                        child: activeCompany != null
                            ? CustomerCompanyCard(
                                company: activeCompany,
                                onChangeCompany: () => context.pushNamed(
                                  'memberList',
                                  extra: {'initialTabIndex': 1},
                                ),
                              )
                            : _NoCompanyCard(
                                isLoading: state is ActiveCompanyLoading,
                                onAddCompany: () =>
                                    context.pushNamed('companySelection'),
                              ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -22),
                        child: Column(
                          children: [
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
                            CustomerMenuSection(
                              title: 'Transaksi',
                              items: [
                                CustomerMenuItem(
                                  icon: Icons.assignment_outlined,
                                  iconColor: const Color(0xFF2563EB),
                                  iconBackground: const Color(0xFFEFF6FF),
                                  title: 'Sales Order',
                                  subtitle: 'Riwayat & status pesanan berjalan',
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
                                  subtitle:
                                      'Tagihan, faktur & status pembayaran',
                                  onTap: activeCompany == null
                                      ? () => _showComingSoon(
                                          context,
                                          'Pilih perusahaan terlebih dahulu',
                                        )
                                      : () => _openInvoice(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({required this.onHelp, required this.onNotification});

  final VoidCallback onHelp;
  final VoidCallback onNotification;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 154,
      padding: const EdgeInsets.fromLTRB(18, 0, 12, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD52A2F), AppColors.primaryColor],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EKATUNGGAL B2B',
                    style: TextStyle(
                      color: Color(0xFFFECACA),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .35,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Customer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.3,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderButton(
              tooltip: 'Bantuan',
              icon: Icons.help_outline_rounded,
              onPressed: onHelp,
            ),
            const SizedBox(width: 7),
            _HeaderButton(
              tooltip: 'Notifikasi',
              icon: Icons.notifications_none_rounded,
              showBadge: true,
              onPressed: onNotification,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: 38, height: 38),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(.13),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 19),
          if (showBadge)
            const Positioned(
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeWidth: 2.5,
              ),
            )
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
                FilledButton.icon(
                  onPressed: onAddCompany,
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: const Text('Hubungkan Perusahaan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
