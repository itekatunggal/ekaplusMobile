import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_state.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/domain/entities/sales_profile.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/domain/repositories/sales_directory_repository.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/widgets/sales_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SalesDetailResolverPage extends StatelessWidget {
  const SalesDetailResolverPage({
    super.key,
    required this.salesId,
    required this.repository,
    this.initialProfile,
  });
  final int salesId;
  final SalesDirectoryRepository repository;
  final SalesProfile? initialProfile;

  @override
  Widget build(BuildContext context) {
    if (initialProfile != null) {
      return SalesDetailPage(profile: initialProfile!);
    }
    final branchState = context.watch<SelectedBranchCubit>().state;
    if (branchState.status == SelectedBranchStatus.initial ||
        branchState.status == SelectedBranchStatus.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7F9),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }
    final branchId = salesId ~/ 100;
    if (!branchState.branches.any((branch) => branch.id == branchId)) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(title: const Text('Detail Sales')),
        body: const Center(child: Text('Profil sales tidak tersedia')),
      );
    }
    return FutureBuilder<SalesProfile?>(
      future: repository.getSalesById(salesId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F7F9),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }
        final profile = snapshot.data;
        if (profile == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F7F9),
            appBar: AppBar(title: const Text('Detail Sales')),
            body: const Center(child: Text('Profil sales tidak tersedia')),
          );
        }
        return SalesDetailPage(profile: profile);
      },
    );
  }
}

class SalesDetailPage extends StatelessWidget {
  const SalesDetailPage({super.key, required this.profile});
  final SalesProfile profile;

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri) && context.mounted) {
      AppSnackbar.show(
        context,
        message: 'Telepon tidak dapat dibuka',
        type: AppSnackbarType.error,
      );
    }
  }

  Future<void> _whatsapp(BuildContext context, String number) async {
    final normalized = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.https('wa.me', '/$normalized');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      AppSnackbar.show(
        context,
        message: 'WhatsApp tidak dapat dibuka',
        type: AppSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final branches = context.read<SelectedBranchCubit>().state.branches;
    var branchName = 'Cabang Ekatunggal';
    for (final branch in branches) {
      if (branch.id == profile.branchId) {
        branchName = branch.branchName;
        break;
      }
    }
    final hasPhone = (profile.workPhone?.trim() ?? '').isNotEmpty;
    final hasWhatsapp = (profile.workWhatsapp?.trim() ?? '').isNotEmpty;
    return CustomHeaderScaffold(
      title: 'Detail Sales',
      showBackButton: true,
      backgroundColor: const Color(0xFFF6F7F9),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _detailDecoration,
            child: Column(
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: ClipOval(child: SalesProfilePhoto(profile: profile)),
                ),
                const SizedBox(height: 14),
                if (profile.isDemo)
                  const Text(
                    'PROFIL DEMO',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .4,
                    ),
                  ),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${profile.position} • ${profile.division}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 18),
                _InfoRow(
                  icon: Icons.store_mall_directory_outlined,
                  label: 'Cabang',
                  value: branchName,
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Tentang',
                  value: profile.description,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (!hasPhone && !hasWhatsapp)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _detailDecoration,
              child: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kontak kerja belum tersedia untuk profil demo.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                if (hasWhatsapp)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () =>
                            _whatsapp(context, profile.workWhatsapp!),
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('WhatsApp'),
                      ),
                    ),
                  ),
                if (hasWhatsapp && hasPhone) const SizedBox(width: 10),
                if (hasPhone)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _call(context, profile.workPhone!),
                        icon: const Icon(Icons.phone_outlined),
                        label: const Text('Telepon'),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppColors.primaryColor, size: 20),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

const _detailDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9))),
  boxShadow: [
    BoxShadow(color: Color(0x120F172A), blurRadius: 20, offset: Offset(0, 6)),
  ],
);
