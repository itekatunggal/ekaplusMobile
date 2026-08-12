import 'package:flutter/material.dart';

class TabPenjualan extends StatefulWidget {
  const TabPenjualan({super.key});

  @override
  State<TabPenjualan> createState() => _TabPenjualanState();
}

class _TabPenjualanState extends State<TabPenjualan> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _salesData = const [
    {'bulan': 'Apr 2024', 'nilai': 27500000, 'highlighted': true},
    {'bulan': 'Mar 2024', 'nilai': 20000000, 'highlighted': false},
    {'bulan': 'Feb 2024', 'nilai': 16500000, 'highlighted': false},
    {'bulan': 'Jan 2024', 'nilai': 12000000, 'highlighted': false},
    {'bulan': 'Des 2023', 'nilai': 9250000, 'highlighted': false},
    {'bulan': 'Nov 2023', 'nilai': 7500000, 'highlighted': false},
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatRupiah(int nilai) {
    String s = nilai.toString();
    String result = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result = '.$result';
      result = s[i] + result;
      count++;
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          overscroll: false,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTotalPenjualanCard(),
                  const SizedBox(height: 12),
                  _buildTrenPenjualanCard(),
                  const SizedBox(height: 12),
                  _buildRingkasanCepatCard(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPenjualanCard() {
    return Container(
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
                      style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
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
    );
  }

  Widget _buildTrenPenjualanCard() {
    return Container(
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
          _buildMiniBarChart(),
          const SizedBox(height: 4),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
    );
  }

  Widget _buildMiniBarChart() {
    final List<double> values = [7.5, 9.25, 12, 16.5, 20, 27.5];
    const double maxVal = 27.5;
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
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
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 13,
              color: highlighted ? const Color(0xFFC0392B) : Colors.black87,
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanCepatCard() {
    return Container(
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
          _buildRingkasanRow('Rata-rata nilai SO', 'Rp 7.250.000', isRed: false),
          const SizedBox(height: 10),
          _buildRingkasanRow('Frekuensi beli', 'Setiap 6 hari', isRed: true),
          const SizedBox(height: 10),
          _buildRingkasanRow('Status pelanggan', '⭐ Premium', isRed: true),
        ],
      ),
    );
  }

  Widget _buildRingkasanRow(String label, String value, {required bool isRed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54, fontSize: 13)),
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
}