import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:flutter/material.dart';

class ActiveMemberCard extends StatelessWidget {
  const ActiveMemberCard({
    super.key,
    required this.company,
    required this.onTap,
    this.onLongPress,
    this.onInfoTap,
    this.isActiveSelected = false,
  });

  final ActiveMemberCompany company;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onInfoTap;
  final bool isActiveSelected;

  static const Color _activeColor = Color(0xFF10B981);

  String get _companyName {
    final gcName = (company.gcName ?? '').trim();
    if (gcName.isNotEmpty) return gcName;

    final customerCompanyName = (company.customerCompanyName ?? '').trim();
    return customerCompanyName.isEmpty
        ? company.displayName
        : customerCompanyName;
  }

  String get _city {
    final value = (company.branchCity ?? '').trim();
    return value.isEmpty ? '-' : value;
  }

  String get _picName {
    final value = (company.branchOwnerName ?? '').trim();
    return value.isEmpty ? '-' : value;
  }

  String get _picPhone {
    final value = (company.branchOwnerPhone ?? '').trim();
    return value.isEmpty ? '-' : value;
  }

  String get _branchName {
    final value = (company.branchName ?? '').trim();
    return value.isEmpty ? '-' : value;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: isActiveSelected ? _activeColor : const Color(0xFFE2E8F0),
          width: isActiveSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActiveSelected
                ? _activeColor.withOpacity(.14)
                : const Color(0x0D0F172A),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: _activeColor.withOpacity(.08),
          highlightColor: _activeColor.withOpacity(.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isActiveSelected) const _SelectedCompanyHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFF059669),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _companyName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const SizedBox(
                                width: 6,
                                height: 6,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF059669),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _city,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.primaryFont,
                                    color: Color(0xFF047857),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Color(0xFFF1F5F9),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
                child: Column(
                  children: [
                    _CompanyInfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'PIC Branch',
                      value: _picName,
                    ),
                    const SizedBox(height: 7),
                    _CompanyInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'No. HP PIC',
                      value: _picPhone,
                    ),
                    const SizedBox(height: 7),
                    _CompanyInfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Cabang Terdaftar',
                      value: _branchName,
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: Color(0xFFF1F5F9),
              ),
              InkWell(
                onTap: onInfoTap ?? onTap,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(14, 9, 14, 10),
                  child: Row(
                    children: [
                      Text(
                        'Detail Info',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 17,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedCompanyHeader extends StatelessWidget {
  const _SelectedCompanyHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ActiveMemberCard._activeColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: const Row(
        children: [
          SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'PERUSAHAAN TERPILIH SAAT INI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: .15,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x40FFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              child: Text(
                'Aktif',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyInfoRow extends StatelessWidget {
  const _CompanyInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        color: Color(0xFF334155),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 7),
        Text(
          '$label:',
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Color(0xFF94A3B8),
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(child: valueWidget),
      ],
    );
  }
}
