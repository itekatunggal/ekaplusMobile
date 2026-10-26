import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/customer/data/models/customer_credit_policy.dart';
import 'package:ekaplus_ekatunggal/features/customer/data/services/customer_credit_limit_service.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerCompanyCard extends StatefulWidget {
  CustomerCompanyCard({
    super.key,
    required this.company,
    required this.onChangeCompany,
    this.reloadKey = 0,
    CustomerCreditLimitService? creditLimitService,
  }) : creditLimitService = creditLimitService ?? _defaultCreditLimitService;

  static final CustomerCreditLimitService _defaultCreditLimitService =
      CustomerCreditLimitService();

  final ActiveMemberCompany company;
  final VoidCallback onChangeCompany;
  final int reloadKey;
  final CustomerCreditLimitService creditLimitService;

  @override
  State<CustomerCompanyCard> createState() => _CustomerCompanyCardState();
}

class _CustomerCompanyCardState extends State<CustomerCompanyCard> {
  late Future<CustomerCreditPolicy> _creditPolicy;

  ActiveMemberCompany get company => widget.company;

  @override
  void initState() {
    super.initState();
    _loadCreditPolicy();
  }

  @override
  void didUpdateWidget(covariant CustomerCompanyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.company.branchCustomerCode !=
            widget.company.branchCustomerCode ||
        oldWidget.company.branchCustomerId != widget.company.branchCustomerId ||
        oldWidget.creditLimitService != widget.creditLimitService ||
        oldWidget.reloadKey != widget.reloadKey) {
      _loadCreditPolicy();
    }
  }

  void _loadCreditPolicy() {
    _creditPolicy = widget.creditLimitService.fetch(
      widget.company.branchCustomerCode ?? '',
      branchCustomerId: widget.company.branchCustomerId,
    );
  }

  String get _initials {
    final source = (company.gcName ?? company.customerCompanyName ?? 'ET')
        .trim();
    final words = source.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    return words.take(2).map((word) => word[0]).join().toUpperCase();
  }

  String get _companyName {
    final name = (company.gcName ?? company.customerCompanyName ?? '').trim();
    return name.isEmpty ? company.displayName : name;
  }

  String get _companyMeta {
    final branch = (company.branchName ?? '').trim();
    final city = (company.branchCity ?? '').trim();

    if (branch.isEmpty) {
      return city.isEmpty ? 'Cabang Utama' : city;
    }

    return city.isEmpty ? branch : '$branch ($city)';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusBadge(isTaxable: company.customerTaxStatus),
                        Text(
                          _companyMeta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: widget.onChangeCompany,
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                label: const Text('Ganti'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  backgroundColor: const Color(0xFFFEF2F2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  minimumSize: const Size(0, 40),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                    side: const BorderSide(color: Color(0xFFFEE2E2)),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          FutureBuilder<CustomerCreditPolicy>(
            future: _creditPolicy,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _CreditLoadingView();
              }

              if (!snapshot.hasData) {
                return _CreditErrorView(
                  onRetry: () {
                    setState(_loadCreditPolicy);
                  },
                );
              }

              return _CreditPolicyView(policy: snapshot.data!);
            },
          ),
        ],
      ),
    );
  }
}

class _CreditPolicyView extends StatelessWidget {
  const _CreditPolicyView({required this.policy});

  final CustomerCreditPolicy policy;

  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  String _money(double value) => _rupiah.format(value);

  /// Warna progress mengikuti tingkat pemakaian plafon.
  Color _usageColor(double ratio) {
    if (ratio >= 0.9) return const Color(0xFFDC2626);
    if (ratio >= 0.7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    if (!policy.hasCreditLimit) {
      return const _NoCreditLimitView();
    }

    final ratio = policy.usedRatio.clamp(0.0, 1.0).toDouble();
    final percentage = (policy.usedRatio * 100).toStringAsFixed(1);
    final paymentTerm = policy.paymentTermDays;
    final usageColor = _usageColor(ratio);
    final ownerName = (policy.limitOwnerName ?? '').trim().isEmpty
        ? policy.limitOwnerFallback
        : policy.limitOwnerName!.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + chip TOP
        Row(
          children: [
            const Expanded(
              child: Text(
                'Sisa Plafon Kredit',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _TermChip(
              label: paymentTerm == null
                  ? 'TOP belum ditetapkan'
                  : 'TOP $paymentTerm Hari',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _money(policy.remainingCredit),
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation(usageColor),
          ),
        ),
        const SizedBox(height: 10),

        // Terpakai & Credit Limit
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AmountStat(
                label: 'Terpakai ($percentage%)',
                value: _money(policy.totalLimitOutstanding),
                valueColor: usageColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AmountStat(
                label: 'Credit Limit',
                value: _money(policy.finalCreditLimit),
                alignEnd: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Level + pemilik limit
        _LimitOwnerRow(
          level: policy.creditLimitLevelLabel,
          ownerName: ownerName,
        ),
      ],
    );
  }
}

class _TermChip extends StatelessWidget {
  const _TermChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 12,
            color: Color(0xFF475569),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountStat extends StatelessWidget {
  const _AmountStat({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF334155),
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _LimitOwnerRow extends StatelessWidget {
  const _LimitOwnerRow({required this.level, required this.ownerName});

  final String level;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              size: 16,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limit level $level',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  ownerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _NoCreditLimitView extends StatelessWidget {
  const _NoCreditLimitView();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.credit_card_off_outlined,
            size: 18,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer ini belum memiliki plafon kredit',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Limit kredit belum ditetapkan untuk customer ini.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        _CreditInfoBadge(label: 'Belum ada limit'),
      ],
    );
  }
}

class _CreditLoadingView extends StatelessWidget {
  const _CreditLoadingView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 54,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _CreditErrorView extends StatelessWidget {
  const _CreditErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sisa Plafon Kredit',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
              SizedBox(height: 4),
              Text(
                'Data tidak tersedia',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isTaxable});

  final bool isTaxable;

  @override
  Widget build(BuildContext context) {
    final color = isTaxable ? const Color(0xFF047857) : const Color(0xFF64748B);
    final background = isTaxable
        ? const Color(0xFFECFDF5)
        : const Color(0xFFF1F5F9);
    final border = isTaxable
        ? const Color(0xFFA7F3D0)
        : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isTaxable ? 'PKP' : 'Non PKP',
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditInfoBadge extends StatelessWidget {
  const _CreditInfoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF92400E),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
