import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class BranchDirectoryPage extends StatefulWidget {
  const BranchDirectoryPage({super.key});

  @override
  State<BranchDirectoryPage> createState() => _BranchDirectoryPageState();
}

class _BranchDirectoryPageState extends State<BranchDirectoryPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _city;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Branch> _filtered(List<Branch> branches) {
    final query = _query.trim().toLowerCase();
    return branches
        .where((branch) {
          final matchesCity =
              _city == null || (branch.city?.trim() ?? '') == _city;
          final searchable = [
            branch.branchName,
            branch.city ?? '',
            branch.area ?? '',
            branch.address ?? '',
          ].join(' ').toLowerCase();
          return matchesCity && (query.isEmpty || searchable.contains(query));
        })
        .toList(growable: false);
  }

  Future<void> _openMaps(Branch branch) async {
    final coordinates = _coordinates(branch);
    final query = coordinates == null
        ? [branch.branchName, branch.address, branch.city]
              .whereType<String>()
              .where((text) => text.trim().isNotEmpty)
              .join(', ')
        : '${coordinates.$1},${coordinates.$2}';
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      AppSnackbar.show(
        context,
        message: 'Maps tidak dapat dibuka',
        type: AppSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomHeaderScaffold(
      title: 'Daftar Cabang Ekatunggal',
      showBackButton: false,
      backgroundColor: const Color(0xFFF6F7F9),
      body: BlocBuilder<SelectedBranchCubit, SelectedBranchState>(
        builder: (context, state) {
          final cities =
              state.branches
                  .map((branch) => branch.city?.trim() ?? '')
                  .where((city) => city.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
          if (_city != null && !cities.contains(_city)) _city = null;
          final rows = _filtered(state.branches);
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () =>
                context.read<SelectedBranchCubit>().load(force: true),
            child: CustomScrollView(
              key: const PageStorageKey('branch-directory-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _SearchAndFilter(
                    controller: _searchController,
                    cities: cities,
                    selectedCity: _city,
                    onSearch: (value) => setState(() => _query = value),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    onCityChanged: (value) => setState(() => _city = value),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                if (state.branches.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${rows.length} cabang ditemukan',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ),
                if (state.status == SelectedBranchStatus.loading &&
                    state.branches.isEmpty)
                  const SliverToBoxAdapter(child: _BranchLoading())
                else if (state.status == SelectedBranchStatus.error &&
                    state.branches.isEmpty)
                  SliverToBoxAdapter(
                    child: _BranchStateView(
                      icon: Icons.cloud_off_rounded,
                      title: 'Cabang belum dapat dimuat',
                      message: state.message ?? 'Silakan coba kembali.',
                      onRetry: () =>
                          context.read<SelectedBranchCubit>().load(force: true),
                    ),
                  )
                else if (state.branches.isEmpty)
                  const SliverToBoxAdapter(
                    child: _BranchStateView(
                      icon: Icons.store_mall_directory_outlined,
                      title: 'Belum ada cabang',
                      message: 'Data cabang aktif belum tersedia.',
                    ),
                  )
                else if (rows.isEmpty)
                  const SliverToBoxAdapter(
                    child: _BranchStateView(
                      icon: Icons.search_off_rounded,
                      title: 'Cabang tidak ditemukan',
                      message: 'Coba kata kunci atau kota lain.',
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final branch = rows[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _BranchCard(
                          branch: branch,
                          selected: branch.id == state.selectedBranchId,
                          onDetail: () => context.pushNamed(
                            'branch-detail',
                            pathParameters: {'branchId': '${branch.id}'},
                            extra: branch,
                          ),
                          onMaps: () => _openMaps(branch),
                        ),
                      );
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
          );
        },
      ),
    );
  }

  (double, double)? _coordinates(Branch branch) {
    final lat = double.tryParse(branch.lat?.trim() ?? '');
    final lng = double.tryParse(branch.lng?.trim() ?? '');
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return (lat, lng);
  }
}

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({
    required this.controller,
    required this.cities,
    required this.selectedCity,
    required this.onSearch,
    required this.onClear,
    required this.onCityChanged,
  });
  final TextEditingController controller;
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final ValueChanged<String?> onCityChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: _surfaceDecoration,
    child: Column(
      children: [
        CustomHeaderSearchField(
          controller: controller,
          hintText: 'Cari nama cabang atau kota',
          onChanged: onSearch,
          onClear: onClear,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(
          initialValue: selectedCity,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Filter kota',
            prefixIcon: const Icon(Icons.location_city_outlined, size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Semua kota')),
            ...cities.map(
              (city) => DropdownMenuItem(value: city, child: Text(city)),
            ),
          ],
          onChanged: onCityChanged,
        ),
      ],
    ),
  );
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.selected,
    required this.onDetail,
    required this.onMaps,
  });
  final Branch branch;
  final bool selected;
  final VoidCallback onDetail;
  final VoidCallback onMaps;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: _surfaceDecoration.copyWith(
      border: Border.all(
        color: selected ? AppColors.primaryColor : const Color(0xFFF1F5F9),
        width: selected ? 1.4 : 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   width: 48,
            //   height: 48,
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFFFF1F2),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: const Icon(
            //     Icons.store_mall_directory_rounded,
            //     color: AppColors.primaryColor,
            //   ),
            // ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          branch.branchName,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                    ],
                  ),
                  if ((branch.city ?? '').trim().isNotEmpty)
                    Text(
                      branch.city!.trim(),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                  if ((branch.address ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      branch.address!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 10,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: double.infinity,
            height: 155,
            child: CachedNetworkImage(
              imageUrl: _photoUrl(branch),
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  const _BranchPhotoFallback(showProgress: true),
              errorWidget: (_, _, _) => const _BranchPhotoFallback(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDetail,
                icon: const Icon(Icons.info_outline_rounded, size: 17),
                label: const Text('Lihat Detail'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: onMaps,
                icon: const Icon(Icons.map_outlined, size: 17),
                label: const Text('Lihat Lokasi'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  static String _photoUrl(Branch branch) {
    final seedSource = branch.city?.trim().isNotEmpty == true
        ? branch.city!
        : branch.branchName;
    final seed = seedSource.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    return Uri.https(
      'via.placeholder.com',
      '/photo/office-building/800x450.webp',
      {'seed': seed.isEmpty ? '${branch.id}' : '$seed-${branch.id}'},
    ).toString();
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
              size: 48,
            ),
    ),
  );
}

class _BranchLoading extends StatelessWidget {
  const _BranchLoading();
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      4,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(height: 330, decoration: _surfaceDecoration),
        ),
      ),
    ),
  );
}

class _BranchStateView extends StatelessWidget {
  const _BranchStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: _surfaceDecoration,
    child: Column(
      children: [
        Icon(icon, size: 34, color: const Color(0xFF94A3B8)),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ],
    ),
  );
}

const _surfaceDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9))),
  boxShadow: [
    BoxShadow(color: Color(0x120F172A), blurRadius: 20, offset: Offset(0, 6)),
  ],
);
