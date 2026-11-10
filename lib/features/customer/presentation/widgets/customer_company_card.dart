import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/theme/app_card_styles.dart';
import 'package:ekaplus_ekatunggal/features/customer/data/models/customer_credit_policy.dart';
import 'package:ekaplus_ekatunggal/features/customer/data/services/customer_credit_limit_service.dart';
import 'package:ekaplus_ekatunggal/features/customer/presentation/widgets/customer_menu_section.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:flutter/material.dart';

class CustomerCompanyCard extends StatefulWidget {
  const CustomerCompanyCard({
    super.key,
    required this.company,
    required this.onChangeCompany,
  });

  final ActiveMemberCompany company;
  final VoidCallback onChangeCompany;

  @override
  State<CustomerCompanyCard> createState() => _CustomerCompanyCardState();
}

class _CustomerCompanyCardState extends State<CustomerCompanyCard> {
  ActiveMemberCompany get company => widget.company;

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
      decoration: AppCardStyles.major,
      child: Row(
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
                    // _StatusBadge(isTaxable: company.customerTaxStatus),
                    Text(
                      _companyMeta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
    );
  }
}

class CustomerCreditSummaryCard extends StatefulWidget {
  CustomerCreditSummaryCard({
    super.key,
    required this.company,
    required this.onTap,
    this.reloadKey = 0,
    CustomerCreditLimitService? creditLimitService,
  }) : creditLimitService = creditLimitService ?? _defaultCreditLimitService;

  static final CustomerCreditLimitService _defaultCreditLimitService =
      CustomerCreditLimitService();

  final ActiveMemberCompany company;
  final ValueChanged<CustomerCreditPolicy> onTap;
  final int reloadKey;
  final CustomerCreditLimitService creditLimitService;

  @override
  State<CustomerCreditSummaryCard> createState() =>
      _CustomerCreditSummaryCardState();
}

class _CustomerCreditSummaryCardState extends State<CustomerCreditSummaryCard> {
  late Future<CustomerCreditPolicy> _creditPolicy;

  @override
  void initState() {
    super.initState();
    _loadCreditPolicy();
  }

  @override
  void didUpdateWidget(covariant CustomerCreditSummaryCard oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerCreditPolicy>(
      future: _creditPolicy,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomerMenuSection(
            title: 'Plafon Kredit',
            items: [
              CustomerMenuItem(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFF64748B),
                iconBackground: const Color(0xFFF1F5F9),
                title: 'Sisa Plafon Kredit',
                subtitle: 'Memuat informasi plafon dan TOP...',
                enabled: false,
                onTap: () {},
              ),
            ],
          );
        }

        if (!snapshot.hasData) {
          return CustomerMenuSection(
            title: 'Plafon Kredit',
            items: [
              CustomerMenuItem(
                icon: Icons.refresh_rounded,
                iconColor: AppColors.primaryColor,
                iconBackground: const Color(0xFFFEF2F2),
                title: 'Data plafon belum tersedia',
                subtitle: 'Ketuk untuk mencoba memuat kembali',
                onTap: () => setState(_loadCreditPolicy),
              ),
            ],
          );
        }

        final policy = snapshot.data!;
        return CustomerMenuSection(
          title: 'Plafon Kredit',
          items: [
            CustomerMenuItem(
              icon: policy.hasCreditLimit
                  ? Icons.account_balance_wallet_outlined
                  : Icons.credit_card_off_outlined,
              iconColor: const Color(0xFF64748B),
              iconBackground: const Color(0xFFF1F5F9),
              title: policy.hasCreditLimit
                  ? 'Sisa Plafon Kredit'
                  : 'Plafon kredit belum tersedia',
              subtitle: policy.hasCreditLimit
                  ? 'Lihat detail Limit dan TOP'
                  : 'Limit dan TOP belum ditetapkan',
              onTap: () => widget.onTap(policy),
            ),
          ],
        );
      },
    );
  }
}
