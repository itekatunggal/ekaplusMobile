import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category_group.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  static const double _tileAspectRatio = .78;
  String? _expandedType;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const CategoryEventGetByType());
  }

  void _toggleExpand(String typeName) {
    setState(() {
      _expandedType = _expandedType == typeName ? null : typeName;
    });
  }

  void _openProductPage(CategorySimpleEntity category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductPage(),
        settings: RouteSettings(arguments: category),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    return 3;
  }

  double _getTileWidth(double width) {
    if (width >= 900) return 124;
    if (width >= 600) return 116;
    return 104;
  }

  double _getSpacing(double width) => width >= 600 ? 12 : 10;

  @override
  Widget build(BuildContext context) {
    return CustomHeaderScaffold(
      title: 'Kategori',
      backgroundColor: const Color(0xFFF6F7F9),
      // contentColor: const Color(0xFFF6F7F9),
      showBackButton: false,
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryStateLoading) {
            return _buildShimmerLoading();
          }

          if (state is CategoryStateError) {
            return _CategoryMessageCard(
              icon: Icons.cloud_off_outlined,
              title: 'Kategori gagal dimuat',
              message: state.message,
              actionLabel: 'Coba Lagi',
              onAction: () => context.read<CategoryBloc>().add(
                const CategoryEventGetByType(),
              ),
            );
          }

          if (state is CategoryStateLoadedCategoryByType) {
            if (state.allCategory.isEmpty) {
              return const _CategoryMessageCard(
                icon: Icons.category_outlined,
                title: 'Belum ada kategori',
                message: 'Kategori produk akan tampil di halaman ini.',
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth > 680
                    ? 680.0
                    : constraints.maxWidth;
                final spacing = _getSpacing(contentWidth);
                final crossAxisCount = _getCrossAxisCount(contentWidth);
                final tileWidth = _getTileWidth(contentWidth);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        children: state.allCategory.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final typeGroup = entry.value;

                          final categories = typeGroup.categories;
                          final typeName = typeGroup.typeName;
                          final isExpanded = _expandedType == typeName;

                          final accentColors = <Color>[
                            const Color(0xFFC4F4F5),
                            const Color(0xFFEFD0D3),
                            const Color(0xFFF5F0B0),
                            const Color(0xFFD3CECE),
                            const Color(0xFFCEF4BB),
                            const Color(0xFF9333EA),
                            const Color(0xFFEA580C),
                            const Color(0xFFDB2777),
                          ];

                          final accentColor =
                              accentColors[index % accentColors.length];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _CategorySection(
                              title: typeName,
                              itemCount: categories.length,
                              accentColor: accentColor,
                              isExpanded: isExpanded,
                              onToggle: () => _toggleExpand(typeName),
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeInOut,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isExpanded
                                      ? GridView.builder(
                                          key: ValueKey('expanded-$typeName'),
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: categories.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                mainAxisSpacing: spacing,
                                                crossAxisSpacing: spacing,
                                                childAspectRatio:
                                                    _tileAspectRatio,
                                              ),
                                          itemBuilder: (_, index) {
                                            final category = categories[index];

                                            return _CategoryTile(
                                              category: category,
                                              onTap: () =>
                                                  _openProductPage(category),
                                            );
                                          },
                                        )
                                      : SizedBox(
                                          key: ValueKey('collapsed-$typeName'),
                                          height: tileWidth / _tileAspectRatio,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: categories.length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(width: spacing),
                                            itemBuilder: (_, index) {
                                              final category =
                                                  categories[index];

                                              return _CategoryTile(
                                                category: category,
                                                width: tileWidth,
                                                onTap: () =>
                                                    _openProductPage(category),
                                              );
                                            },
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth > 680
            ? 680.0
            : constraints.maxWidth;
        final spacing = _getSpacing(contentWidth);
        final tileWidth = _getTileWidth(contentWidth);
        final tileHeight = tileWidth / _tileAspectRatio;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                children: List.generate(
                  3,
                  (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
                      decoration: _categorySectionDecoration,
                      child: Shimmer.fromColors(
                        baseColor: const Color(0xFFE2E8F0),
                        highlightColor: const Color(0xFFF8FAFC),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _shimmerBlock(width: 120, height: 10),
                                const Spacer(),
                                _shimmerBlock(width: 68, height: 22),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: tileHeight,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 4,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: spacing),
                                itemBuilder: (_, __) => _shimmerBlock(
                                  width: tileWidth,
                                  height: tileHeight,
                                  radius: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBlock({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.itemCount,
    required this.accentColor,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final int itemCount;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _categorySectionDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 9),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GARIS WARNA
                      Container(
                        width: 3,
                        height: 30,
                        margin: const EdgeInsets.only(top: 1, right: 8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .45,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              '$itemCount kategori produk',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onToggle,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 17,
                  ),
                  label: Text(
                    isExpanded ? 'Ringkas' : 'Lihat Semua',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, this.width, this.onTap});

  final CategorySimpleEntity category;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEFF2F6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.all(10),
                    child: CachedNetworkImage(
                      imageUrl:
                          '${ApiConfig.baseImageUrl}/${category.icon}?format=rs:fill:250:250/q:80/ext:webp',
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: const Color(0xFFE2E8F0),
                        highlightColor: const Color(0xFFF8FAFC),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 30,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 44,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryMessageCard extends StatelessWidget {
  const _CategoryMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: _categorySectionDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primaryColor, size: 26),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _categorySectionDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [
    BoxShadow(color: Color(0x0D0F172A), blurRadius: 10, offset: Offset(0, 2)),
  ],
);
