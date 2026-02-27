import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../constant.dart';
import '../../../../injection.dart';
import '../../domain/entities/active_member_company.dart';
import '../../domain/usecases/get_active_member_companies_by_user_id.dart';
import '../enums/member_registration_intent.dart';

class AddBCIDPage extends StatefulWidget {
  const AddBCIDPage({super.key});

  @override
  State<AddBCIDPage> createState() => _AddBCIDPageState();
}

class _AddBCIDPageState extends State<AddBCIDPage> {
  final GetActiveMemberCompaniesByUserId _getActiveMemberCompaniesByUserId =
      myinjection<GetActiveMemberCompaniesByUserId>();

  bool _isLoading = true;
  List<ActiveMemberCompany> _parentGcOptions = [];
  ActiveMemberCompany? _selectedParent;

  @override
  void initState() {
    super.initState();
    _loadGcOptions();
  }

  Future<void> _loadGcOptions() async {
    final result = await _getActiveMemberCompaniesByUserId.execute();
    if (!mounted) return;

    result.fold(
      (_) => setState(() {
        _parentGcOptions = [];
        _isLoading = false;
      }),
      (companies) {
        final byGcid = <int, ActiveMemberCompany>{};
        for (final c in companies) {
          if (!c.memberIsOwner) continue;
          final id = c.gcidId;
          if (id == null || id <= 0) continue;
          byGcid.putIfAbsent(id, () => c);
        }
        final rows = byGcid.values.toList()
          ..sort((a, b) => (a.gcName ?? '').compareTo(b.gcName ?? ''));
        setState(() {
          _parentGcOptions = rows;
          _isLoading = false;
        });
      },
    );
  }

  void _continueToForm() {
    if (_selectedParent == null) {
      AppSnackbar.showRaw(context, 
        const SnackBar(
          content: Text('Pilih Group Customer terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.pushNamed(
      'memberRegistration',
      extra: {
        'intent': MemberRegistrationIntent
            .addBranchToExistingGroupCustomer
            .routeValue,
        'selectedGcidId': _selectedParent!.gcidId,
        'selectedGcName': _selectedParent!.gcName,
        'selectedActiveCompany': _selectedParent,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cabang Perusahaan',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Pilih Group Customer yang dimiliki',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _parentGcOptions.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.info,
                            size: 16,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pilih Group Customer (GCID) yang sudah Anda miliki. Form Hubungkan Usaha akan terisi otomatis setelah pemilihan.',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: 12,
                              color: const Color(0xFF1D4ED8),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pilih Group Customer',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: DropdownButtonFormField<ActiveMemberCompany>(
                      value: _selectedParent,
                      isExpanded: true,
                      icon: const Icon(Icons.expand_more_rounded),
                      decoration: InputDecoration(
                        labelText: 'GCID (Nama Group Customer) *',
                        labelStyle: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 8,
                        ),
                      ),
                      items: _parentGcOptions.map((item) {
                        final name = item.gcName ?? item.displayName;
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedParent = value),
                    ),
                  ),
                  if (_selectedParent != null) ...[
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'DETAIL PILIHAN',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kvStack(
                            'Group Customer',
                            _selectedParent!.gcName ?? '-',
                            icon: Icons.maps_home_work,
                          ),
                          const Divider(height: 20),
                          _kvStack(
                            'Branch Customer',
                            _selectedParent!.displayName,
                            icon: Icons.location_on,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _continueToForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Lanjut Isi Form Cabang',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business_outlined, size: 64, color: Colors.orange),
            const SizedBox(height: 12),
            Text(
              'Belum Ada Group Customer',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda belum memiliki Group Customer yang bisa dipilih untuk menambah cabang. Tambahkan perusahaan baru terlebih dahulu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 13,
                color: AppColors.grayColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pushNamed(
                'memberRegistration',
                extra: {
                  'intent': MemberRegistrationIntent.newCompany.routeValue,
                },
              ),
              child: const Text('Tambah Perusahaan Baru'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kvStack(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        if (icon == null)
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
            ),
          )
        else
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
