// import 'package:ekaplus_ekatunggal/constant.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class BottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const BottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

// //   BottomNavBar(
// //   currentIndex: _currentIndex,
// //   onTap: (index) {
// //     setState(() {
// //       _currentIndex = index;
// //     });
// //   },
// // )

//   @override
//   Widget build(BuildContext context) {
//     final scale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.0);

//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         decoration: BoxDecoration(
//           color: AppColors.whiteColor,
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 8),
//           ],
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(16),
//             topRight: Radius.circular(16),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // _NavItem(
//             //   icon: Icons.home,
//             //   label: 'Beranda',
//             //   selected: currentIndex == 0,
//             //   onTap: () {
//             //     if (currentIndex != 0) onTap(0);
//             //   },
//             // ),
//             // _NavItem(
//             //   icon: Icons.grid_view,
//             //   label: 'Kategori',
//             //   selected: currentIndex == 1,
//             //   onTap: () {
//             //     if (currentIndex != 1) onTap(1);
//             //   },
//             // ),
//             // _NavItem(
//             //   icon: Icons.favorite_border,
//             //   label: 'Wishlist',
//             //   selected: currentIndex == 2,
//             //   onTap: () {
//             //     if (currentIndex != 2) onTap(2);
//             //   },
//             // ),
//             // _NavItem(
//             //   icon: Icons.report,
//             //   label: 'Report',
//             //   selected: currentIndex == 3,
//             //   onTap: () {
//             //     if (currentIndex != 3) onTap(3);
//             //   },
//             // ),
//             // _NavItem(
//             //   icon: Icons.person_outline,
//             //   label: 'Akun',
//             //   selected: currentIndex == 4,
//             //   onTap: () {
//             //     if (currentIndex != 4) onTap(4);
//             //   },
//             // ),
//             _NavItem(
//               icon: Icons.home,
//               label: 'Beranda',
//               selected: currentIndex == 0,
//               onTap: () {
//                 context.goNamed('home');
//               },
//             ),
//             _NavItem(
//               icon: Icons.grid_view,
//               label: 'Kategori',
//               selected: currentIndex == 1,
//               onTap: () {
//                 context.goNamed('category');
//               },
//             ),
//             _NavItem(
//               icon: Icons.favorite_border,
//               label: 'Wishlist',
//               selected: currentIndex == 2,
//               onTap: () {
//                 context.goNamed('wishlist');
//               },
//             ),
//             _NavItem(
//               icon: Icons.report,
//               label: 'Report',
//               selected: currentIndex == 3,
//               onTap: () {
//                 context.goNamed('report');
//               },
//             ),
//             // _NavItem(
//             //   icon: Icons.report,
//             //   label: 'Invoice',
//             //   selected: currentIndex == 4,
//             //   onTap: () {
//             //     context.goNamed('invoice');
//             //   },
//             // ),
//             _NavItem(
//               icon: Icons.receipt_long_outlined,
//               label: 'Transaksi',
//               selected: currentIndex == 4,
//               onTap: () {
//                 context.goNamed('transaksi');
//               },
//             ),
//             // BlocBuilder<ActiveCompanyCubit, ActiveCompanyState>(
//             //   builder: (context, state) {
//             //     final hasActiveCompany = state is ActiveCompanyReady &&
//             //         state.companies.isNotEmpty &&
//             //         state.activeCompany != null;

//             //     if (!hasActiveCompany) return const SizedBox.shrink();

//             //     return _NavItem(
//             //       icon: Icons.receipt_long_outlined,
//             //       label: 'Transaksi',
//             //       selected: currentIndex == 4,
//             //       onTap: () {
//             //         context.goNamed('transaksi');
//             //       },
//             //     );
//             //   },
//             // ),
//             _NavItem(
//               icon: Icons.person_outline,
//               label: 'Akun',
//               selected: currentIndex == 5,
//               onTap: () {
//                 context.goNamed('account');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _NavItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;

//   const _NavItem({
//     required this.icon,
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = selected
//         ? Theme.of(context).primaryColor
//         : Colors.grey.shade600;

//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: SizedBox(
//         width: 64,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: color, size: 22),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(color: color, fontSize: 11, height: 1.1),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.0);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home,
              label: 'Beranda',
              selected: currentIndex == 0,
              onTap: () => context.goNamed('home'),
            ),
            _NavItem(
              icon: Icons.grid_view,
              label: 'Kategori',
              selected: currentIndex == 1,
              onTap: () => context.goNamed('category'),
            ),
            _NavItem(
              icon: Icons.apartment_rounded,
              label: 'Customer',
              selected: currentIndex == 2,
              showBadge: true,
              onTap: () => context.goNamed('customer'),
            ),
            // _NavItem(
            //   icon: Icons.report,
            //   label: 'Report',
            //   selected: currentIndex == 3,
            //   onTap: () => context.goNamed('report'),
            // ),
            _NavItem(
              icon: Icons.receipt_long_outlined,
              label: 'Transaksi',
              selected: currentIndex == 3,
              onTap: () => context.goNamed('transaksi'),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Akun',
              selected: currentIndex == 4,
              onTap: () => context.goNamed('account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showBadge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).primaryColor
        : Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 22),
                if (showBadge && selected)
                  const Positioned(
                    right: -3,
                    top: -3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 7, height: 7),
                    ),
                  ),
              ],
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
    );
  }
}
