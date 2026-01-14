import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';

class BranchModel {
  static Branch fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      branchName: json['branch_name'],
      address: json['address'],
      city: json['city'],
      area: json['area'],
      island: json['island'],
      status: json['status'],
      disabled: json['disabled'] == 1,
      url: json['url'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }

  static List<Branch> fromJsonList(List<dynamic> list) {
    return list.map((e) => fromJson(e)).toList();
  }
}
