import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, bool>> checkPhoneExists(String phone);

  Future<Either<Failure, String>> requestOtp(String phone, String method);

  Future<Either<Failure, String>> registerOtp(String phone);

  Future<Either<Failure, bool>> verifyOtp(
    String phone,
    String otp,
    String method,
  );

  Future<Either<Failure, User>> registerUser(RegisterUserParams params);
  Future<Either<Failure, User>> getUserInfo();

  Future<Either<Failure, User>> getUserByPhone(String phone);

  Future<Either<Failure, User>> loginUser(String identifier, String password);

  Future<Either<Failure, User>> loginWithGoogle(String idToken);

  Future<Either<Failure, User>> updateProfilePicture(
    String userId,
    String? profilePicPath,
    String? bgColor,
  );

  Future<Either<Failure, User>> updateFullName(String userId, String fullName);

  Future<Either<Failure, String>> requestPhoneChange({
    required String userId,
    required String newPhone,
    required String password,
  });

  Future<Either<Failure, User>> verifyPhoneChange({
    required String userId,
    required String newPhone,
    required String verificationCode,
  });

  Future<Either<Failure, String>> requestEmailChange({
    required String newEmail,
    required String password,
  });

  Future<void> saveLoginUser({required UserModel user});

  Future<Either<Failure, User>> verifyEmailChange({
    required String userId,
    required String newEmail,
    required String verificationCode,
  });

  Future<Either<Failure, bool>> checkPassword({required String password});

  Future<Either<Failure, bool>> verifyOldPassword({
    required String userId,
    required String oldPassword,
  });

  Future<Either<Failure, User>> changePassword({
    required String newPassword,
    required String oldPassword,
  });

  Future<Either<Failure, User>> resetPasswordWithOtp({
    required String phone,
    required String newPassword,
  });
}
