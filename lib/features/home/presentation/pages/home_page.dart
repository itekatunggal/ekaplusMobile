import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/feature_flags.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/profile_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_cubit.dart';
import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_state.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_state.dart';
import 'package:ekaplus_ekatunggal/features/home/presentation/widgets/home_slider_widget.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/data/services/loyalty_service.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/customer_point_summary_cubit.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/cubit/sales_directory_cubit.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/cubit/sales_directory_state.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/widgets/sales_profile_card.dart';
import 'package:ekaplus_ekatunggal/features/promotion/presentation/cubit/promotion_cubit.dart';
import 'package:ekaplus_ekatunggal/features/promotion/presentation/widgets/promotion_card.dart';
import 'package:ekaplus_ekatunggal/features/article/presentation/cubit/article_cubit.dart';
import 'package:ekaplus_ekatunggal/features/article/presentation/widgets/article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CustomerPointSummaryCubit _points;
  int? _loadedGpid;
  String? _loadedBcid;
  int? _loadedSalesBranchId;
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

  void _syncSales(int? branchId) {
    if (branchId == null || branchId == _loadedSalesBranchId) return;
    _loadedSalesBranchId = branchId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SalesDirectoryCubit>().load(branchId: branchId);
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
    if (selectedBranch != null) {
      await context.read<SalesDirectoryCubit>().load(
        branchId: selectedBranch.id,
      );
    }
    if (!mounted) return;
    await Future.wait([
      context.read<PromotionCubit>().load(branchId: selectedBranch?.id),
      context.read<ArticleCubit>().load(),
    ]);
    if (!mounted) return;
    final state = context.read<ActiveCompanyCubit>().state;
    final company = state is ActiveCompanyReady ? state.activeCompany : null;
    await _points.load(company?.gpidId, bcid: _bcid(company));
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
            _syncSales(branch?.id);
            _syncPromotions(branch?.id);
            return BlocProvider.value(
              value: _points,
              child: Scaffold(
                backgroundColor: const Color(0xFFF6F7F9),
                body: SafeArea(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: ProfileHeader(),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primaryColor,
                          onRefresh: _refresh,
                          child: ListView(
                            key: const PageStorageKey('home-scroll'),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
                            children: [
                              _Banner(
                                loggedIn: loggedIn,
                                retry: () =>
                                    context.read<BannerCubit>().fetchBanners(),
                              ),
                              if (FeatureFlags.showBranchDirectory) ...[
                                const SizedBox(height: 14),
                                _BranchCard(
                                  state: branchState,
                                  branch: branch,
                                  onTap: () => context.goNamed('branches'),
                                  retry: () => context
                                      .read<SelectedBranchCubit>()
                                      .load(force: true),
                                ),
                              ],
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
                                  rewards: company == null
                                      ? null
                                      : () => context.pushNamed(
                                          'loyalty-rewards',
                                          extra: {'bcid': _bcid(company)},
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
                                loggedIn: loggedIn,
                                sales: () => context.goNamed('sales'),
                                branch: () => context.goNamed('branches'),
                                transaction: () => loggedIn
                                    ? context.goNamed('customer')
                                    : context.pushNamed('login'),
                              ),
                              if (FeatureFlags.showSalesDirectory) ...[
                                const SizedBox(height: 16),
                                _SalesSection(
                                  branch: branch,
                                  seeAll: () => context.goNamed('sales'),
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
  const _Banner({required this.loggedIn, required this.retry});
  final bool loggedIn;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: SizedBox(
      height: 180,
      child: BlocBuilder<BannerCubit, BannerState>(
        builder: (context, state) {
          if (state is BannerLoaded) {
            return HomeSliderWidget(
              banners: state.banners,
              enableTap: loggedIn,
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
      ),
    ),
  );
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.state,
    required this.branch,
    required this.onTap,
    required this.retry,
  });
  final SelectedBranchState state;
  final Branch? branch;
  final VoidCallback onTap;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    if (state.status == SelectedBranchStatus.error && state.branches.isEmpty) {
      return _Card(
        child: _StateView(
          icon: Icons.store_mall_directory_outlined,
          text: 'Cabang belum dapat dimuat',
          retry: retry,
        ),
      );
    }
    if (state.status == SelectedBranchStatus.ready && branch == null) {
      return const _Card(
        child: _StateView(
          icon: Icons.store_mall_directory_outlined,
          text: 'Cabang mengikuti customer aktif',
        ),
      );
    }
    if (branch == null) return const _Card(child: _BranchShimmer());
    final location = [
      branch!.city?.trim(),
      branch!.area?.trim(),
    ].whereType<String>().where((text) => text.isNotEmpty).join(' • ');
    return _Card(
      onTap: onTap,
      child: Row(
        children: [
          const _IconBox(icon: Icons.store_mall_directory_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CABANG INFORMASI AKTIF', style: _eyebrow),
                const SizedBox(height: 4),
                Text(
                  branch!.branchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _cardTitle,
                ),
                if (location.isNotEmpty)
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _subtitle,
                  ),
                if (state.status == SelectedBranchStatus.error) ...[
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Menampilkan data tersimpan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (state.status == SelectedBranchStatus.error)
            IconButton(
              tooltip: 'Coba perbarui cabang',
              onPressed: retry,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryColor,
              ),
            )
          else
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
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
    required this.rewards,
    required this.details,
  });
  final bool loggedIn;
  final ActiveCompanyState companyState;
  final ActiveMemberCompany? company;
  final String? bcid;
  final VoidCallback login;
  final VoidCallback addCompany;
  final VoidCallback retry;
  final VoidCallback? rewards;
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.secondaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('EkaPoint', style: _loyaltyTitle)),
                  Flexible(
                    child: Text(
                      (company!.gpName ?? '').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD7BCC0),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Total Poin Tersedia',
                style: TextStyle(color: Color(0xFFE8DADD), fontSize: 10),
              ),
              Text(
                NumberFormat.decimalPattern(
                  'id_ID',
                ).format(state.availablePoint),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _LoyaltyButton(
                      label: 'Tukar Poin',
                      filled: true,
                      action: rewards,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LoyaltyButton(
                      label: 'Rincian Poin',
                      action: details,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF68151A), Color(0xFF991D22)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _QuickServices extends StatelessWidget {
  const _QuickServices({
    required this.loggedIn,
    required this.sales,
    required this.branch,
    required this.transaction,
  });
  final bool loggedIn;
  final VoidCallback sales;
  final VoidCallback branch;
  final VoidCallback transaction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Header(title: 'Layanan Cepat'),
      const SizedBox(height: 8),
      _Card(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: _QuickItem(
                icon: Icons.support_agent_rounded,
                label: 'Hubungi\nSales',
                action: sales,
              ),
            ),
            Expanded(
              child: _QuickItem(
                icon: Icons.location_on_outlined,
                label: 'Lokasi\nCabang',
                action: branch,
              ),
            ),
            Expanded(
              child: _QuickItem(
                icon: Icons.receipt_long_outlined,
                label: 'Transaksi',
                caption: loggedIn ? null : 'Masuk dulu',
                action: transaction,
              ),
            ),
            const Expanded(
              child: _QuickItem(
                icon: Icons.help_outline_rounded,
                label: 'Bantuan',
                caption: 'Segera',
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _SalesSection extends StatelessWidget {
  const _SalesSection({required this.branch, required this.seeAll});
  final Branch? branch;
  final VoidCallback seeAll;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SalesDirectoryCubit, SalesDirectoryState>(
        builder: (context, state) => Column(
          children: [
            _Header(
              title: 'Sales Ekatunggal',
              subtitle: branch == null
                  ? 'Pilih customer aktif untuk melihat tim sales'
                  : 'Tim sales cabang ${branch!.branchName}',
              action: seeAll,
            ),
            const SizedBox(height: 8),
            if (branch == null)
              const _Card(
                child: _StateView(
                  icon: Icons.support_agent_rounded,
                  text: 'Data sales menunggu customer aktif',
                ),
              )
            else if (state.status == SalesDirectoryStatus.loading &&
                state.profiles.isEmpty)
              const SizedBox(height: 190, child: _ShimmerBox())
            else if (state.status == SalesDirectoryStatus.error)
              _Card(
                child: _StateView(
                  icon: Icons.cloud_off_rounded,
                  text: 'Data sales belum dapat dimuat',
                  retry: () => context.read<SalesDirectoryCubit>().load(
                    branchId: branch!.id,
                  ),
                ),
              )
            else if (state.profiles.isEmpty)
              const _Card(
                child: _StateView(
                  icon: Icons.person_search_outlined,
                  text: 'Belum ada data sales untuk cabang ini',
                ),
              )
            else
              SizedBox(
                height: 190,
                child: ListView.separated(
                  key: const PageStorageKey('home-sales-carousel'),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.profiles.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final profile = state.profiles[index];
                    return SalesProfileCard(
                      compact: true,
                      profile: profile,
                      onTap: () => context.pushNamed(
                        'sales-detail',
                        pathParameters: {'salesId': '${profile.id}'},
                        extra: profile,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
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
  const _QuickItem({
    required this.icon,
    required this.label,
    this.caption,
    this.action,
  });
  final IconData icon;
  final String label;
  final String? caption;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Semantics(
    button: action != null,
    enabled: action != null,
    label: caption == null ? label : '$label, $caption',
    excludeSemantics: true,
    child: InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _IconBox(icon: icon, disabled: action == null),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 9,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 7.5,
                  ),
                ),
            ],
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
      const Icon(
        Icons.workspace_premium_outlined,
        color: AppColors.secondaryColor,
        size: 36,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _loyaltyTitle),
            Text(
              message,
              style: const TextStyle(color: Color(0xFFE8DADD), fontSize: 9.5),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: FilledButton(
                onPressed: action,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  foregroundColor: AppColors.blackColor,
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

class _LoyaltyButton extends StatelessWidget {
  const _LoyaltyButton({
    required this.label,
    required this.action,
    this.filled = false,
  });
  final String label;
  final VoidCallback? action;
  final bool filled;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: filled
        ? FilledButton(
            onPressed: action,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: AppColors.blackColor,
            ),
            child: Text(label, style: _buttonText),
          )
        : OutlinedButton(
            onPressed: action,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0x66FFFFFF)),
            ),
            child: Text(label, style: _buttonText),
          ),
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
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: disabled ? const Color(0xFFF1F5F9) : const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      icon,
      color: disabled ? const Color(0xFF94A3B8) : AppColors.primaryColor,
      size: 21,
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

class _BranchShimmer extends StatelessWidget {
  const _BranchShimmer();
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: const SizedBox(height: 44, child: ColoredBox(color: Colors.white)),
  );
}

class _LoyaltyShimmer extends StatelessWidget {
  const _LoyaltyShimmer();
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFF8C4C50),
    highlightColor: const Color(0xFFB47B7E),
    child: const SizedBox(height: 130, child: ColoredBox(color: Colors.white)),
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
const _sectionTitle = TextStyle(
  color: Color(0xFF1E293B),
  fontSize: 14,
  fontWeight: FontWeight.w700,
);
const _cardTitle = TextStyle(
  color: Color(0xFF1E293B),
  fontSize: 13,
  fontWeight: FontWeight.w700,
);
const _subtitle = TextStyle(color: Color(0xFF64748B), fontSize: 9.5);
const _eyebrow = TextStyle(
  color: Color(0xFF94A3B8),
  fontSize: 9,
  fontWeight: FontWeight.w700,
  letterSpacing: .4,
);
const _loyaltyTitle = TextStyle(
  color: Colors.white,
  fontSize: 13,
  fontWeight: FontWeight.w700,
);
const _buttonText = TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700);
