import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/customer_point_summary_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:ekaplus_ekatunggal/features/customer/presentation/widgets/customer_menu_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class CustomerLoyaltyPointCard extends StatelessWidget {
  const CustomerLoyaltyPointCard({
    super.key,
    required this.onCatalogTap,
    required this.onDetailTap,
    required this.onRetry,
  });

  final VoidCallback? onCatalogTap;
  final VoidCallback? onDetailTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerPointSummaryCubit, CustomerPointSummaryState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomerSectionTitle(title: 'Poin & Hadiah'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BrandRow(),
                const SizedBox(height: 18),
                _BalanceContent(state: state, onRetry: onRetry),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                _RewardHint(state: state),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _LoyaltyActionButton(
                        label: 'Tukar Poin',
                        icon: Icons.card_giftcard_rounded,
                        filled: true,
                        onPressed: onCatalogTap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _LoyaltyActionButton(
                        label: 'Rincian Poin',
                        icon: Icons.list_alt_rounded,
                        onPressed: onDetailTap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Icon(
          Icons.workspace_premium_outlined,
          color: Color(0xFFF59E0B),
          size: 21,
        ),
      ),
      const SizedBox(width: 10),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ekapoint',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _BalanceContent extends StatelessWidget {
  const _BalanceContent({required this.state, required this.onRetry});
  final CustomerPointSummaryState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.status == CustomerPointSummaryStatus.initial ||
        state.status == CustomerPointSummaryStatus.loading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 92,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 116,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    if (state.status == CustomerPointSummaryStatus.failure) {
      return Row(
        children: [
          const Expanded(
            child: Text(
              'Data poin belum dapat dimuat',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 15),
            label: const Text('Coba Lagi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              textStyle: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Saldo Poin Anda',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ),
            if (state.ready)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF059669),
                    size: 13,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Siap digunakan',
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 3),
        Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              formatPointNumber(state.availablePoint),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 25,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: -.4,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Poin',
                style: TextStyle(
                  color: Color(0xFFD97706),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RewardHint extends StatelessWidget {
  const _RewardHint({required this.state});
  final CustomerPointSummaryState state;

  @override
  Widget build(BuildContext context) {
    final hasExpiry = state.nearestExpiry != null;
    final message = hasExpiry
        ? 'Berlaku sampai ${DateFormat('d MMMM y', 'id_ID').format(state.nearestExpiry!.toLocal())}'
        : state.availablePoint == 0
        ? 'Mulai kumpulkan poin dari setiap pembelian Anda'
        : 'Gunakan poin untuk berbagai reward eksklusif';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFFF59E0B),
          size: 17,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoyaltyActionButton extends StatelessWidget {
  const _LoyaltyActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: filled
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 17),
            label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: const Color(0xFF1A1A1A),
              disabledBackgroundColor: const Color(0xFFF1F5F9),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 17),
            label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
  );
}
