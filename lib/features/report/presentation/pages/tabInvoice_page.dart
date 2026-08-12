import 'package:flutter/material.dart';

class TabInvoice extends StatefulWidget {
  const TabInvoice({super.key});

  @override
  State<TabInvoice> createState() => _TabInvoiceState();
}

class _TabInvoiceState extends State<TabInvoice> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _invoices = const [
    {
      'nomor': 'SINV-2026-00368',
      'jatuh': '1 Apr',
      'hari': '1 hari terlambat',
      'nilai': 'Rp 6,65Jt',
      'status': 'Jatuh Tempo',
      'statusColor': Color(0xFFC0392B),
      'bgColor': Color(0xFFFDEDED),
      'iconColor': Color(0xFFC0392B),
      'nilaiRed': true,
    },
    {
      'nomor': 'SINV-2026-00355',
      'jatuh': '28 Mar',
      'hari': '4 hari terlambat',
      'nilai': 'Rp 3,85Jt',
      'status': 'Jatuh Tempo',
      'statusColor': Color(0xFFC0392B),
      'bgColor': Color(0xFFFDEDED),
      'iconColor': Color(0xFFC0392B),
      'nilaiRed': true,
    },
    {
      'nomor': 'SINV-2026-00341',
      'jatuh': '20 Apr',
      'hari': '18 hari lagi',
      'nilai': 'Rp 8,33Jt',
      'status': 'Sebagian',
      'statusColor': Color(0xFFF5C518),
      'bgColor': Color(0xFFFFFDE7),
      'iconColor': Color(0xFFF5C518),
      'nilaiRed': false,
    },
    {
      'nomor': 'SINV-2026-00320',
      'jatuh': '10 Apr',
      'hari': '8 hari lagi',
      'nilai': 'Rp 6,25Jt',
      'status': 'Belum Bayar',
      'statusColor': Color(0xFFF5C518),
      'bgColor': Color(0xFFFFFDE7),
      'iconColor': Color(0xFFF5C518),
      'nilaiRed': false,
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                  _buildStatusInvoiceCard(),
                  const SizedBox(height: 12),
                  _buildInvoiceAktifCard(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInvoiceCard() {
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
            'STATUS INVOICE KESELURUHAN',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(painter: _DonutChartPainter()),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(const Color(0xFFC0392B), 'Belum Lunas', '47%'),
                  const SizedBox(height: 10),
                  _buildLegendItem(const Color(0xFFF5C518), 'Sebagian', '25%'),
                  const SizedBox(height: 10),
                  _buildLegendItem(
                    const Color(0xFFFCE4EC),
                    'Lunas',
                    '28%',
                    textColor: Colors.black54,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          _buildSummaryRow('Total Invoice', '31 invoice', isRed: false),
          const SizedBox(height: 8),
          _buildSummaryRow('Nilai Total', 'Rp 84.250.000', isRed: true),
          const SizedBox(height: 8),
          _buildSummaryRow('Sudah Diterima', 'Rp 63.650.000', isRed: false),
          const SizedBox(height: 8),
          _buildSummaryRow('Outstanding', 'Rp 20.600.000', isRed: true),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    String persen, {
    Color textColor = Colors.black87,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: textColor)),
        const SizedBox(width: 8),
        Text(
          persen,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {required bool isRed}) {
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

  Widget _buildInvoiceAktifCard() {
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
            'INVOICE AKTIF (5 INVOICE)',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ..._invoices.asMap().entries.map((entry) {
            final i = entry.key;
            final inv = entry.value;
            return Column(
              children: [
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                _buildInvoiceRow(inv),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(Map<String, dynamic> inv) {
    final bool isTerlambat = (inv['hari'] as String).contains('terlambat');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: inv['bgColor'] as Color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_outlined,
            color: inv['iconColor'] as Color,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                inv['nomor'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'Jatuh: ${inv['jatuh']} · ',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    TextSpan(
                      text: inv['hari'] as String,
                      style: TextStyle(
                        color: isTerlambat
                            ? const Color(0xFFC0392B)
                            : Colors.black54,
                        fontWeight: isTerlambat
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              inv['nilai'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: (inv['nilaiRed'] as bool)
                    ? const Color(0xFFC0392B)
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: inv['statusColor'] as Color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                inv['status'] as String,
                style: TextStyle(
                  color: (inv['status'] as String) == 'Jatuh Tempo'
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const gap = 3.0;
    final segments = [
      {'color': const Color(0xFFC0392B), 'sweep': 360.0 * 0.47},
      {'color': const Color(0xFFF5C518), 'sweep': 360.0 * 0.25},
      {'color': const Color(0xFFFCE4EC), 'sweep': 360.0 * 0.28},
    ];

    double startAngle = -90.0;
    for (final seg in segments) {
      paint.color = seg['color'] as Color;
      final sweep = (seg['sweep'] as double) - gap;
      canvas.drawArc(
        rect,
        _toRad(startAngle),
        _toRad(sweep),
        false,
        paint,
      );
      startAngle += seg['sweep'] as double;
    }
  }

  double _toRad(double deg) => deg * 3.14159265 / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}