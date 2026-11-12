import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/core/utils/debouncer.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/promotion/presentation/cubit/promotion_cubit.dart';
import 'package:ekaplus_ekatunggal/features/promotion/presentation/widgets/promotion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class PromotionListPage extends StatefulWidget {
  const PromotionListPage({super.key});
  @override
  State<PromotionListPage> createState() => _PromotionListPageState();
}

class _PromotionListPageState extends State<PromotionListPage> {
  final _search = TextEditingController();
  final _searchDebouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() => context.read<PromotionCubit>().load(
    branchId: context.read<SelectedBranchCubit>().state.selectedBranchId,
    query: _search.text,
  );

  void _searchChanged(String _) => _searchDebouncer.run(_load);

  void _clearSearch() {
    _searchDebouncer.cancel();
    _search.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Promo Spesial',
    showBackButton: true,
    backgroundColor: const Color(0xFFF6F7F9),
    body: Column(
      children: [
        CustomHeaderSearchField(
          controller: _search,
          hintText: 'Cari promo',
          onChanged: _searchChanged,
          onClear: _clearSearch,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: BlocBuilder<PromotionCubit, PromotionState>(
            builder: (context, state) {
              if ((state.status == PromotionStatus.initial ||
                      state.status == PromotionStatus.loading) &&
                  state.items.isEmpty) {
                return const _LoadingList();
              }
              if (state.status == PromotionStatus.error) {
                return _StateView(
                  title: 'Promo belum dapat dimuat',
                  message: state.message ?? 'Silakan coba kembali.',
                  onRetry: _load,
                );
              }
              if (state.items.isEmpty) {
                return _StateView(
                  title: _search.text.isEmpty
                      ? 'Belum ada promo aktif'
                      : 'Promo tidak ditemukan',
                  message: _search.text.isEmpty
                      ? 'Informasi promo akan ditampilkan setelah tersedia.'
                      : 'Coba kata kunci lain.',
                );
              }
              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: _load,
                child: ListView.separated(
                  key: const PageStorageKey('promotion-list-scroll'),
                  padding: const EdgeInsets.only(bottom: 28),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return PromotionCard(
                      promotion: item,
                      onTap: () => context.pushNamed(
                        'promotion-detail',
                        pathParameters: {'id': item.id},
                        extra: item,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();
  @override
  Widget build(BuildContext context) => ListView.separated(
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) => Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 118,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

class _StateView extends StatelessWidget {
  const _StateView({required this.title, required this.message, this.onRetry});
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
          const Icon(
            Icons.local_offer_outlined,
            size: 42,
            color: Color(0xFF94A3B8),
          ),
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
            OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ],
      ),
    ),
  );
}
