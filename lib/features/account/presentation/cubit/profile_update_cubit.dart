// lib/features/account/presentation/cubit/profile_update_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_full_name.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_username.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_phone_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_phone_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_email_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_email_change.dart';

part 'profile_update_state.dart';

class ProfileUpdateCubit extends Cubit<ProfileUpdateState> {
  final UpdateFullName updateFullName;
  final UpdateUsername updateUsername;
  final RequestPhoneChange requestPhoneChange;
  final VerifyPhoneChange verifyPhoneChange;
  final RequestEmailChange requestEmailChange;
  final VerifyEmailChange verifyEmailChange;

  ProfileUpdateCubit({
    required this.updateFullName,
    required this.updateUsername,
    required this.requestPhoneChange,
    required this.verifyPhoneChange,
    required this.requestEmailChange,
    required this.verifyEmailChange,
  }) : super(ProfileUpdateInitial());

  // Update Full Name
  Future<void> updateName({
    required String userId,
    required String fullName,
  }) async {
    emit(ProfileUpdateLoading());
    
    final result = await updateFullName(
      userId: userId,
      fullName: fullName,
    );
    
    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message.toString())),
      (user) => emit(ProfileUpdateSuccess(user, 'Nama berhasil diubah')),
    );
  }

  Future<void> updateUsernameValue({
    required String userId,
    required String username,
  }) async {
    emit(ProfileUpdateLoading());

    final result = await updateUsername(
      userId: userId,
      username: username,
    );

    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message.toString())),
      (user) => emit(ProfileUpdateSuccess(user, 'Username berhasil diubah')),
    );
  }

  // Request Phone Change (Step 1)
  Future<void> requestPhoneUpdate({
    required String userId,
    required String newPhone,
    required String password,
  }) async {
    emit(ProfileUpdateLoading());
    
    final result = await requestPhoneChange(
      userId: userId,
      newPhone: newPhone,
      password: password,
    );
    
    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message.toString())),
      (message) => emit(ProfileUpdateAwaitingVerification(
        message: message,
        pendingPhone: newPhone,
      )),
    );
  }

  // Verify Phone Change (Step 2)
  Future<void> verifyPhoneUpdate({
    required String userId,
    required String newPhone,
    required String verificationCode,
  }) async {
    emit(ProfileUpdateLoading());
    
    final result = await verifyPhoneChange(
      userId: userId,
      newPhone: newPhone,
      verificationCode: verificationCode,
    );
    
    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message.toString())),
      (user) => emit(ProfileUpdateSuccess(user, 'Nomor telepon berhasil diubah')),
    );
  }

  // Request Email Change (Step 1)
  Future<void> requestEmailUpdate({
    required String userId,
    required String newEmail,
    required String password,
  }) async {
    emit(ProfileUpdateLoading());
    
    final result = await requestEmailChange(
      userId: userId,
      newEmail: newEmail,
      password: password,
    );
    
    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message.toString())),
      (message) => emit(ProfileUpdateAwaitingVerification(
        message: message,
        pendingEmail: newEmail,
      )),
    );
  }

  // Verify Email Change (Step 2)
  Future<void> verifyEmailUpdate({
    required String userId,
    required String newEmail,
    required String verificationCode,
  }) async {
    emit(ProfileUpdateLoading());

    final result = await verifyEmailChange(
      userId: userId,
      newEmail: newEmail,
      verificationCode: verificationCode,
    );

    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message.toString().toString())),
      (user) => emit(ProfileUpdateSuccess(user, 'Email berhasil diubah')),
    );
  }

  // Request Initial Email Verification (untuk email yang belum terverifikasi)
  Future<void> requestInitialEmailVerification({
    required String userId,
    required String email,
  }) async {
    emit(ProfileUpdateLoading());

    // Reuse requestEmailChange tapi tanpa password (untuk initial verification)
    final result = await requestEmailChange(
      userId: userId,
      newEmail: email,
      password: '', // Empty password untuk initial verification
    );

    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message.toString())),
      (message) => emit(ProfileUpdateAwaitingVerification(
        message: message,
        pendingEmail: email,
      )),
    );
  }

  // Verify Initial Email (untuk email yang belum terverifikasi)
  Future<void> verifyInitialEmail({
    required String userId,
    required String email,
    required String verificationCode,
  }) async {
    emit(ProfileUpdateLoading());

    final result = await verifyEmailChange(
      userId: userId,
      newEmail: email,
      verificationCode: verificationCode,
    );

    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message.toString())),
      (user) => emit(ProfileUpdateSuccess(user, 'Email berhasil diverifikasi')),
    );
  }

  void reset() {
    emit(ProfileUpdateInitial());
  }
}

