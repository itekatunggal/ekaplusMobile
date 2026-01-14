// lib/features/member/data/models/branch_model.dart

class BranchModel {
  final String id;
  final String name;
  final String address;
  final String daerah;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.daerah,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      address: json['address'] as String,
      daerah: json['daerah'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'daerah': daerah,
    };
  }
}
