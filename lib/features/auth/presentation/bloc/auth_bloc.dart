import 'package:ekaplus_ekatunggal/features/auth/data/datasources/google_auth_service.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/datasources/apple_auth_service.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/datasources/social_auth_exception.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/social_auth_result.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/complete_social_registration.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/login_with_apple.dart';
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
  final LoginWithApple loginWithApple;
  final CompleteSocialRegistration completeSocialRegistration;
  final UpdateProfilePicture updateProfilePicture;
  final GoogleAuthService googleAuthService;
  final AppleAuthService appleAuthService;

  AuthBloc({
    required this.checkPhoneExists,
    required this.checkPassword,
    required this.requestOtp,
    required this.verifyOtp,
    required this.registerUser,
    required this.registerOtp,
    required this.loginUser,
    required this.loginWithGoogle,
    required this.loginWithApple,
    required this.completeSocialRegistration,
    required this.changePassword,
    required this.updateProfilePicture,
    required this.googleAuthService,
    required this.appleAuthService,
  }) : super(AuthInitial()) {
    on<CheckPhoneEvent>(_onCheckPhone);
    on<CheckPhoneExistsEvent>(_onCheckPhoneExists);
    on<RequestOtpEvent>(_onRequestOtp);
    on<RegisterOtpEvent>(_onRegisterOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LoginWithAppleEvent>(_onLoginWithApple);
    on<CompleteSocialRegistrationEvent>(_onCompleteSocialRegistration);
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
    emit(const AuthLoading(AuthOperation.manualLogin));

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
    emit(const AuthLoading(AuthOperation.googleLogin));

    try {
      final idToken = await googleAuthService.loginAndGetIdToken();

      final result = await loginWithGoogle(idToken);

      result.fold(
        (f) {
          emit(
            LoginWithGoogleError(
              f.message ?? 'Login Google gagal',
              code: f.code,
            ),
          );
        },
        (result) {
          _emitSocialResult(
            result,
            emit,
            authenticatedProvider: SocialProvider.google,
          );
        },
      );
    } on SocialSignInCancelledException {
      emit(AuthInitial());
    } catch (_) {
      await googleAuthService.logout();
      emit(
        const LoginWithGoogleError('Login Google gagal. Silakan coba lagi.'),
      );
    }
  }

  Future<void> _onLoginWithApple(
    LoginWithAppleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(AuthOperation.appleLogin));
    try {
      final identityToken = await appleAuthService.loginAndGetIdentityToken();
      final result = await loginWithApple(identityToken);
      result.fold(
        (failure) => emit(
          LoginWithAppleError(
            failure.message ?? 'Login Apple gagal',
            code: failure.code,
          ),
        ),
        (socialResult) => _emitSocialResult(
          socialResult,
          emit,
          authenticatedProvider: SocialProvider.apple,
        ),
      );
    } on SocialSignInCancelledException {
      emit(AuthInitial());
    } catch (_) {
      emit(const LoginWithAppleError('Login Apple gagal. Silakan coba lagi.'));
    }
  }

  void _emitSocialResult(
    SocialAuthResult result,
    Emitter<AuthState> emit, {
    required SocialProvider authenticatedProvider,
  }) {
    switch (result) {
      case SocialLoginAuthenticated(:final user):
        if (authenticatedProvider == SocialProvider.apple) {
          emit(LoginWithAppleSuccess(user));
        } else {
          emit(LoginWithGoogleSuccess(user));
        }
      case SocialRegistrationPending(
        :final registrationToken,
        :final expiresIn,
        :final prefill,
        :final provider,
      ):
        emit(
          SocialRegistrationRequired(
            registrationToken: registrationToken,
            expiresIn: expiresIn,
            prefill: prefill,
            provider: provider,
          ),
        );
    }
  }

  Future<void> _onCompleteSocialRegistration(
    CompleteSocialRegistrationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(AuthOperation.completion));
    final result = await completeSocialRegistration(
      ticket: event.ticket,
      username: event.username,
      password: event.password,
    );
    result.fold(
      (failure) => emit(
        SocialRegistrationError(
          failure.message ?? 'Gagal menyelesaikan pendaftaran',
          code: failure.code,
        ),
      ),
      (user) => emit(SocialRegistrationCompleted(user)),
    );
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
