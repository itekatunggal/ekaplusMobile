import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';

class BranchCredential {
  final String branchName;
  final String token;
  final String url;

  const BranchCredential({
    required this.branchName,
    required this.token,
    required this.url,
  });

  factory BranchCredential.fromJson(Map<String, dynamic> json) {
    return BranchCredential(
      branchName: json['branch_name'] ?? json['name'] ?? '',
      token: json['token'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class BranchCredentialService {
  Future<BranchCredential?> fetchCredential(String branchName) async {
    final spec = jsonEncode({
      "filters": [
        ["branch_name", "=", branchName]
      ],
      "fields": ["name", "branch_name", "token", "url"]
    });

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/branch?spec=${Uri.encodeComponent(spec)}',
    );

    try {
      final response = await http.get(uri, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List?;
        if (list != null && list.isNotEmpty) {
          return BranchCredential.fromJson(list.first);
        } else {
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
