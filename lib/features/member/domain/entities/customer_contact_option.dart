import 'package:equatable/equatable.dart';

class CustomerContactOption extends Equatable {
  final int id;
  final String? name;
  final String? fullName;
  final String? phone;
  final String? email;

  const CustomerContactOption({
    required this.id,
    this.name,
    this.fullName,
    this.phone,
    this.email,
  });

  String get displayLabel {
    final full = (fullName ?? '').trim();
    if (full.isNotEmpty) return full;
    final short = (name ?? '').trim();
    if (short.isNotEmpty) return short;
    return 'Contact #$id';
  }

  @override
  List<Object?> get props => [id, name, fullName, phone, email];
}

