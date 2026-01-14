// lib/features/auth/data/models/update_profile_request_model.dart
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/update_profile_request.dart';

class UpdateProfileRequestModel extends UpdateProfileRequest {
  UpdateProfileRequestModel({
    super.fullName,
    super.phone,
    super.email,
    super.password,
    super.verificationCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (verificationCode != null) data['verification_code'] = verificationCode;
    
    return data;
  }
}