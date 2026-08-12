import 'package:flutter/material.dart';

class TabPiutang extends StatefulWidget {
  const TabPiutang({super.key});

  @override
  State<TabPiutang> createState() => _TabPiutangState();
}

class _TabPiutangState extends State<TabPiutang> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _distribusiData = const [
    {'label': 'Belum jatuh tempo', 'nilai': 0, 'persen': 0.0, 'warna': Color(0xFFBDBDBD)},
    {'label': '1 – 30 hari', 'nilai': 6250000, 'persen': 30.3, 'warna': Color(0xFFF5A623)},
    {'label': '31 – 60 hari', 'nilai': 7900000, 'persen': 38.3, 'warna': Color(0xFFE74C3C)},
    {'label': '61 – 90 hari', 'nilai': 4600000, 'persen': 22.3, 'warna': Color(0xFFC0392B)},
    {'label': '> 90 hari', 'nilai': 1850000, 'persen': 9.0, 'warna': Color(0xFF922B21)},
  ];

  final List<Map<String, dynamic>> _invoiceTerlambat = const [
    {
      'nomorInvoice': 'SINV-2026-00368',
      'jatuhTempo': 'Jatuh: 1 Apr',
      'telat': '1 hari',
      'nilai': 6650000,
    },
    {
      'nomorInvoice': 'SINV-2026-00298',
      'jatuhTempo': 'Jatuh: 10 Mar',
      'telat': '22 hari',
      'nilai': 3850000,
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatRupiah(int nilai) {
    if (nilai == 0) return 'Rp 0';
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
                  _buildOutstandingCard(),
                  const SizedBox(height: 12),
                  _buildDistribusiUmurCard(),
                  const SizedBox(height: 12),
                  _buildInvoiceTerlambatCard(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutstandingCard() {
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
                  'Total Outstanding',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 6),
                Text(
                  'Rp 20.600.000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Per 2 Apr 2024 · 5 invoice aktif',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
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
            child: const Icon(Icons.alarm, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildDistribusiUmurCard() {
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
            'DISTRIBUSI UMUR PIUTANG',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          ..._distribusiData.map((item) => _buildDistribusiRow(item)),
          const SizedBox(height: 4),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Total Piutang',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp 20.600.000',
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
    );
  }

  Widget _buildDistribusiRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['label'],
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
              Text(_formatRupiah(item['nilai']),
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item['persen'] / 100,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(item['warna']),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTerlambatCard() {
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
            'INVOICE TERLAMBAT',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          ..._invoiceTerlambat.asMap().entries.map((entry) {
            final index = entry.key;
            final invoice = entry.value;
            return Column(
              children: [
                _buildInvoiceRow(invoice),
                if (index < _invoiceTerlambat.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
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
                'Total Terlambat',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp 10.500.000',
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
    );
  }

  Widget _buildInvoiceRow(Map<String, dynamic> invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFF9E9E9E),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice['nomorInvoice'],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12),
                  children: [
                    TextSpan(
                      text: '${invoice['jatuhTempo']} · ',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    TextSpan(
                      text: invoice['telat'],
                      style: const TextStyle(
                        color: Color(0xFFC0392B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Text(
          _formatRupiah(invoice['nilai']),
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFFC0392B),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}