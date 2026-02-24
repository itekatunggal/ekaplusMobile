// lib/features/member/presentation/pages/member_list_page.dart

import 'dart:convert';

import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/member_registration_cubit.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../constant.dart';
import '../../../../core/shared_widgets/custom_header.dart';
// import '../../../../injection.dart';

// import '../../domain/usecases/get_member_registrations_by_user_id.dart';
import '../../domain/entities/member_registration.dart';
import '../widgets/active_company_detail_dialog.dart';
import '../widgets/active_member_card.dart';
import '../widgets/member_registration_card.dart';
import '../widgets/member_confirmation_dialog.dart';

class MemberListPage extends StatefulWidget {
  final int initialTabIndex;

  const MemberListPage({super.key, this.initialTabIndex = 0});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // final GetMemberRegistrationsByUserId _getMemberRegistrationsByUserId =
  //     myinjection<GetMemberRegistrationsByUserId>();

  late MemberRegistrationCubit rBlok;
  List<MemberRegistration> _userRegistrations = [];
  List<ActiveMemberCompany> _activeCompanies = [];
  bool _isRegistrationsLoading = true;
  bool _isActiveCompaniesLoading = true;
  String? _registrationsError;
  String? _activeCompaniesError;

  // bool _isLoading = false;
  // int? _userId;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    rBlok = context.read<MemberRegistrationCubit>();
    rBlok.getUserRegistrations();
    rBlok.getActiveMemberCompanies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    rBlok.getUserRegistrations();
    rBlok.getActiveMemberCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomHeaderAppBar(
        title: 'Member',
        subtitle: 'Daftar Perusahaan',
        onBackPressed: () => context.goNamed('account'),
      ),
      body: BlocListener<MemberRegistrationCubit, MemberRegistrationState>(
        bloc: rBlok,
        listener: (context, state) {
          if (state is MemberRegistrationLoading) {
            setState(() {
              _isRegistrationsLoading = true;
              _registrationsError = null;
            });
          } else if (state is MemberRegistrationUserRegistrationsLoaded) {
            setState(() {
              _userRegistrations = state.registrations;
              _isRegistrationsLoading = false;
              _registrationsError = null;
            });
          } else if (state is MemberRegistrationActiveCompaniesLoading) {
            setState(() {
              _isActiveCompaniesLoading = true;
              _activeCompaniesError = null;
            });
          } else if (state is MemberRegistrationActiveCompaniesLoaded) {
            setState(() {
              _activeCompanies = state.companies;
              _isActiveCompaniesLoading = false;
              _activeCompaniesError = null;
            });
          } else if (state is MemberRegistrationActiveCompaniesError) {
            setState(() {
              _isActiveCompaniesLoading = false;
              _activeCompaniesError = state.message;
            });
          } else if (state is MemberRegistrationError) {
            setState(() {
              _isRegistrationsLoading = false;
              _registrationsError = state.message;
            });
          }
        },
        child: Column(
          children: [
            Container(
              color: AppColors.whiteColor,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.grayColor,
                labelStyle: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                indicatorColor: AppColors.primaryColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Daftar Pengajuan'),
                  Tab(text: 'Perusahaan Aktif'),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: const Color(0xFFE0E0E0),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildRegistrationList(), _buildActiveCompaniesList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationList() {
    if (_isRegistrationsLoading && _userRegistrations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_registrationsError != null && _userRegistrations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Gagal Memuat Pengajuan',
        subtitle: _registrationsError!,
        buttonText: 'Muat Ulang',
        onPressed: () => rBlok.getUserRegistrations(),
      );
    }

    if (_userRegistrations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.description_outlined,
        title: 'Belum Ada Pengajuan',
        subtitle:
            'Anda belum memiliki pengajuan member.\nSilakan daftar untuk menjadi member.',
        buttonText: 'Daftar Member',
        onPressed: () {
          context.pushNamed('memberRegistration');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshAll(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userRegistrations.length,
        itemBuilder: (context, index) {
          final registration = _userRegistrations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MemberRegistrationCard(
              registration: registration,
              onTap: () => _showRegistrationDetail(registration),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveCompaniesList() {
    if (_isActiveCompaniesLoading && _activeCompanies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeCompaniesError != null && _activeCompanies.isEmpty) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Gagal Memuat Perusahaan Aktif',
        subtitle: _activeCompaniesError!,
        buttonText: 'Muat Ulang',
        onPressed: () => rBlok.getActiveMemberCompanies(),
      );
    }

    if (_activeCompanies.isEmpty) {
      return _buildEmptyState(
        icon: Icons.business_outlined,
        title: 'Belum Ada Perusahaan Aktif',
        subtitle:
            'Anda belum memiliki perusahaan aktif.\nPengajuan yang disetujui akan muncul di sini.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshAll(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeCompanies.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ActiveMemberCard(
              company: _activeCompanies[index],
              onTap: () => _showActiveCompanyDetail(_activeCompanies[index]),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildBCIDItem(MemberRegistration bcidReg) {
  //   final bcName = bcidReg.bcid?.name ?? bcidReg.businessName;

  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 8),
  //     child: InkWell(
  //       onTap: () => _showRegistrationDetail(bcidReg),
  //       borderRadius: BorderRadius.circular(8),
  //       child: Container(
  //         padding: const EdgeInsets.all(10),
  //         decoration: BoxDecoration(
  //           color: Colors.blue[50],
  //           borderRadius: BorderRadius.circular(8),
  //           border: Border.all(color: Colors.blue[200]!),
  //         ),
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.subdirectory_arrow_right,
  //               size: 16,
  //               color: Colors.blue[700],
  //             ),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 bcName,
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //                 style: TextStyle(
  //                   fontFamily: AppFonts.primaryFont,
  //                   fontSize: 13,
  //                   fontWeight: FontWeight.w600,
  //                   color: AppColors.blackColor,
  //                 ),
  //               ),
  //             ),
  //             Icon(Icons.chevron_right, color: AppColors.grayColor, size: 16),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          Icon(icon, size: 80, color: AppColors.grayColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 13,
              color: AppColors.grayColor,
              height: 1.5,
            ),
          ),
          const Spacer(),
          if (buttonText != null && onPressed != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showRegistrationDetail(MemberRegistration registration) async {
    final status = registration.status.toLowerCase();
    final shippingAddresses = await _loadShippingAddresses(registration.id);
    if (!mounted) return;
    final formData = _toConfirmationFormData(
      registration,
      shippingAddresses: shippingAddresses,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MemberConfirmationDialog(
        formData: formData,
        title: 'Detail Pengajuan',
        description:
            'Berikut adalah detail pengajuan member Anda yang sudah tersimpan.',
        primaryButtonText: 'Selesai',
        secondaryButtonText: status == 'draft' ? 'Edit Pengajuan' : null,
        showSectionEditAction: false,
        showPrimarySendIcon: false,
        onClose: () => Navigator.of(dialogContext).pop(),
        onConfirm: () => Navigator.of(dialogContext).pop(),
        onEdit: status == 'draft'
            ? () {
                Navigator.of(dialogContext).pop();
                context.pushNamed(
                  'memberRegistration',
                  extra: {'registration': registration},
                );
              }
            : null,
      ),
    );
  }

  Future<void> _showActiveCompanyDetail(ActiveMemberCompany company) async {
    final shippingAddresses = company.customerRegisterId == null
        ? const <Map<String, dynamic>>[]
        : await _loadShippingAddresses(company.customerRegisterId!);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ActiveCompanyDetailDialog(
        company: company,
        shippingAddresses: shippingAddresses,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  Map<String, dynamic> _toConfirmationFormData(
    MemberRegistration registration, {
    List<Map<String, dynamic>> shippingAddresses = const [],
  }) {
    final dob = registration.user.dateOfBirth;
    return {
      'owner_full_name': registration.user.fullName,
      'owner_email': registration.user.email,
      'owner_phone': registration.user.phone,
      'owner_place_of_birth': registration.user.placeOfBirth,
      'owner_date_of_birth': dob == null
          ? ''
          : '${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}',
      'company_type': registration.entity,
      'company_title': registration.companyTitle,
      'company_name': registration.businessName,
      'product_need': registration.productNeed,
      'branch_id': registration.branch.id,
      'branch_name': registration.branch.branchName,
      'branch_area': registration.branch.area ?? registration.branch.city,
      'company_address': registration.address,
      'company_province': registration.province,
      'company_city': registration.city,
      'company_district': registration.district,
      'company_postal_code': registration.postalCode,
      'customer_shipping_address': shippingAddresses,
    };
  }

  Future<List<Map<String, dynamic>>> _loadShippingAddresses(int parentId) async {
    try {
      final token = await SessionManager.getToken();
      final spec = {
        'fields': ['*'],
        'filters': [
          ['parent_id', '=', parentId.toString()],
          ['parent_type', '=', 'customer_register'],
        ],
        'order_by': [
          ['idx', 'asc'],
        ],
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/customer_register_address'
        '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
      );

      final response = await http.get(
        uri,
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) return const [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];
      if (data is! List) return const [];

      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
