class LoyaltyPointBucket {
  const LoyaltyPointBucket({
    required this.earnedPoint,
    required this.usedPoint,
    required this.reservedPoint,
    required this.availablePoint,
    this.validFrom,
    this.validTo,
    required this.expired,
    required this.ready,
  });

  final int earnedPoint;
  final int usedPoint;
  final int reservedPoint;
  final int availablePoint;
  final DateTime? validFrom;
  final DateTime? validTo;
  final bool expired;
  final bool ready;

  factory LoyaltyPointBucket.fromJson(Map<String, dynamic> json) {
    return LoyaltyPointBucket(
      earnedPoint: _asInt(json['earned_point']),
      usedPoint: _asInt(json['used_point']),
      reservedPoint: _asInt(json['reserved_point']),
      availablePoint: _asInt(json['available_point']),
      validFrom: _asDate(json['valid_from']),
      validTo: _asDate(json['valid_to']),
      expired: _asBool(json['expired']),
      ready: json['ready'] == null ? true : _asBool(json['ready']),
    );
  }
}

class LoyaltyBalance {
  const LoyaltyBalance({
    required this.totalPoint,
    required this.redeemedPoint,
    required this.reservedPoint,
    required this.availablePoint,
    required this.buckets,
  });

  final int totalPoint;
  final int redeemedPoint;
  final int reservedPoint;
  final int availablePoint;
  final List<LoyaltyPointBucket> buckets;

  factory LoyaltyBalance.fromJson(Map<String, dynamic> json) {
    final rows = json['buckets'];
    return LoyaltyBalance(
      totalPoint: _asInt(json['total_point']),
      redeemedPoint: _asInt(json['redeemed_point']),
      reservedPoint: _asInt(json['reserved_point']),
      availablePoint: _asInt(json['available_point']),
      buckets: rows is List
          ? rows
                .whereType<Map>()
                .map(
                  (row) => LoyaltyPointBucket.fromJson(
                    Map<String, dynamic>.from(row),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }
}

class LoyaltyEarningDetail {
  const LoyaltyEarningDetail({
    required this.account,
    required this.category,
    required this.purchaseAmount,
    required this.pointDivider,
    required this.awardedPoint,
    this.calculationId,
  });

  final String account;
  final String category;
  final num purchaseAmount;
  final num pointDivider;
  final int awardedPoint;
  final int? calculationId;

  factory LoyaltyEarningDetail.fromJson(Map<String, dynamic> json) {
    final account = _asText(
      json['account'] ?? json['category'],
      fallback: 'Kategori pembelian',
    );
    return LoyaltyEarningDetail(
      account: account,
      category: account.replaceFirst(
        RegExp(r'^Penjualan\s+', caseSensitive: false),
        '',
      ),
      purchaseAmount: _asNum(json['purchase_amount'] ?? json['omzet_snapshot']),
      pointDivider: _asNum(
        json['point_divider'] ?? json['standard_divider_snapshot'],
      ),
      awardedPoint: _asInt(json['awarded_point']),
      calculationId: _asNullableInt(json['calculation_id']),
    );
  }
}

class LoyaltyEarnings {
  const LoyaltyEarnings({
    required this.periodName,
    required this.totalPoint,
    required this.rows,
  });

  final String periodName;
  final int totalPoint;
  final List<LoyaltyEarningDetail> rows;

  factory LoyaltyEarnings.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'];
    final parsed = rows is List
        ? rows
              .whereType<Map>()
              .map(
                (row) => LoyaltyEarningDetail.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .where((row) => row.purchaseAmount > 0)
              .toList(growable: false)
        : <LoyaltyEarningDetail>[];
    return LoyaltyEarnings(
      periodName: _asText(json['period_name'], fallback: 'Periode berjalan'),
      totalPoint: _asInt(json['total_point']),
      rows: parsed,
    );
  }
}

class LoyaltyLedger {
  const LoyaltyLedger({
    required this.calculationId,
    required this.calculationName,
    required this.earnedPoint,
    required this.periodName,
    required this.ready,
    required this.expired,
    this.validFrom,
    this.validTo,
  });

  final int calculationId;
  final String calculationName;
  final int earnedPoint;
  final String periodName;
  final bool ready;
  final bool expired;
  final DateTime? validFrom;
  final DateTime? validTo;

  factory LoyaltyLedger.fromJson(Map<String, dynamic> json) => LoyaltyLedger(
    calculationId: _asInt(json['calculation_id']),
    calculationName: _asText(json['calculation_name']),
    earnedPoint: _asInt(json['earned_point']),
    periodName: _asText(json['period_name'], fallback: 'Periode berjalan'),
    ready: _asBool(json['ready']),
    expired: _asBool(json['expired']),
    validFrom: _asDate(json['valid_from']),
    validTo: _asDate(json['valid_to']),
  );
}

class LoyaltyPurchaseSource {
  const LoyaltyPurchaseSource({
    required this.account,
    required this.purchaseAmount,
    required this.branchId,
    required this.bcReference,
    required this.customerCount,
    required this.calculationId,
    this.customerGroupName,
    this.branchCity,
  });

  final String account;
  final num purchaseAmount;
  final int? branchId;
  final String bcReference;
  final int customerCount;
  final int calculationId;
  final String? customerGroupName;
  final String? branchCity;

  LoyaltyPurchaseSource copyWith({
    String? customerGroupName,
    String? branchCity,
  }) => LoyaltyPurchaseSource(
    account: account,
    purchaseAmount: purchaseAmount,
    branchId: branchId,
    bcReference: bcReference,
    customerCount: customerCount,
    calculationId: calculationId,
    customerGroupName: customerGroupName ?? this.customerGroupName,
    branchCity: branchCity ?? this.branchCity,
  );

  factory LoyaltyPurchaseSource.fromJson(Map<String, dynamic> json) =>
      LoyaltyPurchaseSource(
        account: _asText(json['account']),
        purchaseAmount: _asNum(json['omzet']),
        branchId: _asNullableInt(json['branch_id']),
        bcReference: _asText(json['bc_refs'], fallback: '-'),
        customerCount: _asInt(json['customer_count']),
        calculationId: _asInt(json['calculation_id']),
      );
}

class LoyaltyReward {
  const LoyaltyReward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointRequired,
    this.imageUrl,
    this.available = true,
  });

  final String id;
  final String name;
  final String description;
  final int pointRequired;
  final String? imageUrl;
  final bool available;

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: _asText(json['reward_id'] ?? json['id'] ?? json['name']),
      name: _asText(
        json['reward_name'] ?? json['title'] ?? json['name'],
        fallback: 'Reward Ekaplus',
      ),
      description: _asText(json['description']),
      pointRequired: _asInt(
        json['point_required'] ?? json['required_point'] ?? json['point'],
      ),
      imageUrl: _nullableText(json['image'] ?? json['image_url']),
      available: json['available'] == null ? true : _asBool(json['available']),
    );
  }
}

enum LoyaltyRedemptionStatus { pending, approved, rejected, unknown }

class LoyaltyRedemption {
  const LoyaltyRedemption({
    required this.id,
    required this.name,
    required this.status,
    required this.pointUsed,
    required this.rewardName,
    this.rewardType,
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final String name;
  final LoyaltyRedemptionStatus status;
  final int pointUsed;
  final String rewardName;
  final String? rewardType;
  final DateTime? createdAt;
  final DateTime? completedAt;

  factory LoyaltyRedemption.fromJson(Map<String, dynamic> json) {
    return LoyaltyRedemption(
      id: _asText(json['redemption_id'] ?? json['id']),
      name: _asText(json['redemption_name'] ?? json['name'], fallback: '-'),
      status: parseRedemptionStatus(json['status']),
      pointUsed: _asInt(json['point_used']),
      rewardName: _asText(
        json['reward_name'] ?? json['reward_name_snapshot'],
        fallback: 'Reward Ekaplus',
      ),
      rewardType: _nullableText(
        json['reward_type'] ?? json['reward_type_snapshot'],
      ),
      createdAt: _asDate(json['created_at']),
      completedAt: _asDate(json['completed_at']),
    );
  }
}

LoyaltyRedemptionStatus parseRedemptionStatus(dynamic value) {
  switch (value?.toString().trim().toUpperCase()) {
    case 'PENDING':
      return LoyaltyRedemptionStatus.pending;
    case 'APPROVED':
      return LoyaltyRedemptionStatus.approved;
    case 'REJECTED':
      return LoyaltyRedemptionStatus.rejected;
    default:
      return LoyaltyRedemptionStatus.unknown;
  }
}

int _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

num _asNum(dynamic value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
bool _asBool(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';
DateTime? _asDate(dynamic value) => DateTime.tryParse(value?.toString() ?? '');
String _asText(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _nullableText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
