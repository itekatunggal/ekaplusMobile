import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:flutter/material.dart';

class TransactionListHeader extends StatelessWidget {
  const TransactionListHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterPressed,
    required this.hasActiveFilter,
  });

  final String title;
  final String subtitle;
  final String searchHint;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onFilterPressed;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomHeaderAppBar(
              title: title,
              subtitle: subtitle,
              brandStyle: true,
              height: 178,
              onBackPressed: () => Navigator.of(context).pop(),
              actions: [
                CustomHeaderActionButton(
                  tooltip: 'Filter',
                  onPressed: onFilterPressed,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                      if (hasActiveFilter)
                        const Positioned(
                          right: -2,
                          top: -2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(width: 7, height: 7),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x100F172A),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onChanged: onSearchChanged,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.primaryFont,
                ),
                decoration: InputDecoration(
                  hintText: searchHint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontFamily: AppFonts.primaryFont,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Hapus pencarian',
                          onPressed: onClearSearch,
                          splashRadius: 18,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF94A3B8),
                            size: 19,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionFilterResult {
  const TransactionFilterResult({this.startDate, this.endDate, this.status});

  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
}

Future<TransactionFilterResult?> showTransactionFilterSheet({
  required BuildContext context,
  required String title,
  required List<String> statuses,
  DateTime? startDate,
  DateTime? endDate,
  String? status,
}) {
  DateTime? draftStart = startDate;
  DateTime? draftEnd = endDate;
  String draftStatus = status ?? 'Semua';

  return showModalBottomSheet<TransactionFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        Future<void> pickDate({required bool isStart}) async {
          final now = DateTime.now();
          final selected = await showDatePicker(
            context: context,
            initialDate: (isStart ? draftStart : draftEnd) ?? now,
            firstDate: DateTime(2020),
            lastDate: DateTime(now.year + 2),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primaryColor,
                ),
              ),
              child: child!,
            ),
          );
          if (selected == null) return;
          setSheetState(() {
            if (isStart) {
              draftStart = selected;
            } else {
              draftEnd = selected;
            }
          });
        }

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(
                        sheetContext,
                        const TransactionFilterResult(),
                      ),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Rentang tanggal',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TransactionDateButton(
                        label: 'Dari',
                        date: draftStart,
                        onTap: () => pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TransactionDateButton(
                        label: 'Sampai',
                        date: draftEnd,
                        onTap: () => pickDate(isStart: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Status',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: statuses.map((item) {
                    final selected = item == draftStatus;
                    return ChoiceChip(
                      label: Text(item),
                      selected: selected,
                      onSelected: (_) =>
                          setSheetState(() => draftStatus = item),
                      showCheckmark: false,
                      selectedColor: const Color(0xFFFEF2F2),
                      backgroundColor: const Color(0xFFF8FAFC),
                      side: BorderSide(
                        color: selected
                            ? AppColors.primaryColor
                            : const Color(0xFFE2E8F0),
                      ),
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.primaryColor
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      TransactionFilterResult(
                        startDate: draftStart,
                        endDate: draftEnd,
                        status: draftStatus == 'Semua' ? null : draftStatus,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class TransactionDateButton extends StatelessWidget {
  const TransactionDateButton({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final value = date == null
        ? 'Pilih tanggal'
        : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}';
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 17,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10.5,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.primaryFont,
                      ),
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

class TransactionFilterSummary extends StatelessWidget {
  const TransactionFilterSummary({
    super.key,
    this.status,
    this.startDate,
    this.endDate,
    required this.onClearStatus,
    required this.onClearDates,
  });

  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onClearStatus;
  final VoidCallback onClearDates;

  String _format(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          if (status != null)
            _FilterChip(label: status!, onDeleted: onClearStatus),
          if (startDate != null || endDate != null)
            _FilterChip(
              label:
                  '${_format(startDate ?? endDate!)} – ${_format(endDate ?? startDate!)}',
              onDeleted: onClearDates,
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
          const SizedBox(width: 3),
          InkWell(
            onTap: onDeleted,
            borderRadius: BorderRadius.circular(99),
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionStateCard extends StatelessWidget {
  const TransactionStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D0F172A),
                blurRadius: 18,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.45,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(actionLabel!),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.documentNumber,
    required this.status,
    required this.statusColor,
    required this.customerCode,
    required this.customerName,
    required this.date,
    required this.total,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  final String documentNumber;
  final String status;
  final Color statusColor;
  final String customerCode;
  final String customerName;
  final String date;
  final String total;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C0F172A),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      documentNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 120),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.09),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      status.isEmpty ? '-' : status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoField(
                      icon: Icons.apartment_rounded,
                      label: 'Kode customer',
                      value: customerCode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoField(
                      icon: Icons.calendar_today_outlined,
                      label: 'Tanggal',
                      value: date,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _InfoField(
                      icon: Icons.person_outline_rounded,
                      label: 'Customer',
                      value: customerName,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10.5,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        total,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFCBD5E1),
                    size: 19,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10.5,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
