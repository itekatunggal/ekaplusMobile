import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/feature_flags.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showCustomer;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showCustomer = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_BottomNavItemData>[
      const _BottomNavItemData(icon: Icons.home, label: 'Beranda'),
      if (FeatureFlags.showBranchDirectory)
        const _BottomNavItemData(
          icon: Icons.store_mall_directory_outlined,
          selectedIcon: Icons.store_mall_directory_rounded,
          label: 'Cabang',
        ),
      if (FeatureFlags.showSalesDirectory)
        const _BottomNavItemData(
          icon: Icons.support_agent_outlined,
          selectedIcon: Icons.support_agent_rounded,
          label: 'Sales',
        ),
      if (FeatureFlags.showProductCategories)
        const _BottomNavItemData(icon: Icons.grid_view, label: 'Kategori'),
      if (FeatureFlags.showWishlist)
        const _BottomNavItemData(
          icon: Icons.favorite_border_rounded,
          selectedIcon: Icons.favorite_rounded,
          label: 'Wishlist',
        ),

      if (showCustomer)
        const _BottomNavItemData(
          icon: Icons.apartment_rounded,
          label: 'Customer',
        ),

      const _BottomNavItemData(
        icon: Icons.person_outline,
        selectedIcon: Icons.person_rounded,
        label: 'Akun',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 8),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      // Ikuti system navigation inset masing-masing perangkat. Dengan begitu
      // tombol tidak tertutup navigation bar Android tanpa offset tetap.
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];

              return Expanded(
                child: _NavItem(
                  icon: item.icon,
                  selectedIcon: item.selectedIcon,
                  label: item.label,
                  selected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const _BottomNavItemData({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).primaryColor
        : Colors.grey.shade600;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected && selectedIcon != null ? selectedIcon : icon,
                  color: color,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    height: 1.1,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
