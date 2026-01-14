import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_user.dart';

class AuthRepositoryImplementation implements AuthRepository {
  final AuthRemoteDataSource localDataSource;

  AuthRepositoryImplementation({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> checkPhoneExists(String phone) async {
    try {
      final exists = await localDataSource.checkPhoneExists(phone);
      return Right(exists);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestOtp(
    String phone,
    String method,
  ) async {
    try {
      final otp = await localDataSource.generateOtp(phone, method);
      return Right(otp);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> registerOtp(String phone) async {
    try {
      final otp = await localDataSource.registerOtp(phone);
      return Right(otp);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp(
    String phone,
    String otp,
    String method,
  ) async {
    try {
      final valid = await localDataSource.verifyOtp(phone, otp, method);
      return Right(valid);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> registerUser(RegisterUserParams params) async {
    try {
      final now = DateTime.now();

      final user = UserModel(
        id: 0,
        firstName: params.firstName,
        lastName: params.lastName,
        fullName: '${params.firstName} ${params.lastName}',
        username: params.username,
        email: params.email,
        phone: params.phone,
        isEmailVerified: false,
        isPhoneVerified: true,
        isSystem: false,
        gender: params.gender,
        dateOfBirth: params.dateOfBirth,
        placeOfBirth: params.birthPlace,
        password: params.password,
        profilePic: '',

        referralCode: '',
        referredBy: null,
        address: '',
        city: '',
        province: '',
        postalCode: '',
        country: '',
        googleId: '',
        googleAccessToken: '',
        googleRefreshToken: '',
        googleTokenExpiry: null,
        role: 'user',
        status: 1,
        workflowState: 'Active',
        tokenVersion: 0,
        lastLogin: null,
        createdBy: null,
        updatedBy: null,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.saveUser(user);
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginUser(
    String identifier,
    String password,
  ) async {
    try {
      final user = await localDataSource.login(identifier, password);
      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      final message = e.toString().isNotEmpty
          ? e.toString()
          : 'Terjadi kesalahan saat login';

      return Left(ServerFailure(message: message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle(String idToken) async {
    try {
      final user = await localDataSource.loginWithGoogle(idToken);
      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Terjadi kesalahan saat login Google'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> getUserByPhone(String phone) async {
    try {
      final user = await localDataSource.getCachedUser();
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateFullName(
    String userId,
    String fullName,
  ) async {
    try {
      final user = await localDataSource.getCachedUser();
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      final parts = fullName.trim().split(' ');
      final updated = user.copyWith(
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        fullName: fullName.trim(),
        updatedAt: DateTime.now(),
      );

      await localDataSource.updateUser(user.id, {
        'first_name': updated.firstName,
        'last_name': updated.lastName,
        'full_name': updated.fullName,
      });
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfilePicture(
    String userId,
    String? profilePicPath,
    String? bgColor,
  ) async {
    try {
      // Cek apakah profilePicPath adalah file lokal (untuk upload)
      final isLocalFile = profilePicPath != null &&
                         profilePicPath.isNotEmpty &&
                         !profilePicPath.startsWith('http') &&
                         !profilePicPath.startsWith('assets/') &&
                         !profilePicPath.startsWith('local:') &&
                         profilePicPath.contains('/');

      if (isLocalFile) {
        // Upload file ke server
        final updatedUser = await localDataSource.updateProfilePicture(profilePicPath);
        return Right(updatedUser);
      } else if (profilePicPath != null && profilePicPath.isEmpty) {
        // Delete foto profil dari server
        final updatedUser = await localDataSource.updateProfilePicture("");
        return Right(updatedUser);
      } else {
        // Untuk local avatar atau update UUID, update cache saja
        final user = await localDataSource.getCachedUser();
        if (user == null) {
          return const Left(CacheFailure(message: 'User tidak ditemukan'));
        }

        final updated = user.copyWith(
          profilePic: profilePicPath ?? '',
          updatedAt: DateTime.now(),
        );

        await localDataSource.updateUser(user.id, {
          'profile_pic': profilePicPath ?? '',
        });

        return Right(updated);
      }
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestPhoneChange({
    required String userId,
    required String newPhone,
    required String password,
  }) async {
    try {
      final exists = await localDataSource.checkPhoneExists(newPhone);
      if (exists) {
        return const Left(
          CacheFailure(message: 'Nomor handphone sudah digunakan'),
        );
      }

      final otp = await localDataSource.generateOtp(newPhone, "wa");
      return Right(otp);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyPhoneChange({
    required String userId,
    required String newPhone,
    required String verificationCode,
  }) async {
    try {
      // final valid = await localDataSource.verifyOtp(
      //   newPhone,
      //   verificationCode,
      //   "wa",
      // );
      // if (!valid) {
      //   return const Left(CacheFailure(message: 'Kode verifikasi tidak valid'));
      // }

      final user = await localDataSource.getCachedUser();
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      final updated = user.copyWith(
        phone: newPhone,
        isPhoneVerified: true,
        updatedAt: DateTime.now(),
      );

      await localDataSource.changePhone(newPhone, verificationCode);
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestEmailChange({
    required String newEmail,
    required String password,
  }) async {
    try {
      final otp = await localDataSource.generateOtp(newEmail, "email");
      return Right(otp);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyEmailChange({
    required String userId,
    required String newEmail,
    required String verificationCode,
  }) async {
    try {
      final user = await localDataSource.getCachedUser();
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      final updated = user.copyWith(
        email: newEmail,
        isEmailVerified: true,
        updatedAt: DateTime.now(),
      );

      await localDataSource.changeEmail(newEmail, verificationCode);
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> resetPasswordWithOtp({
    required String phone,
    required String newPassword,
  }) async {
    return const Left(
      CacheFailure(message: 'Password tidak dikelola di client'),
    );
  }

  @override
  Future<Either<Failure, bool>> verifyOldPassword({
    required String userId,
    required String oldPassword,
  }) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, User>> changePassword({
    required String newPassword,
    required String oldPassword,
  }) async {
    try {
      final user = await localDataSource.changePassword(
        oldPassword,
        newPassword,
      );
      return Right(user);
    } catch (e) {
      return Left(ValidationFailure(message: e.toString()));
    }
  }

  @override
  Future<void> saveLoginUser({required UserModel user}) {
    localDataSource.saveLoginUser(user);
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> checkPassword({
    required String password,
  }) async {
    try {
      final valid = await localDataSource.checkPassword(password);
      return Right(valid);
    } catch (e) {
      return Left(ValidationFailure(message: e.toString()));
    }
  }
}
