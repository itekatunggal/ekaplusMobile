import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ekaplus_ekatunggal/features/report/presentation/pages/tab_penjualan_page.dart';
import 'package:ekaplus_ekatunggal/features/report/presentation/pages/tab_product_page.dart';
import 'package:ekaplus_ekatunggal/features/report/presentation/pages/tab_piutang_page.dart';
import 'package:ekaplus_ekatunggal/features/report/presentation/pages/tab_invoice_page.dart';

class PenjualanPage extends StatefulWidget {
  const PenjualanPage({super.key});

  @override
  State<PenjualanPage> createState() => _PenjualanPageState();
}

class _PenjualanPageState extends State<PenjualanPage> {
  int _selectedTab = 0;

  final List<String> _tabs = ['Penjualan', 'Produk', 'Rincian Piutang', 'Invoice'];

  /// Kembalikan widget sesuai tab yang dipilih.
  /// Masing-masing tab punya file sendiri di folder tabs/.
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return const TabPenjualan();   // lib/tabs/tab_penjualan.dart
      case 1:
        return const TabProduk();      // lib/tabs/tab_produk.dart
      case 2:
        return const TabPiutang();
      case 3:
        return const TabInvoice();
      // case 4:
      //   return const TabPembayaran();
      default:
        return const TabPenjualan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      // bottomNavigationBar: _buildBottomNavBar(),
      body: Column(
        children: [
          // Header merah (tetap di semua tab)
          _buildHeader(),
          // Konten tab berubah sesuai pilihan
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFC0392B),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol back + judul
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Laporan Pelanggan',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),

            // Info pelanggan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C518),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'PA',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'PT Anugerah\nSejahtera',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'CUST-00024 · Jakarta · Sales: Ilham Hakim',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Stat chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatChip('Total YTD', 'Rp 84,2Jt', isRed: true),
                  const SizedBox(width: 8),
                  _buildStatChip('Total SO', '28', isRed: false),
                  const SizedBox(width: 8),
                  _buildStatChip('Piutang', 'Rp 20,6Jt', isRed: true),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              dragStartBehavior: DragStartBehavior.down,
              physics: const BouncingScrollPhysics(),  
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF5C518)
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color:
                              isSelected ? Colors.black87 : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, {required bool isRed}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: isRed ? const Color(0xFFF5C518) : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Navigation Bar ────────────────────────────────────────────────

  // Widget _buildBottomNavBar() {
  //   final items = [
  //     {'icon': Icons.home_outlined, 'label': 'Beranda'},
  //     {'icon': Icons.receipt_long_outlined, 'label': 'SO'},
  //     {'icon': Icons.description_outlined, 'label': 'Invoice'},
  //     {'icon': Icons.bar_chart, 'label': 'Report'},
  //   ];

  //   return Container(
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
  //     ),
  //     child: SafeArea(
  //       top: false,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: List.generate(items.length, (index) {
  //           final isSelected = _selectedNavIndex == index;
  //           return GestureDetector(
  //             onTap: () => setState(() => _selectedNavIndex = index),
  //             child: Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 8),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     items[index]['icon'] as IconData,
  //                     color: isSelected
  //                         ? const Color(0xFFC0392B)
  //                         : Colors.grey,
  //                     size: 24,
  //                   ),
  //                   const SizedBox(height: 2),
  //                   Text(
  //                     items[index]['label'] as String,
  //                     style: TextStyle(
  //                       fontSize: 11,
  //                       color: isSelected
  //                           ? const Color(0xFFC0392B)
  //                           : Colors.grey,
  //                       fontWeight: isSelected
  //                           ? FontWeight.w600
  //                           : FontWeight.normal,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         }),
  //       ),
  //     ),
  //   );
  // }
}
