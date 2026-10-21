import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
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

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  int _creditReloadKey = 0;

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
    await context.read<ActiveCompanyCubit>().refreshCompanies();
    if (!mounted) return;
    setState(() => _creditReloadKey++);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveCompanyCubit, ActiveCompanyState>(
      builder: (context, state) {
        final readyState = state is ActiveCompanyReady ? state : null;

        final activeCompany = readyState?.activeCompany;

        return CustomHeaderScaffold(
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

          body: RefreshIndicator(
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
                    : _NoCompanyCard(
                        isLoading: state is ActiveCompanyLoading,
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

                    CustomerMenuItem(
                      icon: Icons.add_rounded,
                      iconColor: AppColors.primaryColor,
                      iconBackground: const Color(0xFFFEF2F2),
                      title: 'Tambah / Gabung Perusahaan Baru',
                      subtitle: 'Registrasi cabang atau gabung kode entitas',
                      onTap: () => context.pushNamed('companySelection'),
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
                      subtitle: 'Tagihan, faktur & status pembayaran',
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
