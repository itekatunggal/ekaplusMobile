import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category_group.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class FilterProduct extends StatefulWidget {
  final List<int> selectedTypeIds;
  final List<int> selectedCategoryIds;
  final Function(List<int> typeIds, List<int> categoryIds) onApplyFilter;
  final int? lockedTypeId;

  const FilterProduct({
    super.key,
    this.selectedTypeIds = const [],
    this.selectedCategoryIds = const [],
    this.lockedTypeId,
    required this.onApplyFilter,
  });

  @override
  State<FilterProduct> createState() => _FilterProductState();
}

class _FilterProductState extends State<FilterProduct> {
  List<int> _selectedTypeIds = [];
  List<int> _selectedCategoryIds = [];

  bool _isTypeExpanded = true;
  bool _isKategoriExpanded = true;

  final ScrollController _scrollController = ScrollController();

  // Simpan data category groups untuk digunakan di _toggleType
  List<CategoryGroupEntity> _categoryGroups = [];

  @override
  void initState() {
    super.initState();
    _selectedTypeIds = List.from(widget.selectedTypeIds);
    _selectedCategoryIds = List.from(widget.selectedCategoryIds);
    context.read<TypeBloc>().add(TypeEventGetAllTypes(0));
    context.read<CategoryBloc>().add(CategoryEventGetByType());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleType(int typeId) {
    if (widget.lockedTypeId != null) return;

    setState(() {
      if (_selectedTypeIds.contains(typeId)) {
        // ❌ UNCHECK type - hapus type dan semua kategorinya
        _selectedTypeIds.remove(typeId);

        // Cari dan hapus semua kategori yang belongs to type ini
        for (var group in _categoryGroups) {
          if (group.id == typeId) {
            // Hapus semua kategori dari group ini
            for (var category in group.categories) {
              _selectedCategoryIds.remove(category.id);
            }
            break;
          }
        }
      } else {
        // ✅ CHECK type - tambahkan type dan semua kategorinya
        _selectedTypeIds.add(typeId);

        // Cari dan tambahkan semua kategori yang belongs to type ini
        for (var group in _categoryGroups) {
          if (group.id == typeId) {
            // Tambahkan semua kategori dari group ini
            for (var category in group.categories) {
              if (!_selectedCategoryIds.contains(category.id)) {
                _selectedCategoryIds.add(category.id);
              }
            }
            break;
          }
        }
      }
    });
  }

  void _toggleCategory(int categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _resetFilter() {
    setState(() {
      if (widget.lockedTypeId != null) {
        _selectedTypeIds = [widget.lockedTypeId!];
      } else {
        _selectedTypeIds.clear();
      }
      _selectedCategoryIds.clear();
    });
  }

  void _applyFilter() {
    widget.onApplyFilter(_selectedTypeIds, _selectedCategoryIds);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is OverscrollNotification) {
                  if (notification.overscroll < 0) {}
                }
                return false;
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag Handle Indicator
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 5,
                        right: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter   ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(
                          top: 5,
                          left: 20,
                          right: 20,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type Section
                            BlocBuilder<TypeBloc, TypeState>(
                              builder: (context, state) {
                                if (state is TypeStateLoading) {
                                  return _buildExpandableSection(
                                    title: 'Type',
                                    isExpanded: _isTypeExpanded,
                                    onToggle: () {
                                      setState(() {
                                        _isTypeExpanded = !_isTypeExpanded;
                                      });
                                    },
                                    child: _buildTypeShimmer(),
                                  );
                                }

                                if (state is TypeStateError) {
                                  return _buildExpandableSection(
                                    title: 'Type',
                                    isExpanded: _isTypeExpanded,
                                    onToggle: () {
                                      setState(() {
                                        _isTypeExpanded = !_isTypeExpanded;
                                      });
                                    },
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              state.message,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextButton(
                                              onPressed: () {
                                                context.read<TypeBloc>().add(
                                                  TypeEventGetAllTypes(0),
                                                );
                                              },
                                              child: const Text('Coba Lagi'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                if (state is TypeStateLoadedAllType) {
                                  return _buildExpandableSection(
                                    title: 'Type',
                                    isExpanded: _isTypeExpanded,
                                    onToggle: () {
                                      setState(() {
                                        _isTypeExpanded = !_isTypeExpanded;
                                      });
                                    },
                                    child: Column(
                                      children: List.generate(
                                        state.allType.length,
                                        (index) {
                                          final type = state.allType[index];
                                          final isSelected = _selectedTypeIds
                                              .contains(type.id);

                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom:
                                                  index <
                                                      state.allType.length - 1
                                                  ? 10
                                                  : 0,
                                            ),
                                            child: GestureDetector(
                                              onTap: () => _toggleType(type.id),
                                              behavior: HitTestBehavior.opaque,
                                              child: _buildCheckboxItem(
                                                label: type.name,
                                                isSelected: isSelected,
                                                onChanged: (value) =>
                                                    _toggleType(type.id),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }

                                return _buildExpandableSection(
                                  title: 'Type',
                                  isExpanded: _isTypeExpanded,
                                  onToggle: () {
                                    setState(() {
                                      _isTypeExpanded = !_isTypeExpanded;
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text(
                                      'Tidak ada tipe tersedia',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 10),
                            Divider(
                              height: 20,
                              thickness: 0.5,
                              color: Colors.grey[300],
                            ),

                            // Category Section
                            _buildExpandableSection(
                              title: 'Kategori',
                              isExpanded: _isKategoriExpanded,
                              onToggle: () {
                                setState(() {
                                  _isKategoriExpanded = !_isKategoriExpanded;
                                });
                              },
                              child: BlocBuilder<CategoryBloc, CategoryState>(
                                builder: (context, state) {
                                  if (state is CategoryStateLoading) {
                                    return _buildCategoryShimmer();
                                  }

                                  if (state
                                      is CategoryStateLoadedCategoryByType) {
                                    // ✅ Simpan data category groups
                                    _categoryGroups = state.allCategory;

                                    if (state.allCategory.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Text(
                                          'Tidak ada kategori tersedia',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: _buildCategoryContent(
                                        state.allCategory,
                                      ),
                                    );
                                  }

                                  return const SizedBox();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer Buttons
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 40,
                      ),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _resetFilter,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Hapus',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyFilter,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Terapkan',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ========== Shimmer Widgets ==========

  Widget _buildTypeShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(3, (groupIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(5, (index) {
                  return Container(
                    width: 80 + (index * 10.0),
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],
          );
        }),
      ),
    );
  }

  // ========== Reusable Widgets ==========

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: AppFonts.primaryFont,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[const SizedBox(height: 8), child],
      ],
    );
  }

  Widget _buildCheckboxItem({
    required String label,
    required bool isSelected,
    required Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: AppFonts.primaryFont,
                color: isSelected ? Colors.black87 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(
            width: 16,
            height: 16,
            child: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: isSelected,
              onChanged: onChanged,
              activeColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              checkColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryContent(List<CategoryGroupEntity> data) {
    List<Widget> widgets = [];

    for (var type in data) {
      if (type.categories.isEmpty) continue;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft, // ✅ Tambahkan Align
            child: Text(
              type.typeName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );

      widgets.add(
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: type.categories.map((category) {
              final isSelected = _selectedCategoryIds.contains(category.id);
              return _buildCategoryChip(
                label: category.name,
                isSelected: isSelected,
                enabled: true,
                onTap: () => _toggleCategory(category.id),
              );
            }).toList(),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final borderColor = isSelected
        ? const Color(0xFFFDD835)
        : (enabled ? Colors.grey.shade300 : Colors.grey.shade200);

    final bgColor = isSelected ? const Color(0xFFFDD835) : Colors.white;
    final textColor = isSelected ? Colors.black87 : Colors.grey.shade700;

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );

    if (!enabled) {
      return Opacity(opacity: 0.5, child: child);
    }

    return GestureDetector(onTap: onTap, child: child);
  }
}
