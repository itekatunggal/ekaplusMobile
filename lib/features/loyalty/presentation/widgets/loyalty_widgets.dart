import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final NumberFormat _pointFormat = NumberFormat.decimalPattern('id_ID');
final NumberFormat _moneyFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);
final DateFormat _dateFormat = DateFormat('d MMMM y', 'id_ID');

String formatPointNumber(num value) => _pointFormat.format(value);
String formatPoint(num value) => '${formatPointNumber(value)} Poin';
String formatMoney(num value) => _moneyFormat.format(value);
String formatDate(DateTime? value) =>
    value == null ? '-' : _dateFormat.format(value.toLocal());

String redemptionStatusLabel(LoyaltyRedemptionStatus status) =>
    switch (status) {
      LoyaltyRedemptionStatus.pending => 'Dalam Proses',
      LoyaltyRedemptionStatus.approved => 'Berhasil',
      LoyaltyRedemptionStatus.rejected => 'Ditolak',
      LoyaltyRedemptionStatus.unknown => 'Status belum tersedia',
    };

class LoyaltySectionCard extends StatelessWidget {
  const LoyaltySectionCard({
    super.key,
    required this.title,
    required this.child,
    this.onSeeAll,
  });
  final String title;
  final Widget child;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .45,
                  ),
                ),
              ),
              if (onSeeAll != null)
                InkWell(
                  onTap: onSeeAll,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
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
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}

class LoyaltyBalanceCard extends StatelessWidget {
  const LoyaltyBalanceCard({super.key, required this.balance});
  final LoyaltyBalance balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB11F23), Color(0xFFD52A2F)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29B11F23),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Poin Tersedia',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatPoint(balance.availablePoint),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: -.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BalanceMeta(
                    label: 'Total Poin',
                    value: balance.totalPoint,
                  ),
                ),
                const _BalanceDivider(),
                Expanded(
                  child: _BalanceMeta(
                    label: 'Dalam Proses',
                    value: balance.reservedPoint,
                  ),
                ),
                const _BalanceDivider(),
                Expanded(
                  child: _BalanceMeta(
                    label: 'Digunakan',
                    value: balance.redeemedPoint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceMeta extends StatelessWidget {
  const _BalanceMeta({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 8),
      ),
      const SizedBox(height: 2),
      Text(
        _pointFormat.format(value),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _BalanceDivider extends StatelessWidget {
  const _BalanceDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: const Color(0x33FFFFFF));
}

class LoyaltyBucketNotice extends StatelessWidget {
  const LoyaltyBucketNotice({super.key, required this.balance});
  final LoyaltyBalance balance;

  @override
  Widget build(BuildContext context) {
    final notReady = balance.buckets
        .where((b) => !b.ready && b.availablePoint > 0)
        .fold<int>(0, (sum, b) => sum + b.availablePoint);
    final usable =
        balance.buckets
            .where(
              (b) =>
                  b.ready &&
                  !b.expired &&
                  b.availablePoint > 0 &&
                  b.validTo != null,
            )
            .toList()
          ..sort((a, b) => a.validTo!.compareTo(b.validTo!));
    if (notReady <= 0 && usable.isEmpty) return const SizedBox.shrink();
    final bucket = usable.isEmpty ? null : usable.first;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 18,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bucket != null)
                  Text(
                    '${_pointFormat.format(bucket.availablePoint)} poin akan berakhir',
                    style: const TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (bucket != null)
                  Text(
                    formatDate(bucket.validTo),
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 9.5,
                    ),
                  ),
                if (bucket != null && notReady > 0) const SizedBox(height: 4),
                if (notReady > 0)
                  Text(
                    '${_pointFormat.format(notReady)} poin belum dapat digunakan',
                    style: const TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 9.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoyaltyEarningTile extends StatelessWidget {
  const LoyaltyEarningTile({super.key, required this.item});
  final LoyaltyEarningDetail item;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.add_chart_rounded,
            color: Color(0xFF059669),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.category,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Total Pembelian ${formatMoney(item.purchaseAmount)}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
              ),
              Text(
                '${formatMoney(item.pointDivider)} = 1 poin',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '+${_pointFormat.format(item.awardedPoint)}',
          style: const TextStyle(
            color: Color(0xFF059669),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class LoyaltyRewardTile extends StatelessWidget {
  const LoyaltyRewardTile({
    super.key,
    required this.reward,
    required this.availablePoint,
    required this.onTap,
  });
  final LoyaltyReward reward;
  final int availablePoint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canRedeem =
        reward.available && availablePoint >= reward.pointRequired;
    final shortage = (reward.pointRequired - availablePoint).clamp(
      0,
      reward.pointRequired,
    );
    final url = reward.imageUrl == null
        ? ''
        : ApiConfig.getImageUrl(reward.imageUrl);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Container(
                width: 52,
                height: 52,
                color: const Color(0xFFFFFBEB),
                child: url.isEmpty
                    ? const Icon(
                        Icons.card_giftcard_rounded,
                        color: Color(0xFFD97706),
                        size: 24,
                      )
                    : CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.card_giftcard_rounded,
                          color: Color(0xFFD97706),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatPoint(reward.pointRequired),
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    canRedeem
                        ? 'Bisa ditukar'
                        : reward.available
                        ? 'Kurang ${_pointFormat.format(shortage)} poin'
                        : 'Tidak tersedia',
                    style: TextStyle(
                      color: canRedeem
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1),
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class LoyaltyHistoryTile extends StatelessWidget {
  const LoyaltyHistoryTile({super.key, required this.item, this.onTap});
  final LoyaltyRedemption item;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final color = switch (item.status) {
      LoyaltyRedemptionStatus.approved => const Color(0xFF059669),
      LoyaltyRedemptionStatus.rejected => AppColors.primaryColor,
      _ => const Color(0xFFD97706),
    };
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFF64748B),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.rewardName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(item.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${_pointFormat.format(item.pointUsed)} Poin',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  redemptionStatusLabel(item.status),
                  style: TextStyle(
                    color: color,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LoyaltySectionMessage extends StatelessWidget {
  const LoyaltySectionMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.inbox_outlined,
  });
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 25),
        const SizedBox(height: 7),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            height: 1.4,
          ),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
      ],
    ),
  );
}

class LoyaltyLoading extends StatelessWidget {
  const LoyaltyLoading({super.key, this.height = 82});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryColor,
        strokeWidth: 2,
      ),
    ),
  );
}

class LoyaltyDividedList extends StatelessWidget {
  const LoyaltyDividedList({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var index = 0; index < children.length; index++) ...[
        children[index],
        if (index != children.length - 1)
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
      ],
    ],
  );
}
