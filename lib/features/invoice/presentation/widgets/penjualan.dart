import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laporan Pelanggan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB71C1C)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LaporanPelangganPage(),
    );
  }
}

class LaporanPelangganPage extends StatefulWidget {
  const LaporanPelangganPage({super.key});

  @override
  State<LaporanPelangganPage> createState() => _LaporanPelangganPageState();
}

class _LaporanPelangganPageState extends State<LaporanPelangganPage> {
  int _selectedTab = 0;
  int _selectedNavIndex = 3;

  final List<String> _tabs = ['Penjualan', 'Invoice', 'Produk', 'Lainnya'];

  final List<Map<String, dynamic>> _salesData = [
    {'bulan': 'Apr 2024', 'nilai': 27500000, 'highlighted': true},
    {'bulan': 'Mar 2024', 'nilai': 20000000, 'highlighted': false},
    {'bulan': 'Feb 2024', 'nilai': 16500000, 'highlighted': false},
    {'bulan': 'Jan 2024', 'nilai': 12000000, 'highlighted': false},
    {'bulan': 'Des 2023', 'nilai': 9250000, 'highlighted': false},
    {'bulan': 'Nov 2023', 'nilai': 7500000, 'highlighted': false},
  ];

  String _formatRupiah(int nilai) {
    String s = nilai.toString();
    String result = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result = '.' + result;
      result = s[i] + result;
      count++;
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      bottomNavigationBar: _buildBottomNavBar(),
      body: Column(
        children: [
          // Header merah
          _buildHeader(),
          // Konten scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTotalPenjualanCard(),
                  const SizedBox(height: 12),
                  _buildTrenPenjualanCard(),
                  const SizedBox(height: 12),
                  _buildRingkasanCepatCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFC0392B),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            // Customer info
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
                        'CUST-00024 · Jakarta · Sales: Ilham\nHakim',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Stats row
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
            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
                          color: isSelected ? Colors.black87 : Colors.white,
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
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
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

  Widget _buildTotalPenjualanCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Total Penjualan Apr 2024',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Rp 27.500.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.arrow_upward,
                          color: Color(0xFF4CAF50), size: 14),
                      SizedBox(width: 2),
                      Text(
                        '+37,5% vs Maret 2024',
                        style:
                            TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.show_chart, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrenPenjualanCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TREN PENJUALAN 6 BULAN',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            // Mini bar chart
            _buildMiniBarChart(),
            const SizedBox(height: 4),
            // Month labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('Nov', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Des', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Jan', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Feb', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Mar', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Apr',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFC0392B),
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // Sales list
            ..._salesData.map((item) => _buildSalesRow(
                  item['bulan'],
                  _formatRupiah(item['nilai']),
                  item['highlighted'],
                )),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Total YTD 2024',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Rp 84.250.000',
                  style: TextStyle(
                    color: Color(0xFFC0392B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBarChart() {
    final List<double> values = [7.5, 9.25, 12, 16.5, 20, 27.5];
    final double maxVal = 27.5;
    const double chartHeight = 60;

    return SizedBox(
      height: chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(values.length, (i) {
          final isLast = i == values.length - 1;
          final barHeight = (values[i] / maxVal) * chartHeight;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 28,
                height: barHeight,
                decoration: BoxDecoration(
                  color: isLast
                      ? const Color(0xFFC0392B)
                      : const Color(0xFFEEEEEE),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSalesRow(String bulan, String nilai, bool highlighted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            bulan,
            style: TextStyle(
              fontSize: 13,
              color: highlighted ? const Color(0xFFC0392B) : Colors.black54,
              fontWeight:
                  highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 13,
              color: highlighted ? const Color(0xFFC0392B) : Colors.black87,
              fontWeight:
                  highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanCepatCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RINGKASAN CEPAT',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),
            _buildRingkasanRow('Rata-rata SO/bulan', '5,2 SO', isRed: false),
            const SizedBox(height: 10),
            _buildRingkasanRow('Rata-rata nilai SO', 'Rp 7.250.000',
                isRed: false),
            const SizedBox(height: 10),
            _buildRingkasanRow('Frekuensi beli', 'Setiap 6 hari', isRed: true),
            const SizedBox(height: 10),
            _buildRingkasanRow('Status pelanggan', '⭐ Premium', isRed: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanRow(String label, String value,
      {required bool isRed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: isRed ? const Color(0xFFC0392B) : Colors.black87,
            fontWeight: isRed ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Beranda'},
      {'icon': Icons.receipt_long_outlined, 'label': 'SO'},
      {'icon': Icons.description_outlined, 'label': 'Invoice'},
      {'icon': Icons.bar_chart, 'label': 'Report'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = _selectedNavIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedNavIndex = index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index]['icon'] as IconData,
                      color: isSelected
                          ? const Color(0xFFC0392B)
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? const Color(0xFFC0392B)
                            : Colors.grey,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}