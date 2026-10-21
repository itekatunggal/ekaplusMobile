class CustomerCreditPolicy {
  const CustomerCreditPolicy({
    required this.bcid,
    required this.creditLimitLevel,
    required this.finalCreditLimit,
    required this.gcid,
    required this.gpid,
    required this.nbid,
    required this.totalLimitOutstanding,
    this.limitOwnerName,
    this.paymentTermDays,
  });

  final String bcid;
  final String creditLimitLevel;
  final double finalCreditLimit;
  final int? gcid;
  final int? gpid;
  final int? nbid;
  final double totalLimitOutstanding;
  final String? limitOwnerName;
  final int? paymentTermDays;

  String get normalizedCreditLimitLevel =>
      creditLimitLevel.trim().toLowerCase();

  bool get hasCreditLimit =>
      normalizedCreditLimitLevel != 'none' && finalCreditLimit > 0;

  String get creditLimitLevelLabel {
    switch (normalizedCreditLimitLevel) {
      case 'nbid':
        return 'National Brand';
      case 'gpid':
        return 'Group Parent';
      case 'gcid':
        return 'Group Customer';
      case 'bcid':
        return 'Branch Customer';
      default:
        final value = creditLimitLevel.trim();
        return value.isEmpty ? '-' : value;
    }
  }

  String get creditLimitSourceLabel {
    final ownerName = limitOwnerName?.trim();
    if (ownerName == null || ownerName.isEmpty) {
      return creditLimitLevelLabel;
    }
    return '$creditLimitLevelLabel • $ownerName';
  }

  String get limitOwnerFallback {
    switch (normalizedCreditLimitLevel) {
      case 'nbid':
        return nbid == null ? 'NBID' : 'NBID $nbid';
      case 'gpid':
        return gpid == null ? 'GPID' : 'GPID $gpid';
      case 'gcid':
        return gcid == null ? 'GCID' : 'GCID $gcid';
      case 'bcid':
        return bcid.isEmpty ? 'BCID' : 'BCID $bcid';
      default:
        return creditLimitLevel.trim().toUpperCase();
    }
  }

  CustomerCreditPolicy copyWith({
    String? limitOwnerName,
    int? paymentTermDays,
  }) {
    return CustomerCreditPolicy(
      bcid: bcid,
      creditLimitLevel: creditLimitLevel,
      finalCreditLimit: finalCreditLimit,
      gcid: gcid,
      gpid: gpid,
      nbid: nbid,
      totalLimitOutstanding: totalLimitOutstanding,
      limitOwnerName: limitOwnerName ?? this.limitOwnerName,
      paymentTermDays: paymentTermDays ?? this.paymentTermDays,
    );
  }

  double get remainingCredit =>
      (finalCreditLimit - totalLimitOutstanding).clamp(0, double.infinity);

  double get usedRatio {
    if (finalCreditLimit <= 0) return 0;
    return (totalLimitOutstanding / finalCreditLimit).clamp(0, 1);
  }

  factory CustomerCreditPolicy.fromJson(Map<String, dynamic> json) {
    return CustomerCreditPolicy(
      bcid: json['bcid']?.toString() ?? '',
      creditLimitLevel: json['credit_limit_level']?.toString() ?? '',
      finalCreditLimit: _toDouble(json['final_credit_limit']),
      gcid: _toInt(json['gcid']),
      gpid: _toInt(json['gpid']),
      nbid: _toInt(json['nbid']),
      totalLimitOutstanding: _toDouble(json['total_limit_outstanding']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
