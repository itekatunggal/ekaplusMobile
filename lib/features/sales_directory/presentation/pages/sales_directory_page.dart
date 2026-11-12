import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/core/utils/debouncer.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_state.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/cubit/sales_directory_cubit.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/cubit/sales_directory_state.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/widgets/sales_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class SalesDirectoryPage extends StatefulWidget {
  const SalesDirectoryPage({super.key});

  @override
  State<SalesDirectoryPage> createState() => _SalesDirectoryPageState();
}

class _SalesDirectoryPageState extends State<SalesDirectoryPage> {
  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer();
  int? _loadedBranchId;
  String? _position;

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _syncBranch(int? branchId) {
    if (branchId == null || branchId == _loadedBranchId) return;
    _loadedBranchId = branchId;
    _searchController.clear();
    _position = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SalesDirectoryCubit>().load(branchId: branchId);
    });
  }

  void _reload({String? query, String? position}) {
    final branchId = context.read<SelectedBranchCubit>().state.selectedBranchId;
    if (branchId == null) return;
    context.read<SalesDirectoryCubit>().load(
      branchId: branchId,
      query: query ?? _searchController.text,
      position: position ?? _position,
    );
  }

  void _search(String _) => _searchDebouncer.run(_reload);

  void _clearSearch() {
    _searchDebouncer.cancel();
    _searchController.clear();
    _reload(query: '');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedBranchCubit, SelectedBranchState>(
      builder: (context, branchState) {
        _syncBranch(branchState.selectedBranchId);
        return CustomHeaderScaffold(
          title: 'Sales Ekatunggal',
          showBackButton: false,
          backgroundColor: const Color(0xFFF6F7F9),
          body: Column(
            children: [
              _Filters(
                branch: branchState.selectedBranch,
                searchController: _searchController,
                onSearch: _search,
                onClear: _clearSearch,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<SalesDirectoryCubit, SalesDirectoryState>(
                  builder: (context, salesState) {
                    return _SalesContent(
                      state: salesState,
                      selectedPosition: _position,
                      onPositionChanged: (value) {
                        setState(() => _position = value);
                        _reload(position: value);
                      },
                      onRetry: _reload,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.branch,
    required this.searchController,
    required this.onSearch,
    required this.onClear,
  });
  final Branch? branch;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: _surfaceDecoration,
    child: Column(
      children: [
        InputDecorator(
          decoration: _inputDecoration('Cabang aktif'),
          child: Row(
            children: [
              const Icon(Icons.store_mall_directory_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  branch?.branchName ?? 'Mengikuti customer aktif',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.lock_outline_rounded, size: 17),
            ],
          ),
        ),
        const SizedBox(height: 10),
        CustomHeaderSearchField(
          controller: searchController,
          hintText: 'Cari nama atau jabatan sales',
          onChanged: onSearch,
          onClear: onClear,
        ),
      ],
    ),
  );
}

class _SalesContent extends StatelessWidget {
  const _SalesContent({
    required this.state,
    required this.selectedPosition,
    required this.onPositionChanged,
    required this.onRetry,
  });
  final SalesDirectoryState state;
  final String? selectedPosition;
  final ValueChanged<String?> onPositionChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.branchId == null) {
      return const _StateView(
        icon: Icons.store_mall_directory_outlined,
        title: 'Cabang belum dipilih',
        message: 'Pilih customer aktif untuk melihat tim sales.',
      );
    }
    if (state.status == SalesDirectoryStatus.loading &&
        state.profiles.isEmpty) {
      return const _LoadingGrid();
    }
    if (state.status == SalesDirectoryStatus.error) {
      return _StateView(
        icon: Icons.cloud_off_rounded,
        title: 'Data sales belum dapat dimuat',
        message: state.message ?? 'Silakan coba kembali.',
        onRetry: onRetry,
      );
    }
    return Column(
      children: [
        if (state.availablePositions.isNotEmpty)
          SizedBox(
            height: 36,
            child: ListView(
              key: const PageStorageKey('sales-position-filter'),
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: selectedPosition == null,
                  onSelected: (_) => onPositionChanged(null),
                ),
                const SizedBox(width: 8),
                ...state.availablePositions.map(
                  (position) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(position),
                      selected: selectedPosition == position,
                      onSelected: (_) => onPositionChanged(position),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (state.availablePositions.isNotEmpty) const SizedBox(height: 10),
        Expanded(
          child: state.profiles.isEmpty
              ? const _StateView(
                  icon: Icons.person_search_outlined,
                  title: 'Belum ada data sales',
                  message: 'Belum ada data sales untuk cabang ini.',
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 700 ? 3 : 2;
                    final textScale = MediaQuery.textScalerOf(context).scale(1);
                    final scaleAdjustment = textScale
                        .clamp(1.0, 1.5)
                        .toDouble();
                    return GridView.builder(
                      key: const PageStorageKey('sales-directory-grid'),
                      padding: const EdgeInsets.only(bottom: 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: .82 / scaleAdjustment,
                      ),
                      itemCount: state.profiles.length,
                      itemBuilder: (context, index) {
                        final profile = state.profiles[index];
                        return SalesProfileCard(
                          profile: profile,
                          onTap: () => context.pushNamed(
                            'sales-detail',
                            pathParameters: {'salesId': '${profile.id}'},
                            extra: profile,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();
  @override
  Widget build(BuildContext context) => GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: .82,
    ),
    itemCount: 6,
    itemBuilder: (_, _) => Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(decoration: _surfaceDecoration),
    ),
  );
}

class _StateView extends StatelessWidget {
  const _StateView({
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
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF94A3B8)),
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
    ),
  );
}

InputDecoration _inputDecoration(String label) => InputDecoration(
  labelText: label,
  filled: true,
  fillColor: const Color(0xFFF8FAFC),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
);

const _surfaceDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9))),
  boxShadow: [
    BoxShadow(color: Color(0x120F172A), blurRadius: 20, offset: Offset(0, 6)),
  ],
);
