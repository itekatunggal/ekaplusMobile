import 'package:ekaplus_ekatunggal/features/auth/data/datasources/google_auth_service.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/change_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/check_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_otp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/check_phone_exists.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/update_profile_picture.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckPhoneExists checkPhoneExists;
  final CheckPassword checkPassword;
  final ChangePassword changePassword;
  final RequestOtp requestOtp;
  final RegisterOtp registerOtp;
  final VerifyOtp verifyOtp;
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final LoginWithGoogle loginWithGoogle;
  final UpdateProfilePicture updateProfilePicture;
  final GoogleAuthService googleAuthService;

  AuthBloc({
    required this.checkPhoneExists,
    required this.checkPassword,
    required this.requestOtp,
    required this.verifyOtp,
    required this.registerUser,
    required this.registerOtp,
    required this.loginUser,
    required this.loginWithGoogle,
    required this.changePassword,
    required this.updateProfilePicture,
    required this.googleAuthService,
  }) : super(AuthInitial()) {
    on<CheckPhoneEvent>(_onCheckPhone);
    on<CheckPhoneExistsEvent>(_onCheckPhoneExists);
    on<RequestOtpEvent>(_onRequestOtp);
    on<RegisterOtpEvent>(_onRegisterOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<UpdateProfilePictureEvent>(_onUpdateProfilePicture);
    on<ResetAuthEvent>(_onResetAuth);
    on<CheckPasswordEvent>(_onCheckPassword);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onCheckPhone(
    CheckPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkPhoneExists(event.phone);

    result.fold(
      (f) => emit(PhoneCheckError(f.message ?? 'Gagal mengecek nomor')),
      (exists) => emit(PhoneCheckSuccess(exists)),
    );
  }

  Future<void> _onCheckPhoneExists(
    CheckPhoneExistsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkPhoneExists(event.phone);

    result.fold((f) => emit(AuthError(f.message ?? 'Gagal mengecek nomor')), (
      exists,
    ) {
      if (exists) {
        emit(PhoneExistsState(true));
      } else {
        emit(const PhoneNotFoundError('Nomor handphone tidak terdaftar'));
      }
    });
  }

  Future<void> _onRegisterOtp(
    RegisterOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerOtp(event.phone);

    result.fold(
      (f) => emit(OtpRequestError(f.message ?? 'Gagal meminta OTP')),
      (otp) => emit(OtpRequestSuccess(otp: otp, phone: event.phone)),
    );
  }

  Future<void> _onRequestOtp(
    RequestOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await requestOtp(event.phone, "wa");

    result.fold(
      (f) => emit(OtpRequestError(f.message ?? 'Gagal meminta OTP')),
      (otp) => emit(OtpRequestSuccess(otp: otp, phone: event.phone)),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await verifyOtp(event.phone, event.otp, event.method);

    result.fold(
      (f) => emit(OtpVerificationError(f.message ?? 'Verifikasi gagal')),
      (isValid) {
        if (isValid) {
          emit(OtpVerificationSuccess(event.phone));
        } else {
          emit(const OtpVerificationError('OTP tidak valid'));
        }
      },
    );
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final params = RegisterUserParams(
      phone: event.phone,
      firstName: event.firstName,
      lastName: event.lastName,
      username: event.username,
      email: event.email,
      password: event.password,
      gender: event.gender,
      dateOfBirth: event.dateOfBirth,
      birthPlace: event.birthPlace,
    );

    final result = await registerUser(params);

    result.fold(
      (f) => emit(RegisterError(f.message ?? 'Registrasi gagal')),
      (user) => emit(RegisterSuccess(user)),
    );
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUser(event.identifier, event.password);

    result.fold(
      (f) => emit(LoginError(f.message ?? 'Login gagal')),
      (user) => emit(LoginSuccess(user)),
    );
  }

  // Future<void> _onLoginWithGoogle(
  //   LoginWithGoogleEvent event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   try {
  //     final idToken = await googleAuthService.loginAndGetIdToken();

  //     final result = await loginWithGoogle(idToken);

  //     result.fold(
  //       (f) => emit(LoginWithGoogleError(f.message ?? 'Login Google gagal')),
  //       (user) => emit(LoginWithGoogleSuccess(user)),
  //     );
  //   } catch (e) {
  //     emit(LoginWithGoogleError(e.toString()));
  //   }
  // }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final idToken = await googleAuthService.loginAndGetIdToken();

      final result = await loginWithGoogle(idToken);

      result.fold(
        (f) {
          emit(LoginWithGoogleError(f.message ?? 'Login Google gagal'));
        },
        (user) {
          emit(LoginWithGoogleSuccess(user));
        },
      );
    } catch (e) {
      await googleAuthService.logout();
      emit(LoginWithGoogleError('Login Google dibatalkan'));
    }
  }

  Future<void> _onUpdateProfilePicture(
    UpdateProfilePictureEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await updateProfilePicture(
      event.userId,
      event.profilePicPath,
      event.bgColor,
    );

    result.fold(
      (f) => emit(ProfilePictureUpdateError(f.message ?? 'Update gagal')),
      (user) => emit(ProfilePictureUpdateSuccess(user)),
    );
  }

  void _onResetAuth(ResetAuthEvent event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }

  Future<void> _onCheckPassword(
    CheckPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkPassword(password: event.password);

    result.fold(
      (f) => emit(AuthError(f.message ?? 'Gagal cek password')),
      (valid) => emit(PasswordCheckSuccess(valid)),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await changePassword(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (f) => emit(PasswordChangeError(f.message ?? 'Gagal ganti password')),
      (_) => emit(PasswordChangeSuccess()),
    );
  }
}
