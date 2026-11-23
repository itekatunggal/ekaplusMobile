import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/customer_service/domain/entities/customer_service_submission.dart';
import 'package:ekaplus_ekatunggal/features/customer_service/presentation/pages/customer_service_history_page.dart';
import 'package:flutter/material.dart';

class CustomerServiceHistoryDetailPage extends StatelessWidget {
  const CustomerServiceHistoryDetailPage({
    super.key,
    required this.submissionId,
  });

  final String submissionId;

  @override
  Widget build(BuildContext context) {
    final submission = CustomerServiceDummyData.findById(submissionId);
    if (submission == null) return const _SubmissionNotFoundPage();
    return _SubmissionDetail(submission: submission);
  }
}

class _SubmissionDetail extends StatefulWidget {
  const _SubmissionDetail({required this.submission});

  final CustomerServiceSubmission submission;

  @override
  State<_SubmissionDetail> createState() => _SubmissionDetailState();
}

class _SubmissionDetailState extends State<_SubmissionDetail> {
  final _replyController = TextEditingController();
  final List<_LocalUserReply> _userReplies = [];

  CustomerServiceSubmission get submission => widget.submission;

  bool get _isFeedback =>
      submission.type == CustomerServiceSubmissionType.feedback;

  @override
  void initState() {
    super.initState();
    _replyController.addListener(_refreshReplyAction);
  }

  @override
  void dispose() {
    _replyController
      ..removeListener(_refreshReplyAction)
      ..dispose();
    super.dispose();
  }

  void _refreshReplyAction() => setState(() {});

  void _sendReply() {
    final message = _replyController.text.trim();
    if (message.isEmpty) return;

    _replyController.clear();
    setState(
      () => _userReplies.add(
        _LocalUserReply(message: message, sentAt: DateTime.now()),
      ),
    );
    FocusScope.of(context).unfocus();
    AppSnackbar.show(
      context,
      message: 'Balasan tersimpan sementara. Pengiriman API belum aktif.',
      type: AppSnackbarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 52,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
            size: 22,
          ),
        ),
        titleSpacing: 0,
        title: Text(
          _isFeedback ? 'DETAIL MASUKAN' : 'DETAIL KENDALA',
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Image.asset(
              'assets/icons/icon_app.png',
              width: 34,
              height: 34,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
              children: [
                _DetailStatusCard(submission: submission),
                const SizedBox(height: 14),
                _DetailSection(
                  title: 'INFORMASI PENGAJUAN',
                  child: Column(
                    children: [
                      _InfoRow(label: 'Nomor', value: submission.id),
                      const Divider(height: 17, color: Color(0xFFF1F5F9)),
                      _InfoRow(
                        label: 'Jenis',
                        value: _isFeedback ? 'Masukan' : 'Kendala',
                      ),
                      const Divider(height: 17, color: Color(0xFFF1F5F9)),
                      _InfoRow(label: 'Kategori', value: submission.category),
                      const Divider(height: 17, color: Color(0xFFF1F5F9)),
                      _InfoRow(label: 'Nama', value: submission.name),
                      const Divider(height: 17, color: Color(0xFFF1F5F9)),
                      _InfoRow(
                        label: 'Diajukan',
                        value: formatCustomerServiceDate(submission.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _DetailSection(
                  title: _isFeedback ? 'ISI MASUKAN' : 'DETAIL KENDALA',
                  child: Text(
                    submission.message,
                    style: const TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      color: Color(0xFF475569),
                      fontSize: 11.5,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (submission.attachmentName != null) ...[
                  const SizedBox(height: 14),
                  _DetailSection(
                    title: 'LAMPIRAN',
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppColors.primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              submission.attachmentName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppFonts.primaryFont,
                                color: Color(0xFF1E293B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _AdminReplySection(
                  submission: submission,
                  userReplies: _userReplies,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: submission.hasReply
          ? _ReplyComposer(
              controller: _replyController,
              canSend: _replyController.text.trim().isNotEmpty,
              onSend: _sendReply,
            )
          : null,
    );
  }
}

class _DetailStatusCard extends StatelessWidget {
  const _DetailStatusCard({required this.submission});

  final CustomerServiceSubmission submission;

  @override
  Widget build(BuildContext context) {
    final hasReply = submission.hasReply;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasReply ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasReply ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasReply ? Icons.mark_chat_read_outlined : Icons.schedule_rounded,
            color: hasReply ? const Color(0xFF059669) : const Color(0xFFD97706),
            size: 24,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasReply ? 'Sudah dibalas admin' : 'Menunggu balasan admin',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    color: hasReply
                        ? const Color(0xFF047857)
                        : const Color(0xFFB45309),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasReply
                      ? 'Balasan dapat dilihat pada bagian bawah.'
                      : 'Tim kami akan meninjau pengajuan Anda.',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    color: hasReply
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(18)),
      border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9))),
      boxShadow: [
        BoxShadow(
          color: Color(0x120F172A),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Color(0xFF94A3B8),
            fontSize: 9.5,
            letterSpacing: .45,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 82,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Color(0xFF94A3B8),
            fontSize: 10.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Color(0xFF1E293B),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _AdminReplySection extends StatelessWidget {
  const _AdminReplySection({
    required this.submission,
    required this.userReplies,
  });

  final CustomerServiceSubmission submission;
  final List<_LocalUserReply> userReplies;

  @override
  Widget build(BuildContext context) {
    if (!submission.hasReply) {
      return const _DetailSection(
        title: 'BALASAN ADMIN',
        child: Row(
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              color: Color(0xFF94A3B8),
              size: 21,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Belum ada balasan dari admin.',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _DetailSection(
      title: 'PERCAKAPAN',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Color(0xFF059669),
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.adminName ?? 'Admin Customer Service',
                      style: const TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: Color(0xFF1E293B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (submission.repliedAt != null)
                      Text(
                        formatCustomerServiceDate(submission.repliedAt!),
                        style: const TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          color: Color(0xFF94A3B8),
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              submission.adminReply!,
              style: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: Color(0xFF475569),
                fontSize: 11,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          for (final reply in userReplies) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: .88,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formatCustomerServiceDate(reply.sentAt),
                          style: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            color: Color(0xFF94A3B8),
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Anda',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            color: Color(0xFF1E293B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        reply.message,
                        style: const TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          color: Color(0xFF7F1D2D),
                          fontSize: 11,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocalUserReply {
  const _LocalUserReply({required this.message, required this.sentAt});

  final String message;
  final DateTime sentAt;
}

class _ReplyComposer extends StatelessWidget {
  const _ReplyComposer({
    required this.controller,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
    ),
    child: SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      color: Color(0xFF1E293B),
                      fontSize: 11.5,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tulis balasan...',
                      counterText: '',
                      hintStyle: const TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: _replyBorder(const Color(0xFFE2E8F0)),
                      enabledBorder: _replyBorder(const Color(0xFFE2E8F0)),
                      focusedBorder: _replyBorder(
                        AppColors.primaryColor,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 46,
                  height: 46,
                  child: IconButton.filled(
                    tooltip: 'Kirim balasan',
                    onPressed: canSend ? onSend : null,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 19),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  static OutlineInputBorder _replyBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _SubmissionNotFoundPage extends StatelessWidget {
  const _SubmissionNotFoundPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F7F9),
    appBar: AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
      ),
    ),
    body: const Center(
      child: Text(
        'Pengajuan tidak ditemukan',
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          color: Color(0xFF64748B),
          fontSize: 12,
        ),
      ),
    ),
  );
}
