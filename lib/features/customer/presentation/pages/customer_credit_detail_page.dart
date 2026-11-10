import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/customer/data/models/customer_credit_policy.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerCreditDetailPage extends StatelessWidget {
  const CustomerCreditDetailPage({
    super.key,
    required this.company,
    required this.policy,
  });

  final ActiveMemberCompany company;
  final CustomerCreditPolicy policy;

  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  String _money(double value) => _rupiah.format(value);

  String get _companyName {
    final name = (company.gcName ?? company.customerCompanyName ?? '').trim();
    return name.isEmpty ? company.displayName : name;
  }

  Color _usageColor(double ratio) {
    if (ratio >= .9) return AppColors.primaryColor;
    if (ratio >= .7) return const Color(0xFFD97706);
    return const Color(0xFF059669);
  }

  @override
  Widget build(BuildContext context) {
    final ratio = policy.usedRatio.clamp(0.0, 1.0).toDouble();
    final usageColor = _usageColor(ratio);
    final percentage = (ratio * 100).toStringAsFixed(1);
    final availablePercentage = ((1 - ratio) * 100).toStringAsFixed(1);
    final ownerName = (policy.limitOwnerName ?? '').trim();

    return CustomHeaderScaffold(
      title: 'Detail Plafon Kredit',
      subtitle: _companyName,
      showBackButton: true,
      backgroundColor: const Color(0xFFF6F7F9),
      headerHeight: 160,
      contentTop: 124,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 12),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              _OverviewCard(
                remainingCredit: _money(policy.remainingCredit),
                ratio: ratio,
                percentage: percentage,
                availablePercentage: availablePercentage,
                usageColor: usageColor,
                isAvailable: policy.hasCreditLimit,
              ),
              const SizedBox(height: 16),
              _DetailCard(
                title: 'Ringkasan Plafon',
                children: [
                  _DetailRow(
                    label: 'Total Plafon Kredit',
                    value: _money(policy.finalCreditLimit),
                    indicatorColor: const Color(0xFFCBD5E1),
                  ),
                  _DetailRow(
                    label: 'Plafon Terpakai',
                    value: _money(policy.totalLimitOutstanding),
                    valueColor: usageColor,
                    indicatorColor: usageColor,
                  ),
                  _DetailRow(
                    label: 'Sisa Plafon Kredit',
                    value: _money(policy.remainingCredit),
                    indicatorColor: AppColors.primaryColor,
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailCard(
                title: 'Informasi Ketentuan',
                children: [
                  _InformationRow(
                    icon: Icons.calendar_today_outlined,
                    iconColor: const Color(0xFFD97706),
                    iconBackground: const Color(0xFFFFFBEB),
                    label: 'TOP (Term of Payment)',
                    value: policy.paymentTermDays == null
                        ? 'Belum ditetapkan'
                        : '${policy.paymentTermDays} Hari',
                    valueAsBadge: true,
                  ),
                  _InformationRow(
                    icon: Icons.verified_user_outlined,
                    iconColor: const Color(0xFF2563EB),
                    iconBackground: const Color(0xFFEFF6FF),
                    label: 'Level Limit',
                    value: policy.creditLimitLevelLabel,
                  ),
                  _InformationRow(
                    icon: Icons.apartment_rounded,
                    iconColor: AppColors.primaryColor,
                    iconBackground: const Color(0xFFFFF1F2),
                    label: 'Entitas Limit',
                    value: ownerName.isEmpty
                        ? policy.limitOwnerFallback
                        : ownerName,
                    showDivider: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.remainingCredit,
    required this.ratio,
    required this.percentage,
    required this.availablePercentage,
    required this.usageColor,
    required this.isAvailable,
  });

  final String remainingCredit;
  final double ratio;
  final String percentage;
  final String availablePercentage;
  final Color usageColor;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(18)),
      border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9))),
      boxShadow: [
        BoxShadow(
          color: Color(0x120F172A),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'SISA PLAFON KREDIT',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: Color(0xFF64748B),
                  fontSize: 10.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .25,
                ),
              ),
            ),
            _StatusBadge(isAvailable: isAvailable),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            remainingCredit,
            style: const TextStyle(
              fontFamily: AppFonts.primaryFont,
              color: Color(0xFF0F172A),
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -.3,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          label: 'Pemakaian plafon kredit',
          value: '$percentage persen terpakai',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFFF1F5F9)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: usageColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _UsageBreakdown(
          percentage: percentage,
          availablePercentage: availablePercentage,
          usageColor: usageColor,
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final foreground = isAvailable
        ? const Color(0xFF059669)
        : const Color(0xFF64748B);
    final background = isAvailable
        ? const Color(0xFFECFDF5)
        : const Color(0xFFF1F5F9);
    final border = isAvailable
        ? const Color(0xFFA7F3D0)
        : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isAvailable ? 'Tersedia' : 'Belum Tersedia',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              color: foreground,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageBreakdown extends StatelessWidget {
  const _UsageBreakdown({
    required this.percentage,
    required this.availablePercentage,
    required this.usageColor,
  });

  final String percentage;
  final String availablePercentage;
  final Color usageColor;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final usedWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, color: usageColor, size: 14),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            '$percentage% plafon telah terpakai',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              color: usageColor,
              fontSize: 10,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
    final availableWidget = Text(
      '$availablePercentage% Tersedia',
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        color: Color(0xFF94A3B8),
        fontSize: 9.5,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300 || textScale > 1.2) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerLeft, child: usedWidget),
              const SizedBox(height: 5),
              Align(alignment: Alignment.centerRight, child: availableWidget),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: usedWidget),
            const SizedBox(width: 8),
            availableWidget,
          ],
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(18)),
      border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9))),
      boxShadow: [
        BoxShadow(
          color: Color(0x120F172A),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Color(0xFF94A3B8),
            fontSize: 10,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        ...children,
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.indicatorColor,
    this.valueColor = const Color(0xFF0F172A),
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Color indicatorColor;
  final Color valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackContent = constraints.maxWidth < 270 || textScale > 1.2;
        final labelWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: Color(0xFF475569),
                  fontSize: 10.5,
                  height: 1.35,
                ),
              ),
            ),
          ],
        );
        final valueWidget = Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: valueColor,
            fontSize: 11,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: stackContent
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        labelWidget,
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: valueWidget,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: labelWidget),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: valueWidget,
                          ),
                        ),
                      ],
                    ),
            ),
            if (showDivider) const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ],
        );
      },
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    this.valueAsBadge = false,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final bool valueAsBadge;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackValue = constraints.maxWidth < 280 || textScale > 1.2;
        final valueWidget = Container(
          padding: valueAsBadge
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
              : EdgeInsets.zero,
          decoration: valueAsBadge
              ? BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(7),
                )
              : null,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: AppFonts.primaryFont,
              color: Color(0xFF0F172A),
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, color: iconColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: stackValue
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InformationLabel(label: label),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: valueWidget,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _InformationLabel(label: label)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: valueWidget,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            if (showDivider) const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ],
        );
      },
    );
  }
}

class _InformationLabel extends StatelessWidget {
  const _InformationLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontFamily: AppFonts.primaryFont,
      color: Color(0xFF475569),
      fontSize: 10.5,
      height: 1.35,
    ),
  );
}
