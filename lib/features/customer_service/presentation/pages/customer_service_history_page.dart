import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/customer_service/domain/entities/customer_service_submission.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerServiceHistoryPage extends StatefulWidget {
  const CustomerServiceHistoryPage({super.key});

  @override
  State<CustomerServiceHistoryPage> createState() =>
      _CustomerServiceHistoryPageState();
}

class _CustomerServiceHistoryPageState
    extends State<CustomerServiceHistoryPage> {
  CustomerServiceSubmissionType? _selectedType;

  List<CustomerServiceSubmission> get _visibleItems {
    final items = CustomerServiceDummyData.submissions;
    if (_selectedType == null) return items;
    return items.where((item) => item.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final repliedCount = CustomerServiceDummyData.submissions
        .where((item) => item.hasReply)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: const _HistoryAppBar(),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: _HistorySummary(
                    total: CustomerServiceDummyData.submissions.length,
                    replied: repliedCount,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _HistoryFilterChip(
                        label: 'Semua',
                        selected: _selectedType == null,
                        onTap: () => setState(() => _selectedType = null),
                      ),
                      const SizedBox(width: 8),
                      _HistoryFilterChip(
                        label: 'Masukan',
                        selected:
                            _selectedType ==
                            CustomerServiceSubmissionType.feedback,
                        onTap: () => setState(
                          () => _selectedType =
                              CustomerServiceSubmissionType.feedback,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _HistoryFilterChip(
                        label: 'Kendala',
                        selected:
                            _selectedType ==
                            CustomerServiceSubmissionType.complaint,
                        onTap: () => setState(
                          () => _selectedType =
                              CustomerServiceSubmissionType.complaint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _visibleItems.isEmpty
                      ? const _EmptyHistory()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
                          itemCount: _visibleItems.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final submission = _visibleItems[index];
                            return _SubmissionCard(
                              submission: submission,
                              onTap: () => context.pushNamed(
                                'customer-history-detail',
                                pathParameters: {'submissionId': submission.id},
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HistoryAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
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
    title: const Text(
      'RIWAYAT PENGAJUAN',
      style: TextStyle(
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
  );
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({required this.total, required this.replied});

  final int total;
  final int replied;

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
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.history_rounded,
            color: AppColors.primaryColor,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Riwayat Customer Service',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: Color(0xFF1E293B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$total pengajuan • $replied sudah dibalas',
                style: const TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: Color(0xFF64748B),
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

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.primaryColor : Colors.white,
    shape: StadiumBorder(
      side: BorderSide(
        color: selected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
      ),
    ),
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: selected ? Colors.white : const Color(0xFF334155),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.submission, required this.onTap});

  final CustomerServiceSubmission submission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFeedback =
        submission.type == CustomerServiceSubmissionType.feedback;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF1F5F9)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isFeedback
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isFeedback
                      ? Icons.rate_review_outlined
                      : Icons.report_problem_outlined,
                  color: isFeedback
                      ? const Color(0xFF2563EB)
                      : AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            submission.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              color: Color(0xFF1E293B),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(hasReply: submission.hasReply),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      submission.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: Color(0xFF64748B),
                        fontSize: 10.5,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          isFeedback ? 'Masukan' : 'Kendala',
                          style: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            color: AppColors.primaryColor,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '  •  ',
                          style: TextStyle(color: Color(0xFFCBD5E1)),
                        ),
                        Expanded(
                          child: Text(
                            formatCustomerServiceDate(submission.createdAt),
                            style: const TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              color: Color(0xFF94A3B8),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFCBD5E1),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.hasReply});

  final bool hasReply;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: hasReply ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: hasReply ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
      ),
    ),
    child: Text(
      hasReply ? 'Dibalas' : 'Menunggu',
      style: TextStyle(
        fontFamily: AppFonts.primaryFont,
        color: hasReply ? const Color(0xFF059669) : const Color(0xFFD97706),
        fontSize: 8,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Belum ada riwayat pengajuan',
      style: TextStyle(
        fontFamily: AppFonts.primaryFont,
        color: Color(0xFF64748B),
        fontSize: 11,
      ),
    ),
  );
}

String formatCustomerServiceDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day ${months[date.month - 1]} ${date.year}, $hour:$minute';
}
