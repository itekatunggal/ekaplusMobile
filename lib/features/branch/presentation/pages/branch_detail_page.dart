import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_state.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/utils/branch_image_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class BranchDetailResolverPage extends StatelessWidget {
  const BranchDetailResolverPage({
    super.key,
    required this.branchId,
    this.initialBranch,
  });

  final int branchId;
  final Branch? initialBranch;

  @override
  Widget build(BuildContext context) {
    if (initialBranch != null) {
      return BranchDetailPage(branch: initialBranch!);
    }
    return BlocBuilder<SelectedBranchCubit, SelectedBranchState>(
      builder: (context, state) {
        Branch? branch;
        for (final item in state.branches) {
          if (item.id == branchId) {
            branch = item;
            break;
          }
        }
        if (branch != null) {
          return BranchDetailPage(branch: branch);
        }
        if (state.status == SelectedBranchStatus.initial ||
            state.status == SelectedBranchStatus.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F7F9),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7F9),
          appBar: AppBar(title: const Text('Detail Cabang')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.store_mall_directory_outlined,
                    size: 42,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 12),
                  const Text('Cabang tidak tersedia'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<SelectedBranchCubit>().load(force: true),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BranchDetailPage extends StatelessWidget {
  const BranchDetailPage({super.key, required this.branch});

  final Branch branch;

  Future<void> _openMaps(BuildContext context) async {
    final coordinates = _coordinates;
    if (coordinates == null) return;
    final (lat, lng) = coordinates;
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$lat,$lng',
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      AppSnackbar.show(
        context,
        message: 'Maps tidak dapat dibuka',
        type: AppSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMaps = _coordinates != null;
    return CustomHeaderScaffold(
      title: 'Detail Cabang',
      // subtitle: branch.branchName,
      showBackButton: true,
      backgroundColor: const Color(0xFFF6F7F9),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: double.infinity,
              height: 190,
              child: CachedNetworkImage(
                imageUrl: branchImageUrl(branch),
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    const _BranchPhotoFallback(showProgress: true),
                errorWidget: (_, _, _) => const _BranchPhotoFallback(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _detailDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.branchName,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _InfoRow(
                  icon: Icons.location_city_outlined,
                  label: 'Kota',
                  value: (branch.city ?? '').trim(),
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.place_outlined,
                  label: 'Alamat',
                  value: (branch.address ?? '').trim(),
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Telepon',
                  value: (branch.phone ?? '').trim(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (hasMaps)
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _openMaps(context),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Lihat di Maps'),
              ),
            ),
        ],
      ),
    );
  }

  (double, double)? get _coordinates {
    final lat = double.tryParse(branch.lat?.trim() ?? '');
    final lng = double.tryParse(branch.lng?.trim() ?? '');
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return (lat, lng);
  }
}

class _BranchPhotoFallback extends StatelessWidget {
  const _BranchPhotoFallback({this.showProgress = false});
  final bool showProgress;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFFFF1F2),
    child: Center(
      child: showProgress
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            )
          : const Icon(
              Icons.store_mall_directory_rounded,
              color: AppColors.primaryColor,
              size: 52,
            ),
    ),
  );
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
            const SizedBox(height: 3),
            Text(
              value.isEmpty ? 'Belum tersedia' : value,
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
