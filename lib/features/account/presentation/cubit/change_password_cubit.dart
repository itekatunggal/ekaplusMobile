// lib/features/account/presentation/cubit/change_password_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_old_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/change_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/reset_password_with_otp.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final VerifyOldPassword verifyOldPassword;
  final ChangePassword changePassword;
  final ResetPasswordWithOtp resetPasswordWithOtp;

  ChangePasswordCubit({
    required this.verifyOldPassword,
    required this.changePassword,
    required this.resetPasswordWithOtp,
  }) : super(ChangePasswordInitial());

  // Step 1: Verify old password
  Future<void> verifyOld({
    required String userId,
    required String oldPassword,
  }) async {
    emit(ChangePasswordLoading());

    final result = await verifyOldPassword(
      userId: userId,
      oldPassword: oldPassword,
    );

    result.fold(
      (failure) => emit(ChangePasswordError(failure.message.toString())),
      (isValid) => emit(ChangePasswordOldVerified()),
    );
  }

  // Step 2: Change password (normal flow with old password)
  Future<void> updatePassword({
    required String userId,
    required String newPassword,
    required String oldPassword,
  }) async {
    emit(ChangePasswordLoading());

    final result = await changePassword(
      newPassword: newPassword,
      oldPassword: oldPassword,
    );

    result.fold(
      (failure) => emit(ChangePasswordError(failure.message.toString())),
      (user) => emit(ChangePasswordSuccess(user, 'Password berhasil diubah')),
    );
  }

  // Step 3: Reset password (forgot password flow after OTP)
  Future<void> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    emit(ChangePasswordLoading());

    final result = await resetPasswordWithOtp(
      phone: phone,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(ChangePasswordError(failure.message.toString())),
      (user) => emit(ChangePasswordSuccess(user, 'Password berhasil direset')),
    );
  }

  void reset() {
    emit(ChangePasswordInitial());
  }
}
