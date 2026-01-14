// lib/features/auth/domain/entities/otp.dart
import 'package:equatable/equatable.dart';

class Otp extends Equatable {
  final String phone;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;

  const Otp({
    required this.phone,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
  });

  // Getter untuk memeriksa validitas OTP
  bool get isValid => !isUsed && expiresAt.isAfter(DateTime.now());
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  // Getter untuk sisa waktu berlaku (dalam detik)
  int get remainingSeconds {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inSeconds;
  }

  @override
  List<Object?> get props => [phone, code, createdAt, expiresAt, isUsed];
}