import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/core/utils/debouncer.dart';
import 'package:ekaplus_ekatunggal/features/article/presentation/cubit/article_cubit.dart';
import 'package:ekaplus_ekatunggal/features/article/presentation/widgets/article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final _search = TextEditingController();
  final _searchDebouncer = Debouncer();
  String? _category;

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

  Future<void> _load() => context.read<ArticleCubit>().load(
    query: _search.text,
    category: _category,
  );

  void _searchChanged(String _) => _searchDebouncer.run(_load);

  void _clearSearch() {
    _searchDebouncer.cancel();
    _search.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Artikel & Berita',
    showBackButton: true,
    backgroundColor: const Color(0xFFF6F7F9),
    body: Column(
      children: [
        CustomHeaderSearchField(
          controller: _search,
          hintText: 'Cari artikel',
          onChanged: _searchChanged,
          onClear: _clearSearch,
        ),
        BlocBuilder<ArticleCubit, ArticleState>(
          buildWhen: (previous, current) =>
              previous.categories != current.categories ||
              previous.category != current.category,
          builder: (context, state) {
            if (state.categories.isEmpty) return const SizedBox(height: 12);
            return SizedBox(
              height: 48,
              child: ListView(
                key: const PageStorageKey('article-category-filter'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _CategoryChip(
                    label: 'Semua',
                    selected: _category == null,
                    onTap: () {
                      _searchDebouncer.cancel();
                      setState(() => _category = null);
                      _load();
                    },
                  ),
                  ...state.categories.map(
                    (category) => _CategoryChip(
                      label: category,
                      selected: _category == category,
                      onTap: () {
                        _searchDebouncer.cancel();
                        setState(() => _category = category);
                        _load();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: BlocBuilder<ArticleCubit, ArticleState>(
            builder: (context, state) {
              if ((state.status == ArticleStatus.initial ||
                      state.status == ArticleStatus.loading) &&
                  state.items.isEmpty) {
                return const _LoadingList();
              }
              if (state.status == ArticleStatus.error) {
                return _StateView(
                  title: 'Artikel belum dapat dimuat',
                  message: state.message ?? 'Silakan coba kembali.',
                  onRetry: _load,
                );
              }
              if (state.items.isEmpty) {
                return _StateView(
                  title: _search.text.isEmpty
                      ? 'Belum ada artikel'
                      : 'Artikel tidak ditemukan',
                  message: _search.text.isEmpty
                      ? 'Informasi terbaru akan ditampilkan setelah tersedia.'
                      : 'Coba kata kunci atau kategori lain.',
                );
              }
              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: _load,
                child: ListView.separated(
                  key: const PageStorageKey('article-list-scroll'),
                  padding: const EdgeInsets.only(bottom: 28),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final article = state.items[index];
                    return ArticleCard(
                      article: article,
                      onTap: () => context.pushNamed(
                        'article-detail',
                        pathParameters: {'id': article.id},
                        extra: article,
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryColor.withValues(alpha: 0.12),
      side: BorderSide(
        color: selected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryColor : const Color(0xFF64748B),
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
      visualDensity: VisualDensity.compact,
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
        height: 126,
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
            Icons.article_outlined,
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
