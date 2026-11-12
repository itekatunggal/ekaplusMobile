import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';

class BranchModel {
  static Branch fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      branchName: json['branch_name']?.toString() ?? '',
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      area: json['area']?.toString(),
      island: json['island']?.toString(),
      status: json['status']?.toString(),
      disabled: json['disabled'] == 1 || json['disabled']?.toString() == '1',
      url: json['url']?.toString(),
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
    );
  }

  static List<Branch> fromJsonList(List<dynamic> list) {
    return list.map((e) => fromJson(e)).toList();
  }
}
