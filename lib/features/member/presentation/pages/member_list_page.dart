// lib/features/member/presentation/pages/member_list_page.dart

import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/member_registration_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../constant.dart';
import '../../../../core/shared_widgets/custom_header.dart';
// import '../../../../injection.dart';

// import '../../domain/usecases/get_member_registrations_by_user_id.dart';
import '../../domain/entities/member_registration.dart';
import '../widgets/member_registration_card.dart';

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
  // List<MemberRegistration> _allRegistrations = [];
  final List<MemberRegistration> _activeRegistrations = [];
  final Map<String, List<MemberRegistration>> _groupedByGCID = {};

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
    rBlok = context.read<MemberRegistrationCubit>()..getUserRegistrations();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // setState(() => _isLoading = true);

    // final authState = context.read<AuthSessionCubit>().state;
    // if (authState is! AuthSessionAuthenticated) {
    //   setState(() => _isLoading = false);
    //   return;
    // }

    // _userId = authState.user.id;

    // // final result = await _getMemberRegistrationsByUserId.execute();

    // result.fold(
    //   (failure) {
    //     setState(() => _isLoading = false);
    //   },
    //   (registrations) {
    //     final Map<String, List<MemberRegistration>> grouped = {};

    //     for (final reg in registrations) {
    //       final key = reg.gcid?.name ?? 'no_gcid';
    //       grouped.putIfAbsent(key, () => []);
    //       grouped[key]!.add(reg);
    //     }

    //     setState(() {
    //       _allRegistrations = registrations;
    //       _activeRegistrations = registrations
    //           .where((r) => r.status == 'approved')
    //           .toList();
    //       _groupedByGCID = grouped;
    //       _isLoading = false;
    //     });
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: const CustomHeaderAppBar(
        title: 'Member',
        subtitle: 'Daftar Perusahaan',
      ),
      body: Column(
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
    );
  }

  Widget _buildRegistrationList() {
    return BlocBuilder<MemberRegistrationCubit, MemberRegistrationState>(
      bloc: rBlok,
      builder: (context, state) {
        if (state is MemberRegistrationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MemberRegistrationUserRegistrationsLoaded) {
          if (state.registrations.isEmpty) {
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
            onRefresh: () async => rBlok.getUserRegistrations(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.registrations.length,
              itemBuilder: (context, index) {
                final registration = state.registrations[index];
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

        return SizedBox();
      },
    );
  }

  Widget _buildActiveCompaniesList() {
    if (_activeRegistrations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.business_outlined,
        title: 'Belum Ada Perusahaan Aktif',
        subtitle:
            'Anda belum memiliki perusahaan aktif.\nPengajuan yang disetujui akan muncul di sini.',
      );
    }

    final Map<String, List<MemberRegistration>> approvedGrouped = {};

    for (final entry in _groupedByGCID.entries) {
      final approved = entry.value
          .where((r) => r.status == 'approved')
          .toList();
      if (approved.isNotEmpty) {
        approvedGrouped[entry.key] = approved;
      }
    }

    if (approvedGrouped.isEmpty) {
      return _buildEmptyState(
        icon: Icons.business_outlined,
        title: 'Belum Ada Perusahaan Aktif',
        subtitle:
            'Anda belum memiliki perusahaan aktif.\nPengajuan yang disetujui akan muncul di sini.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: approvedGrouped.length,
        itemBuilder: (context, index) {
          final gcid = approvedGrouped.keys.elementAt(index);
          final regs = approvedGrouped[gcid]!;

          final gcidReg = regs.first;
          final bcidRegs = regs.skip(1).toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildHierarchicalCompanyCard(gcidReg, bcidRegs),
          );
        },
      ),
    );
  }

  Widget _buildHierarchicalCompanyCard(
    MemberRegistration gcidReg,
    List<MemberRegistration> bcidRegs,
  ) {
    final gcName = gcidReg.gcid?.name ?? gcidReg.businessName;
    // final hasChildren = bcidRegs.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _showRegistrationDetail(gcidReg),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.business,
                      color: Colors.green[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      gcName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.grayColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
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

  void _showRegistrationDetail(MemberRegistration registration) {}
}
