import 'package:flutter/material.dart';

class TabProduk extends StatelessWidget {
  const TabProduk({super.key});

  final List<Map<String, dynamic>> _produkData = const [
    {
      'nama': 'Produk A - Paket Reguler',
      'qty': 120,
      'total': 15000000,
      'persen': 54.5,
    },
    {
      'nama': 'Produk B - Paket Premium',
      'qty': 45,
      'total': 8500000,
      'persen': 30.9,
    },
    {
      'nama': 'Produk C - Add On',
      'qty': 30,
      'total': 4000000,
      'persen': 14.5,
    },
  ];

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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildTopProdukCard(),
          const SizedBox(height: 12),
          _buildDaftarProdukCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTopProdukCard() {
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
                    'Produk Terlaris Apr 2024',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Produk A - Paket Reguler',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '120 unit · Rp 15.000.000',
                    style: TextStyle(color: Color(0xFFF5C518), fontSize: 13),
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
              child: const Icon(Icons.inventory_2_outlined,
                  color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftarProdukCard() {
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
              'PRODUK DIBELI (APR 2024)',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),
            ..._produkData.map((p) => _buildProdukRow(p)),
          ],
        ),
      ),
    );
  }

  Widget _buildProdukRow(Map<String, dynamic> produk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  produk['nama'],
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                _formatRupiah(produk['total']),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFC0392B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${produk['qty']} unit',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                '${produk['persen']}%',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: produk['persen'] / 100,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC0392B)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}