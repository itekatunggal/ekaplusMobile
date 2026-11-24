import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/core/theme/app_card_styles.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/loyalty_calculation_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class LoyaltyCalculationDetailPage extends StatefulWidget {
  const LoyaltyCalculationDetailPage({
    super.key,
    this.groupParentCode,
    this.groupParentName,
  });

  final String? groupParentCode;
  final String? groupParentName;

  @override
  State<LoyaltyCalculationDetailPage> createState() =>
      _LoyaltyCalculationDetailPageState();
}

class _LoyaltyCalculationDetailPageState
    extends State<LoyaltyCalculationDetailPage> {
  LoyaltyPointActivityType? _filter;

  @override
  Widget build(BuildContext context) {
    return CustomHeaderScaffold(
      title: 'Rincian Poin',
      showBackButton: true,
      backgroundColor: const Color(0xFFF6F7F9),
      headerHeight: 160,
      contentTop: 124,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 12),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: BlocBuilder<LoyaltyCalculationCubit, LoyaltyCalculationState>(
            builder: (context, state) {
              final filteredActivities = _filter == null
                  ? state.activities
                  : state.activities
                        .where((activity) => activity.type == _filter)
                        .toList(growable: false);

              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: context.read<LoyaltyCalculationCubit>().load,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  children: [
                    if (state.status == LoyaltyCalculationStatus.initial ||
                        state.status == LoyaltyCalculationStatus.loading)
                      const _PageSkeleton()
                    else if (state.status == LoyaltyCalculationStatus.failure)
                      _ErrorCard(
                        onRetry: context
                            .read<LoyaltyCalculationCubit>()
                            .loadCalculation,
                      )
                    else ...[
                      _PointSummary(
                        ledger: state.ledger,
                        groupParentName: widget.groupParentName,
                      ),
                      const SizedBox(height: 18),
                      const _SectionHeading(),
                      const SizedBox(height: 8),
                      _PointActivityFilters(
                        selected: _filter,
                        onSelected: (filter) =>
                            setState(() => _filter = filter),
                      ),
                      const SizedBox(height: 10),
                      if (state.activities.isEmpty)
                        const _EmptyTimeline()
                      else if (filteredActivities.isEmpty)
                        const _EmptyTimeline(
                          message: 'Tidak ada aktivitas untuk filter ini.',
                        )
                      else
                        _MonthlyTimeline(
                          activities: filteredActivities,
                          allActivities: state.activities,
                        ),
                    ],
                    const SizedBox(height: 28),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PointActivityFilters extends StatelessWidget {
  const _PointActivityFilters({
    required this.selected,
    required this.onSelected,
  });

  final LoyaltyPointActivityType? selected;
  final ValueChanged<LoyaltyPointActivityType?> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _chip('Semua', null),
        const SizedBox(width: 6),
        _chip('Poin Masuk', LoyaltyPointActivityType.earned),
        const SizedBox(width: 6),
        _chip('Poin Keluar', LoyaltyPointActivityType.used),
      ],
    ),
  );

  Widget _chip(String label, LoyaltyPointActivityType? value) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: const Color(0xFFFEF2F2),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : const Color(0xFF64748B),
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
  }
}

class _PointSummary extends StatelessWidget {
  const _PointSummary({required this.ledger, this.groupParentName});

  final LoyaltyLedger? ledger;
  final String? groupParentName;

  @override
  Widget build(BuildContext context) {
    final customerName = (groupParentName ?? 'Customer aktif').trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.major,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.primaryColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // const SizedBox(height: 2),
                    // Text(
                    //   ledger?.periodName ?? 'Riwayat aktivitas EkaPoint',
                    //   style: const TextStyle(
                    //     color: Color(0xFF64748B),
                    //     fontSize: 8.5,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Poin Tersedia',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rincian aktivitas tercatat di bawah',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatPointNumber(ledger?.earnedPoint ?? 0),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  'Poin',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 10,
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
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 2),
    child: Text(
      'RIWAYAT POIN',
      style: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: .45,
      ),
    ),
  );
}

class _MonthlyTimeline extends StatelessWidget {
  const _MonthlyTimeline({
    required this.activities,
    required this.allActivities,
  });

  final List<LoyaltyPointActivity> activities;
  final List<LoyaltyPointActivity> allActivities;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<LoyaltyPointActivity>>{};
    for (final activity in activities) {
      final date = activity.occurredAt;
      final key = date == null
          ? activity.description
          : _capitalize(DateFormat('MMMM y', 'id_ID').format(date.toLocal()));
      groups.putIfAbsent(key, () => []).add(activity);
    }

    return Column(
      children: groups.entries
          .map((group) {
            final detailActivities = allActivities
                .where((activity) => _monthLabel(activity) == group.key)
                .toList(growable: false);
            final previewActivities = group.value
                .take(3)
                .toList(growable: false);
            final earnedThisMonth = group.value
                .where(
                  (activity) =>
                      activity.type == LoyaltyPointActivityType.earned,
                )
                .fold<int>(0, (total, activity) => total + activity.point);
            final usedThisMonth = group.value
                .where(
                  (activity) => activity.type == LoyaltyPointActivityType.used,
                )
                .fold<int>(0, (total, activity) => total + activity.point);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 7),
                    child: Text(
                      group.key,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    decoration: AppCardStyles.major,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ...List.generate(previewActivities.length, (index) {
                          return _TimelineItem(
                            activity: previewActivities[index],
                            isFirst: index == 0,
                            isLast: index == previewActivities.length - 1,
                          );
                        }),
                        if (group.value.length > previewActivities.length)
                          _SeeMoreButton(
                            remainingCount:
                                group.value.length - previewActivities.length,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => _MonthlyActivityDetailPage(
                                  month: group.key,
                                  activities: detailActivities,
                                ),
                              ),
                            ),
                          ),
                        _MonthlySummary(
                          earned: earnedThisMonth,
                          used: usedThisMonth,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }

  String _capitalize(String value) => value.isEmpty
      ? value
      : '${value.substring(0, 1).toUpperCase()}${value.substring(1)}';

  String _monthLabel(LoyaltyPointActivity activity) {
    final date = activity.occurredAt;
    return date == null
        ? activity.description
        : _capitalize(DateFormat('MMMM y', 'id_ID').format(date.toLocal()));
  }
}

class _SeeMoreButton extends StatelessWidget {
  const _SeeMoreButton({required this.remainingCount, required this.onPressed});

  final int remainingCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
    ),
    child: TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.list_alt_rounded, size: 15),
      label: Text('Lihat Selengkapnya ($remainingCount lainnya)'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 10),
        textStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700),
        shape: const RoundedRectangleBorder(),
      ),
    ),
  );
}

class _MonthlyActivityDetailPage extends StatefulWidget {
  const _MonthlyActivityDetailPage({
    required this.month,
    required this.activities,
  });

  final String month;
  final List<LoyaltyPointActivity> activities;

  @override
  State<_MonthlyActivityDetailPage> createState() =>
      _MonthlyActivityDetailPageState();
}

class _MonthlyActivityDetailPageState
    extends State<_MonthlyActivityDetailPage> {
  LoyaltyPointActivityType? _filter;

  @override
  Widget build(BuildContext context) {
    final totalEarned = widget.activities
        .where((activity) => activity.type == LoyaltyPointActivityType.earned)
        .fold<int>(0, (total, activity) => total + activity.point);
    final totalUsed = widget.activities
        .where((activity) => activity.type == LoyaltyPointActivityType.used)
        .fold<int>(0, (total, activity) => total + activity.point);
    final monthlyPoint = totalEarned - totalUsed;
    final filteredActivities = _filter == null
        ? widget.activities
        : widget.activities
              .where((activity) => activity.type == _filter)
              .toList(growable: false);
    final earned = filteredActivities
        .where((activity) => activity.type == LoyaltyPointActivityType.earned)
        .fold<int>(0, (total, activity) => total + activity.point);
    final used = filteredActivities
        .where((activity) => activity.type == LoyaltyPointActivityType.used)
        .fold<int>(0, (total, activity) => total + activity.point);

    return CustomHeaderScaffold(
      title: 'Rincian ${widget.month}',
      showBackButton: true,
      backgroundColor: const Color(0xFFF6F7F9),
      headerHeight: 160,
      contentTop: 124,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 12),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              _MonthlyPointSummary(month: widget.month, point: monthlyPoint),
              const SizedBox(height: 16),
              _PointActivityFilters(
                selected: _filter,
                onSelected: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Text(
                  '${filteredActivities.length} TRANSAKSI',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .45,
                  ),
                ),
              ),
              if (filteredActivities.isEmpty)
                const _EmptyTimeline(
                  message: 'Tidak ada aktivitas untuk filter ini.',
                )
              else
                Container(
                  decoration: AppCardStyles.major,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ...List.generate(filteredActivities.length, (index) {
                        return _TimelineItem(
                          activity: filteredActivities[index],
                          isFirst: index == 0,
                          isLast: index == filteredActivities.length - 1,
                        );
                      }),
                      _MonthlySummary(earned: earned, used: used),
                    ],
                  ),
                ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyPointSummary extends StatelessWidget {
  const _MonthlyPointSummary({required this.month, required this.point});

  final String month;
  final int point;

  @override
  Widget build(BuildContext context) {
    final pointColor = point >= 0
        ? const Color(0xFF059669)
        : AppColors.primaryColor;
    final iconBackground = point >= 0
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFFF1F2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.major,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: pointColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Poin Bulan $month',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${point > 0 ? '+' : ''}${formatPointNumber(point)}',
            style: TextStyle(
              color: pointColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            'Poin',
            style: TextStyle(
              color: pointColor,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary({required this.earned, required this.used});

  final int earned;
  final int used;

  @override
  Widget build(BuildContext context) {
    final net = earned - used;
    final netColor = net >= 0
        ? const Color(0xFF047857)
        : AppColors.primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${net > 0 ? '+' : ''}${formatPointNumber(net)} Poin',
            style: TextStyle(
              color: netColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.activity,
    required this.isFirst,
    required this.isLast,
  });

  final LoyaltyPointActivity activity;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final incoming = activity.type == LoyaltyPointActivityType.earned;
    final color = incoming ? const Color(0xFF059669) : AppColors.primaryColor;
    final background = incoming
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFFF1F2);
    final date = activity.occurredAt;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isFirst)
                  const Positioned(
                    top: 0,
                    bottom: 36,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                if (!isLast)
                  const Positioned(
                    top: 36,
                    bottom: 0,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: .22)),
                  ),
                  child: Icon(
                    incoming
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    color: color,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 72),
              padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date == null
                              ? activity.description
                              : DateFormat(
                                  'd MMMM y',
                                  'id_ID',
                                ).format(date.toLocal()),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${incoming ? '+' : '-'}${formatPointNumber(activity.point)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Poin',
                    style: TextStyle(
                      color: color.withValues(alpha: .8),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline({
    this.message = 'Riwayat aktivitas poin akan tampil di sini.',
  });

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    decoration: AppCardStyles.major,
    child: Column(
      children: [
        const Icon(Icons.timeline_rounded, color: Color(0xFF94A3B8), size: 38),
        const SizedBox(height: 10),
        const Text(
          'Belum Ada Riwayat Poin',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
        ),
      ],
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
    decoration: AppCardStyles.major,
    child: Column(
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          color: AppColors.primaryColor,
          size: 36,
        ),
        const SizedBox(height: 10),
        const Text(
          'Riwayat poin belum dapat dimuat',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Coba Lagi'),
        ),
      ],
    ),
  );
}

class _PageSkeleton extends StatelessWidget {
  const _PageSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFE2E8F0),
    highlightColor: const Color(0xFFF8FAFC),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 132,
          decoration: AppCardStyles.major.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 18),
        Container(width: 120, height: 10, color: Colors.white),
        const SizedBox(height: 8),
        for (var index = 0; index < 3; index++) ...[
          Container(
            height: 72,
            decoration: AppCardStyles.major.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
        ],
      ],
    ),
  );
}
