import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/cubit/loyalty_point_cubit.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/presentation/widgets/loyalty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoyaltyRewardDetailPage extends StatefulWidget {
  const LoyaltyRewardDetailPage({super.key, required this.reward});
  final LoyaltyReward reward;
  @override
  State<LoyaltyRewardDetailPage> createState() =>
      _LoyaltyRewardDetailPageState();
}

class _LoyaltyRewardDetailPageState extends State<LoyaltyRewardDetailPage> {
  int _quantity = 1;
  bool _submitting = false;
  String? _attemptKey;

  Future<void> _confirmRedeem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tukar poin?'),
        content: Text(
          'Anda akan menukar ${formatPoint(widget.reward.pointRequired * _quantity)} untuk ${widget.reward.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tukar Poin'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _submitting = true;
      _attemptKey ??=
          '${DateTime.now().microsecondsSinceEpoch}-${widget.reward.id}';
    });
    try {
      final status = await context.read<LoyaltyPointCubit>().redeem(
        widget.reward,
        _quantity,
        idempotencyKey: _attemptKey,
      );
      if (!mounted) return;
      _attemptKey = null;
      AppSnackbar.show(
        context,
        message: status == LoyaltyRedemptionStatus.pending
            ? 'Penukaran poin sedang diproses.'
            : 'Reward berhasil ditukar.',
        type: status == LoyaltyRedemptionStatus.pending
            ? AppSnackbarType.info
            : AppSnackbarType.success,
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      final text = error.toString().toUpperCase();
      final message = text.contains('INSUFFICIENT_POINT')
          ? 'Poin Anda tidak mencukupi untuk menukar hadiah ini.'
          : text.contains('QUOTA_EXHAUSTED')
          ? 'Hadiah ini sudah tidak tersedia.'
          : text.contains('REWARD_INACTIVE') || text.contains('REWARD_EXPIRED')
          ? 'Hadiah ini sudah tidak dapat ditukar.'
          : 'Penukaran belum berhasil. Silakan coba kembali.';
      AppSnackbar.show(context, message: message, type: AppSnackbarType.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<LoyaltyPointCubit, LoyaltyPointState>(
    builder: (context, state) {
      final reward = widget.reward;
      final available = state.balance?.availablePoint ?? 0;
      final total = reward.pointRequired * _quantity;
      final canRedeem = reward.available && available >= total;
      final imageUrl = reward.imageUrl == null
          ? ''
          : ApiConfig.getImageUrl(reward.imageUrl);
      return CustomHeaderScaffold(
        title: 'Detail Reward',
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 8,
                    child: Container(
                      color: const Color(0xFFFFFBEB),
                      child: imageUrl.isEmpty
                          ? const Icon(
                              Icons.card_giftcard_rounded,
                              size: 56,
                              color: Color(0xFFD97706),
                            )
                          : CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.card_giftcard_rounded,
                                size: 56,
                                color: Color(0xFFD97706),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.name,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatPoint(reward.pointRequired),
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (reward.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            reward.description,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        _DataRow(
                          label: 'Poin Anda',
                          value: formatPoint(available),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Jumlah',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _quantity > 1 && !_submitting
                                  ? () => setState(() => _quantity--)
                                  : null,
                              icon: const Icon(
                                Icons.remove_circle_outline_rounded,
                              ),
                              iconSize: 21,
                              visualDensity: VisualDensity.compact,
                            ),
                            SizedBox(
                              width: 28,
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: !_submitting
                                  ? () => setState(() => _quantity++)
                                  : null,
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                              ),
                              iconSize: 21,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _DataRow(
                          label: 'Total Poin',
                          value: formatPoint(total),
                          strong: true,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: canRedeem && !_submitting
                                ? _confirmRedeem
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    canRedeem
                                        ? 'Tukar Poin'
                                        : 'Poin Belum Mencukupi',
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Penukaran dapat memerlukan persetujuan. Status terbaru akan tampil pada aktivitas poin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 8.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.label,
    required this.value,
    this.strong = false,
  });
  final String label;
  final String value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: strong ? AppColors.primaryColor : const Color(0xFF1E293B),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
