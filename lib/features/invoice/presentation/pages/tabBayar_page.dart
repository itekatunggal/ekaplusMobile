import 'package:flutter/material.dart';

class TabPembayaran extends StatelessWidget {
  const TabPembayaran({super.key});

  final List<Map<String, dynamic>> _pembayaran = const [
    {
      'nomor': 'PE-2026-00211',
      'tanggal': '2 Apr 2024',
      'metode': 'Transfer BCA',
      'nilai': 6650000,
      'status': 'Submitted',
      'bgColor': Color(0xFFFFF8E1),
      'iconColor': Color(0xFFF5C518),
    },
    {
      'nomor': 'PE-2026-00198',
      'tanggal': '28 Mar 2024',
      'metode': 'Transfer BCA',
      'nilai': 5881500,
      'status': 'Submitted',
      'bgColor': Color(0xFFFFF8E1),
      'iconColor': Color(0xFFF5C518),
    },
    {
      'nomor': 'PE-2026-00175',
      'tanggal': '15 Mar 2024',
      'metode': 'COD',
      'nilai': 8250000,
      'status': 'Submitted',
      'bgColor': Color(0xFFEEEEEE),
      'iconColor': Color(0xFF9E9E9E),
    },
    {
      'nomor': 'PE-2026-00152',
      'tanggal': '28 Feb 2024',
      'metode': 'Transfer BRI',
      'nilai': 11250000,
      'status': 'Submitted',
      'bgColor': Color(0xFFEEEEEE),
      'iconColor': Color(0xFF9E9E9E),
    },
    {
      'nomor': 'PE-2026-00131',
      'tanggal': '15 Feb 2024',
      'metode': 'Transfer BCA',
      'nilai': 5250000,
      'status': 'Submitted',
      'bgColor': Color(0xFFFFF8E1),
      'iconColor': Color(0xFFF5C518),
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
          _buildMetodePembayaranCard(),
          const SizedBox(height: 12),
          _buildPembayaranTerakhirCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── METODE PEMBAYARAN ──────────────────────────────────────────────────────

  Widget _buildMetodePembayaranCard() {
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
              'METODE PEMBAYARAN',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),
            _buildMetodeRow('Transfer Bank', 65, const Color(0xFFC0392B)),
            const SizedBox(height: 12),
            _buildMetodeRow('Cash on Delivery', 25, const Color(0xFFE57373)),
            const SizedBox(height: 12),
            _buildMetodeRow('Giro / Cek', 10, const Color(0xFFEF9A9A)),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            _buildInfoRow('Rata-rata hari bayar', '28 hari', isRed: true),
            const SizedBox(height: 8),
            _buildInfoRow('Tepat waktu', '72% transaksi', isRed: false),
            const SizedBox(height: 8),
            _buildInfoRow('Terlambat bayar', '28% transaksi', isRed: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodeRow(String label, int persen, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            Text(
              '$persen%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC0392B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: persen / 100,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {required bool isRed}) {
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

  // ── PEMBAYARAN TERAKHIR CARD ───────────────────────────────────────────────

  Widget _buildPembayaranTerakhirCard() {
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
              'PEMBAYARAN TERAKHIR',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            ..._pembayaran.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ),
                  _buildPembayaranRow(item),
                ],
              );
            }),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Total Diterima',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rp 63.650.000',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC0392B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPembayaranRow(Map<String, dynamic> item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item['bgColor'] as Color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.credit_card,
            color: item['iconColor'] as Color,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['nomor'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${item['tanggal']} · ${item['metode']}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        // Nilai + status
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatRupiah(item['nilai'] as int),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item['status'] as String,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ],
    );
  }
}