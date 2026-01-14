import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  final int id;
  final String branchName;
  final String? address;
  final String? city;
  final String? area;
  final String? island;
  final String? status;
  final bool? disabled;
  final String? url;
  final String? lat;
  final String? lng;

  const Branch({
    required this.id,
    required this.branchName,
    this.address,
    this.city,
    this.area,
    this.island,
    this.status,
    this.disabled,
    this.url,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [
    id,
    branchName,
    address,
    city,
    area,
    island,
    status,
    disabled,
    url,
    lat,
    lng,
  ];
}
