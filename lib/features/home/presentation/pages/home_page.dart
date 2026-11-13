import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/feature_flags.dart';
// import 'package:ekaplus_ekatunggal/core/shared_widgets/profile_header.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/whatsapp_helper.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_cubit.dart';
import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_state.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_state.dart';
import 'package:ekaplus_ekatunggal/features/home/presentation/widgets/home_slider_widget.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:ekaplus_ekatunggal/features/invoice/presentation/pages/invoice_page.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/customer_point_summary_cubit.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/widgets/company_picker_sheet.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/presentation/cubit/sales_order_cubit.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/presentation/pages/sales_order_page.dart';
import 'package:ekaplus_ekatunggal/features/promotion/presentation/cubit/promotion_cubit.dart';
import 'package:ekaplus_ekatunggal/features/promotion/presentation/widgets/promotion_card.dart';
import 'package:ekaplus_ekatunggal/features/article/presentation/cubit/article_cubit.dart';
import 'package:ekaplus_ekatunggal/features/article/presentation/widgets/article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CustomerPointSummaryCubit _points;
  int? _loadedGpid;
  String? _loadedBcid;
  int? _loadedPromotionBranchId;
  bool _promotionLoaded = false;

  @override
  void initState() {
    super.initState();
    _points = CustomerPointSummaryCubit(LoyaltyService());
    context.read<BannerCubit>().fetchBanners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ArticleCubit>().load();
    });
  }

  @override
  void dispose() {
    _points.close();
    super.dispose();
  }

  String? _bcid(ActiveMemberCompany? company) {
    final code = company?.branchCustomerCode?.trim() ?? '';
    if (code.isNotEmpty) return code;
    final id = company?.branchCustomerId;
    return id == null || id <= 0 ? null : '$id';
  }

  void _syncPoints(ActiveMemberCompany? company) {
    final gpid = company?.gpidId;
    final bcid = _bcid(company);
    if (gpid == _loadedGpid && bcid == _loadedBcid) return;
    _loadedGpid = gpid;
    _loadedBcid = bcid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _points.load(gpid, bcid: bcid);
    });
  }

  void _syncPromotions(int? branchId) {
    if (_promotionLoaded && branchId == _loadedPromotionBranchId) return;
    _promotionLoaded = true;
    _loadedPromotionBranchId = branchId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PromotionCubit>().load(branchId: branchId);
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<BannerCubit>().fetchBanners(),
      context.read<SelectedBranchCubit>().load(force: true),
    ]);
    if (!mounted) return;
    final selectedBranch = context
        .read<SelectedBranchCubit>()
        .state
        .selectedBranch;
    await Future.wait([
      context.read<PromotionCubit>().load(branchId: selectedBranch?.id),
      context.read<ArticleCubit>().load(),
    ]);
    if (!mounted) return;
    final state = context.read<ActiveCompanyCubit>().state;
    final company = state is ActiveCompanyReady ? state.activeCompany : null;
    await _points.load(company?.gpidId, bcid: _bcid(company));
  }

  void _openOrders() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => SalesOrderCubit(),
          child: const SalesOrderPage(),
        ),
      ),
    );
  }

  void _openInvoices() {
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
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, auth) {
        final loggedIn = auth is AuthSessionAuthenticated;
        return BlocBuilder<ActiveCompanyCubit, ActiveCompanyState>(
          builder: (context, companyState) {
            final company = companyState is ActiveCompanyReady
                ? companyState.activeCompany
                : null;
            _syncPoints(loggedIn ? company : null);
            final branchState = context.watch<SelectedBranchCubit>().state;
            final branch = branchState.selectedBranch;
            _syncPromotions(branch?.id);
            return BlocProvider.value(
              value: _points,
              child: Scaffold(
                backgroundColor: const Color(0xFFF6F7F9),
                body: SafeArea(
                  child: Column(
                    children: [
                      // const Padding(
                      //   padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                      //   child: ProfileHeader(),
                      // ),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primaryColor,
                          displacement: 40,
                          edgeOffset: 0,
                          triggerMode: RefreshIndicatorTriggerMode.onEdge,
                          onRefresh: _refresh,
                          child: ListView(
                            key: const PageStorageKey('home-scroll'),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: ClampingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),

                            children: [
                              _HomeHero(
                                company: company,
                                retryBanner: () =>
                                    context.read<BannerCubit>().fetchBanners(),
                                selectCompany: () => loggedIn
                                    ? showCompanyPickerDialog(context)
                                    : context.pushNamed('login'),
                              ),
                              if (FeatureFlags.showHomeLoyalty) ...[
                                const SizedBox(height: 14),
                                _LoyaltyCard(
                                  loggedIn: loggedIn,
                                  companyState: companyState,
                                  company: company,
                                  bcid: _bcid(company),
                                  login: () => context.pushNamed('login'),
                                  addCompany: () =>
                                      context.pushNamed('companySelection'),
                                  retry: () => _points.load(
                                    company?.gpidId,
                                    bcid: _bcid(company),
                                  ),
                                  details: company == null
                                      ? null
                                      : () => context.pushNamed(
                                          'loyalty-calculation-detail',
                                          extra: {
                                            'gpid': company.gpidId,
                                            'bcid': _bcid(company),
                                            'groupParentCode': company.gpCode,
                                            'groupParentName': company.gpName,
                                          },
                                        ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              _QuickServices(
                                orders: () => loggedIn
                                    ? _openOrders()
                                    : context.pushNamed('login'),
                                invoices: () => loggedIn
                                    ? _openInvoices()
                                    : context.pushNamed('login'),
                                about: () => context.pushNamed('about'),
                                customerService: () =>
                                    WhatsAppHelper.openGeneral(context),
                              ),
                              if (FeatureFlags.showBranchDirectory) ...[
                                const SizedBox(height: 16),
                                _BranchListSection(
                                  state: branchState,
                                  seeAll: () => context.goNamed('branches'),
                                ),
                              ],
                              if (FeatureFlags.showPromotions) ...[
                                const SizedBox(height: 16),
                                _PromotionSection(
                                  seeAll: () => context.pushNamed('promotions'),
                                ),
                              ],
                              if (FeatureFlags.showArticles) ...[
                                const SizedBox(height: 16),
                                _ArticleSection(
                                  seeAll: () => context.pushNamed('articles'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.retry});
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => BlocBuilder<BannerCubit, BannerState>(
    builder: (context, state) {
      if (state is BannerLoaded) {
        return HomeSliderWidget(
          banners: state.banners,
          bottomOverlap: _bannerCardOverlap,
        );
      }
      if (state is BannerError) {
        return _StateView(
          icon: Icons.image_not_supported_outlined,
          text: 'Banner belum dapat dimuat',
          retry: retry,
        );
      }
      return const _ShimmerBox();
    },
  );
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.company,
    required this.retryBanner,
    required this.selectCompany,
  });

  final ActiveMemberCompany? company;
  final VoidCallback retryBanner;
  final VoidCallback selectCompany;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Hero melebar 12 px ke setiap sisi untuk menutup padding ListView.
      final bannerWidth = constraints.maxWidth + _bannerHorizontalBleed;
      final bannerHeight = bannerWidth / _bannerAspectRatio;
      final companyCardTop = bannerHeight - _bannerCardOverlap;
      final heroHeight = companyCardTop + _companyCardHeight;

      return SizedBox(
        height: heroHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: -_bannerSideBleed,
              right: -_bannerSideBleed,
              height: bannerHeight,
              child: _Banner(retry: retryBanner),
            ),
            Positioned(
              top: companyCardTop,
              left: 0,
              right: 0,
              child: _CompanyPickerCard(company: company, onTap: selectCompany),
            ),
          ],
        ),
      );
    },
  );
}

class _CompanyPickerCard extends StatelessWidget {
  const _CompanyPickerCard({required this.company, required this.onTap});

  final ActiveMemberCompany? company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gcName = (company?.gcName ?? '').trim();
    final registeredName = (company?.customerCompanyName ?? '').trim();
    final companyName = gcName.isNotEmpty
        ? gcName
        : registeredName.isNotEmpty
        ? registeredName
        : company?.displayName ?? 'Pilih Customer';
    final city = (company?.branchCity ?? '').trim();
    final subtitle = company == null
        ? 'Ketuk untuk memilih customer'
        : city.isEmpty
        ? 'Customer aktif'
        : 'Customer aktif • $city';

    return _Card(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          const Icon(
            Icons.apartment_outlined,
            color: AppColors.primaryColor,
            size: 30,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172554),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'Ganti',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({
    required this.loggedIn,
    required this.companyState,
    required this.company,
    required this.bcid,
    required this.login,
    required this.addCompany,
    required this.retry,
    required this.details,
  });
  final bool loggedIn;
  final ActiveCompanyState companyState;
  final ActiveMemberCompany? company;
  final String? bcid;
  final VoidCallback login;
  final VoidCallback addCompany;
  final VoidCallback retry;
  final VoidCallback? details;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!loggedIn) {
      child = _LoyaltyPrompt(
        title: 'Kenali manfaat EkaPoint',
        message: 'Masuk untuk melihat poin tersedia dari perusahaan Anda.',
        label: 'Masuk',
        action: login,
      );
    } else if (companyState is ActiveCompanyLoading ||
        companyState is ActiveCompanyInitial) {
      child = const _LoyaltyShimmer();
    } else if (company == null || company!.gpidId == null || bcid == null) {
      child = _LoyaltyPrompt(
        title: 'Perusahaan belum terhubung',
        message: 'Tambahkan perusahaan untuk melihat saldo EkaPoint.',
        label: 'Tambahkan Perusahaan',
        action: addCompany,
      );
    } else {
      child = BlocBuilder<CustomerPointSummaryCubit, CustomerPointSummaryState>(
        builder: (context, state) {
          if (state.status == CustomerPointSummaryStatus.loading ||
              state.status == CustomerPointSummaryStatus.initial) {
            return const _LoyaltyShimmer();
          }
          if (state.status == CustomerPointSummaryStatus.failure) {
            return _LoyaltyPrompt(
              title: 'Poin belum dapat dimuat',
              message: 'Periksa koneksi lalu coba kembali.',
              label: 'Coba Lagi',
              action: retry,
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/icon_medali.png',
                width: 61,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EKAPOINT', style: _loyaltyTitle),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        NumberFormat.decimalPattern(
                          'id_ID',
                        ).format(state.availablePoint),
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 34,
                          height: 1.05,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Poin Tersedia',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: details,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rincian Poin',
                        style: TextStyle(
                          color: Color(0xFFD43D45),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFD43D45),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          transform: GradientRotation(82 * math.pi / 180),
          colors: [Color(0xFFFDECC5), Color(0xFFFFFDF9)],
          stops: [0.43, 0.76],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _QuickServices extends StatelessWidget {
  const _QuickServices({
    required this.orders,
    required this.invoices,
    required this.about,
    required this.customerService,
  });
  final VoidCallback orders;
  final VoidCallback invoices;
  final VoidCallback about;
  final VoidCallback customerService;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Header(title: 'Layanan Anda'),
      const SizedBox(height: 8),
      _Card(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: _QuickItem(
                icon: Icons.assignment_outlined,
                label: 'Pesanan',
                action: orders,
              ),
            ),
            Expanded(
              child: _QuickItem(
                icon: Icons.receipt_long_outlined,
                label: 'Tagihan',
                action: invoices,
              ),
            ),
            Expanded(
              child: _QuickItem(
                icon: Icons.support_agent_rounded,
                label: 'Customer\nService',
                action: customerService,
              ),
            ),
            Expanded(
              child: _QuickItem(
                icon: Icons.info_outline_rounded,
                label: 'Program',
                action: about,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _BranchListSection extends StatelessWidget {
  const _BranchListSection({required this.state, required this.seeAll});
  final SelectedBranchState state;
  final VoidCallback seeAll;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Header(
        title: 'Daftar Cabang',
        subtitle: 'Temukan cabang Ekatunggal terdekat',
        action: seeAll,
      ),
      const SizedBox(height: 8),
      if ((state.status == SelectedBranchStatus.initial ||
              state.status == SelectedBranchStatus.loading) &&
          state.branches.isEmpty)
        const SizedBox(height: 128, child: _ShimmerBox())
      else if (state.status == SelectedBranchStatus.error &&
          state.branches.isEmpty)
        const _Card(
          child: _StateView(
            icon: Icons.cloud_off_rounded,
            text: 'Daftar cabang belum dapat dimuat',
          ),
        )
      else if (state.branches.isEmpty)
        const _Card(
          child: _StateView(
            icon: Icons.store_mall_directory_outlined,
            text: 'Belum ada cabang tersedia',
          ),
        )
      else
        SizedBox(
          height: 190,
          child: ListView.separated(
            key: const PageStorageKey('home-branch-list'),
            scrollDirection: Axis.horizontal,
            itemCount:
                (state.branches.length > 5 ? 5 : state.branches.length) + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final visibleBranchCount = state.branches.length > 5
                  ? 5
                  : state.branches.length;
              if (index == visibleBranchCount) {
                return _SeeAllBranchesCard(
                  backgroundBranch: state.branches.last,
                  onTap: seeAll,
                );
              }
              final branch = state.branches[index];
              return _BranchPreviewCard(
                branch: branch,
                onTap: () => context.pushNamed(
                  'branch-detail',
                  pathParameters: {'branchId': '${branch.id}'},
                  extra: branch,
                ),
              );
            },
          ),
        ),
    ],
  );
}

class _SeeAllBranchesCard extends StatelessWidget {
  const _SeeAllBranchesCard({
    required this.backgroundBranch,
    required this.onTap,
  });

  final Branch backgroundBranch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Lihat semua cabang',
    excludeSemantics: true,
    child: Material(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 148,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: _branchPhotoUrl(backgroundBranch),
                fit: BoxFit.cover,
                placeholder: (_, _) => const _BranchPhotoFallback(),
                errorWidget: (_, _, _) => const _BranchPhotoFallback(),
              ),
              const ColoredBox(color: Color(0x990F172A)),
              const Center(
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BranchPreviewCard extends StatelessWidget {
  const _BranchPreviewCard({required this.branch, required this.onTap});

  final Branch branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Buka detail ${branch.branchName}, ${branch.city ?? ''}',
    excludeSemantics: true,
    child: Material(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 148,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: _branchPhotoUrl(branch),
                fit: BoxFit.cover,
                placeholder: (_, _) => const _BranchPhotoFallback(),
                errorWidget: (_, _, _) => const _BranchPhotoFallback(),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.42, 1],
                    colors: [Colors.transparent, Color(0xD9000000)],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      branch.branchName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      (branch.city ?? '').trim().isEmpty
                          ? 'Ekatunggal'
                          : branch.city!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 9,
                      ),
                    ),
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

class _BranchPhotoFallback extends StatelessWidget {
  const _BranchPhotoFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFFFF1F2),
    child: Center(
      child: Icon(
        Icons.store_mall_directory_rounded,
        size: 58,
        color: AppColors.primaryColor,
      ),
    ),
  );
}

String _branchPhotoUrl(Branch branch) {
  final seedSource = branch.city?.trim().isNotEmpty == true
      ? branch.city!
      : branch.branchName;
  final seed = seedSource.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '-',
  );
  return Uri.https(
    'via.placeholder.com',
    '/photo/office-building/800x450.webp',
    {'seed': seed.isEmpty ? '${branch.id}' : '$seed-${branch.id}'},
  ).toString();
}

class _PromotionSection extends StatelessWidget {
  const _PromotionSection({required this.seeAll});

  final VoidCallback seeAll;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final carouselHeight =
        205.0 + ((textScale - 1).clamp(0.0, 1.0) * 64).toDouble();
    return BlocBuilder<PromotionCubit, PromotionState>(
      builder: (context, state) => Column(
        children: [
          _Header(
            title: 'Promo Spesial',
            subtitle: 'Informasi program untuk pelanggan',
            action: seeAll,
          ),
          const SizedBox(height: 8),
          if ((state.status == PromotionStatus.initial ||
                  state.status == PromotionStatus.loading) &&
              state.items.isEmpty)
            SizedBox(height: carouselHeight, child: const _ShimmerBox())
          else if (state.status == PromotionStatus.error)
            _Card(
              child: _StateView(
                icon: Icons.cloud_off_rounded,
                text: 'Promo belum dapat dimuat',
                retry: () => context.read<PromotionCubit>().load(
                  branchId: state.branchId,
                ),
              ),
            )
          else if (state.items.isEmpty)
            const _Card(
              child: _StateView(
                icon: Icons.local_offer_outlined,
                text: 'Belum ada promo aktif',
              ),
            )
          else
            SizedBox(
              height: carouselHeight,
              child: ListView.separated(
                key: const PageStorageKey('home-promotion-carousel'),
                scrollDirection: Axis.horizontal,
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final promotion = state.items[index];
                  return PromotionCard(
                    compact: true,
                    promotion: promotion,
                    onTap: () => context.pushNamed(
                      'promotion-detail',
                      pathParameters: {'id': promotion.id},
                      extra: promotion,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ArticleSection extends StatelessWidget {
  const _ArticleSection({required this.seeAll});

  final VoidCallback seeAll;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final carouselHeight =
        184.0 + ((textScale - 1).clamp(0.0, 1.0) * 64).toDouble();
    return BlocBuilder<ArticleCubit, ArticleState>(
      builder: (context, state) => Column(
        children: [
          _Header(
            title: 'Artikel & Berita Terbaru',
            subtitle: 'Kabar terbaru dari Ekatunggal',
            action: seeAll,
          ),
          const SizedBox(height: 8),
          if ((state.status == ArticleStatus.initial ||
                  state.status == ArticleStatus.loading) &&
              state.items.isEmpty)
            SizedBox(height: carouselHeight, child: const _ShimmerBox())
          else if (state.status == ArticleStatus.error)
            _Card(
              child: _StateView(
                icon: Icons.cloud_off_rounded,
                text: 'Artikel belum dapat dimuat',
                retry: () => context.read<ArticleCubit>().load(),
              ),
            )
          else if (state.items.isEmpty)
            const _Card(
              child: _StateView(
                icon: Icons.article_outlined,
                text: 'Belum ada artikel terbaru',
              ),
            )
          else
            SizedBox(
              height: carouselHeight,
              child: ListView.separated(
                key: const PageStorageKey('home-article-carousel'),
                scrollDirection: Axis.horizontal,
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final article = state.items[index];
                  return ArticleCard(
                    compact: true,
                    article: article,
                    onTap: () => context.pushNamed(
                      'article-detail',
                      pathParameters: {'id': article.id},
                      extra: article,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle, this.action});
  final String title;
  final String? subtitle;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _sectionTitle),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _subtitle,
              ),
          ],
        ),
      ),
      if (action != null)
        TextButton(
          onPressed: action,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Lihat Semua'),
        ),
    ],
  );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: _cardDecoration,
      child: child,
    );
    return onTap == null
        ? card
        : InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: card,
          );
  }
}

class _QuickItem extends StatelessWidget {
  const _QuickItem({required this.icon, required this.label, this.action});
  final IconData icon;
  final String label;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Semantics(
    button: action != null,
    enabled: action != null,
    label: label,
    excludeSemantics: true,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconBox(icon: icon, disabled: action == null),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 28),
                  child: Align(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 10,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _LoyaltyPrompt extends StatelessWidget {
  const _LoyaltyPrompt({
    required this.title,
    required this.message,
    required this.label,
    required this.action,
  });
  final String title;
  final String message;
  final String label;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Image.asset(
        'assets/icons/icon_medali.png',
        width: 36,
        fit: BoxFit.contain,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _loyaltyTitle),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 9.5),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: FilledButton(
                onPressed: action,
                style: FilledButton.styleFrom(
                  backgroundColor: _loyaltyRed,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _StateView extends StatelessWidget {
  const _StateView({required this.icon, required this.text, this.retry});
  final IconData icon;
  final String text;
  final VoidCallback? retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 22),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: _subtitle)),
          if (retry != null) ...[
            const SizedBox(width: 6),
            TextButton(onPressed: retry, child: const Text('Coba Lagi')),
          ],
        ],
      ),
    ),
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, this.disabled = false});
  final IconData icon;
  final bool disabled;

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: disabled ? const Color(0xFFF1F5F9) : const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      icon,
      color: disabled ? const Color(0xFF94A3B8) : AppColors.primaryColor,
      size: 24,
    ),
  );
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox();
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(color: Colors.white),
  );
}

class _LoyaltyShimmer extends StatelessWidget {
  const _LoyaltyShimmer();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFEADDBD),
    highlightColor: const Color(0xFFFFF9EA),
    child: SizedBox(
      height: 90,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _LoyaltyShimmerBar(width: 78, height: 12),
                const SizedBox(height: 7),
                const _LoyaltyShimmerBar(width: 72, height: 30),
                const SizedBox(height: 6),
                const _LoyaltyShimmerBar(width: 62, height: 8),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const _LoyaltyShimmerBar(width: 76, height: 12),
        ],
      ),
    ),
  );
}

class _LoyaltyShimmerBar extends StatelessWidget {
  const _LoyaltyShimmerBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}

const _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9))),
  boxShadow: [
    BoxShadow(color: Color(0x120F172A), blurRadius: 20, offset: Offset(0, 6)),
  ],
);
const double _bannerAspectRatio = 2.28;
const double _bannerSideBleed = 12;
const double _bannerHorizontalBleed = _bannerSideBleed * 2;
const double _bannerCardOverlap = 20;
const double _companyCardHeight = 52;
const _sectionTitle = TextStyle(
  color: Color(0xFF1E293B),
  fontSize: 14,
  fontWeight: FontWeight.w700,
);
const _subtitle = TextStyle(color: Color(0xFF64748B), fontSize: 9.5);
const _loyaltyTitle = TextStyle(
  color: _loyaltyRed,
  fontSize: 15,
  fontWeight: FontWeight.w700,
);
const _loyaltyRed = Color(0xFFB21E2B);
