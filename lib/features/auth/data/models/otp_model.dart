// lib/features/auth/data/models/otp_model.dart
import 'package:equatable/equatable.dart';

class OtpModel extends Equatable {
  final String phone;
  final String otp;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;

  const OtpModel({
    required this.phone,
    required this.otp,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
  });

  // Getter untuk memeriksa validitas OTP
  bool get isValid => !isUsed && expiresAt.isAfter(DateTime.now());
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      phone: json['phone'] as String,
      otp: json['otp'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isUsed: json['is_used'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_used': isUsed,
    };
  }

  OtpModel copyWith({
    String? phone,
    String? otp,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUsed,
  }) {
    return OtpModel(
      phone: phone ?? this.phone,
      otp: otp ?? this.otp,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  @override
  List<Object?> get props => [phone, otp, createdAt, expiresAt, isUsed];
}