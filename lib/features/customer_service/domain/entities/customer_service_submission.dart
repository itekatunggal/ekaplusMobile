enum CustomerServiceSubmissionType { feedback, complaint }

enum CustomerServiceSubmissionStatus { waiting, replied }

class CustomerServiceSubmission {
  const CustomerServiceSubmission({
    required this.id,
    required this.type,
    required this.status,
    required this.name,
    required this.category,
    required this.message,
    required this.createdAt,
    this.attachmentName,
    this.adminName,
    this.adminReply,
    this.repliedAt,
  });

  final String id;
  final CustomerServiceSubmissionType type;
  final CustomerServiceSubmissionStatus status;
  final String name;
  final String category;
  final String message;
  final DateTime createdAt;
  final String? attachmentName;
  final String? adminName;
  final String? adminReply;
  final DateTime? repliedAt;

  bool get hasReply =>
      status == CustomerServiceSubmissionStatus.replied &&
      adminReply?.trim().isNotEmpty == true;
}

class CustomerServiceDummyData {
  const CustomerServiceDummyData._();

  static final List<CustomerServiceSubmission> submissions = [
    CustomerServiceSubmission(
      id: 'CS-20261120-001',
      type: CustomerServiceSubmissionType.feedback,
      status: CustomerServiceSubmissionStatus.replied,
      name: 'Budi Santoso',
      category: 'Aplikasi EKA+',
      message:
          'Mohon ditambahkan filter berdasarkan periode pada halaman riwayat pesanan agar pencarian transaksi lama lebih mudah.',
      createdAt: DateTime(2026, 11, 20, 9, 35),
      adminName: 'Admin Vika',
      adminReply:
          'Terima kasih atas masukannya. Usulan filter periode sudah kami teruskan kepada tim pengembangan untuk dipertimbangkan pada pembaruan berikutnya.',
      repliedAt: DateTime(2026, 11, 21, 14, 10),
    ),
    CustomerServiceSubmission(
      id: 'CS-20261118-002',
      type: CustomerServiceSubmissionType.complaint,
      status: CustomerServiceSubmissionStatus.replied,
      name: 'Budi Santoso',
      category: 'Pengiriman',
      message:
          'Status pengiriman pesanan belum berubah sejak dua hari lalu, padahal barang sudah diterima oleh gudang kami.',
      createdAt: DateTime(2026, 11, 18, 15, 20),
      attachmentName: 'bukti_penerimaan.jpg',
      adminName: 'Admin Customer Service',
      adminReply:
          'Kami sudah melakukan pengecekan. Status pesanan telah diperbarui menjadi diterima. Mohon muat ulang halaman pesanan Anda.',
      repliedAt: DateTime(2026, 11, 19, 10, 5),
    ),
    CustomerServiceSubmission(
      id: 'CS-20261115-003',
      type: CustomerServiceSubmissionType.feedback,
      status: CustomerServiceSubmissionStatus.waiting,
      name: 'Budi Santoso',
      category: 'Produk',
      message:
          'Akan sangat membantu jika foto produk dapat diperbesar langsung dari daftar produk tanpa harus masuk ke halaman detail.',
      createdAt: DateTime(2026, 11, 15, 11, 45),
    ),
    CustomerServiceSubmission(
      id: 'CS-20261112-004',
      type: CustomerServiceSubmissionType.complaint,
      status: CustomerServiceSubmissionStatus.waiting,
      name: 'Budi Santoso',
      category: 'Tagihan atau Pembayaran',
      message:
          'Invoice yang sudah dibayar masih tampil sebagai belum lunas pada halaman tagihan.',
      createdAt: DateTime(2026, 11, 12, 8, 10),
      attachmentName: 'bukti_transfer.png',
    ),
  ];

  static CustomerServiceSubmission? findById(String id) {
    for (final submission in submissions) {
      if (submission.id == id) return submission;
    }
    return null;
  }
}
