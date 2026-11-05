// lib/injection.dart
import 'package:ekaplus_ekatunggal/core/constants.dart'; // Import Constants
import 'package:ekaplus_ekatunggal/features/auth/data/datasources/google_auth_service.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/change_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/check_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/get_user_info.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/login_with_google.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/reset_password_with_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/save_login_user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_profile_picture.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_full_name.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_personal_profile.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_username.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_phone_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_old_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_phone_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_email_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_email_change.dart';
import 'package:ekaplus_ekatunggal/features/banner/data/datasources/banner_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/banner/data/repositories/banner_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/repository/banner_repository.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/usecases/get_all_banner.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/usecases/get_banner.dart';
import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/data/repositories/branch_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/repositories/branch_repository.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/usecases/get_all_branches.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/usecases/get_branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_by_type.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/bulk_delete_wishlist.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

// AUTH
import 'package:ekaplus_ekatunggal/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/repositories/auth_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/check_phone_exists.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/login_user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';

// MEMBER
import 'package:ekaplus_ekatunggal/features/member/data/datasources/member_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/member/data/repositories/member_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_all_member_registrations.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/save_member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/update_member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_member_registration_by_id.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/delete_member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_member_registrations_by_user_id.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_member_registrations_by_status.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_approved_gcids.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_active_member_companies_by_user_id.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/member_registration_cubit.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';

// CATEGORY
import 'package:ekaplus_ekatunggal/features/category/data/datasources/category_remote_datasource.dart';

import 'package:ekaplus_ekatunggal/features/category/data/repositories/category_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/repositories/category_repository.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_all_category.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';

// PRODUCT
import 'package:ekaplus_ekatunggal/features/product/data/datasources/product_remote_datasource.dart';

import 'package:ekaplus_ekatunggal/features/product/data/repositories/product_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_all_product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_hot_deals.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';

// TYPE
import 'package:ekaplus_ekatunggal/features/type/data/datasources/type_remote_datasource.dart';

import 'package:ekaplus_ekatunggal/features/type/data/repositories/type_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/repositories/type_repository.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/usecases/get_all_type.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/usecases/get_type.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';

// BRANCH
import 'package:ekaplus_ekatunggal/features/branch/data/datasources/branch_remote_datasource.dart';

// WISHLIST
import 'package:ekaplus_ekatunggal/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/data/repositories/wishlist_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/check_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/get_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/toggle_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';

final myinjection = GetIt.instance;

Future<void> init() async {
  // ============================================
  // 🔥 GOOGLE AUTH SERVICE - HARUS PERTAMA!
  // ============================================
  final googleAuthService = GoogleAuthService();
  await googleAuthService.init(serverClientId: Constants.googleServerClientId);
  myinjection.registerLazySingleton<GoogleAuthService>(() => googleAuthService);

  // ============================================
  // SINGLETONS (Global State - Persists Across Navigation)
  // ============================================

  // Auth Session Cubit
  myinjection.registerLazySingleton<AuthSessionCubit>(
    () => AuthSessionCubit(
      saveLoginUser: myinjection(),
      getUserInfo: myinjection(),
      getActiveMemberCompaniesByUserId: myinjection(),
    ),
  );

  myinjection.registerLazySingleton<ActiveCompanyCubit>(
    () => ActiveCompanyCubit(getActiveMemberCompaniesByUserId: myinjection()),
  );

  // ProductBloc as Singleton
  myinjection.registerLazySingleton<ProductBloc>(
    () => ProductBloc(
      getAllProduct: myinjection(),
      getProduct: myinjection(),
      getHotDeals: myinjection(),
    ),
  );

  // WishlistBloc as Singleton
  myinjection.registerLazySingleton<WishlistBloc>(
    () => WishlistBloc(
      getWishlist: myinjection(),
      toggleWishlist: myinjection(),
      checkWishlist: myinjection(),
      bulkDeleteWishlist: myinjection(),
    ),
  );

  // ============================================
  // GENERAL DEPENDENCIES
  // ============================================
  myinjection.registerLazySingleton(() => http.Client());

  myinjection.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  myinjection.registerLazySingleton<Box>(() => Hive.box('auth_user_box'));

  // ============================================
  // DATA SOURCES
  // ============================================
  myinjection.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthLocalDataSourceImpl(
      myinjection<FlutterSecureStorage>(),
      myinjection<Box>(),
    ),
  );

  myinjection.registerLazySingleton<CategoryRemoteDatasource>(
    () => CategoryRemoteDatasourceImplementation(
      client: myinjection<http.Client>(),
    ),
  );

  myinjection.registerLazySingleton<BannerRemoteDatasource>(
    () => BannerRemoteDatasourceImplementation(
      client: myinjection<http.Client>(),
    ),
  );
  myinjection.registerLazySingleton<BranchRemoteDatasource>(
    () => BranchRemoteDatasourceImplementation(
      client: myinjection<http.Client>(),
    ),
  );

  myinjection.registerLazySingleton<SaveLoginUser>(
    () => SaveLoginUser(myinjection()),
  );

  myinjection.registerLazySingleton<GetUserInfo>(
    () => GetUserInfo(myinjection()),
  );

  myinjection.registerLazySingleton<TypeRemoteDatasource>(
    () => TypeRemoteDatasourceImpl(client: myinjection()),
  );

  myinjection.registerLazySingleton<WishlistRemoteDataSource>(
    () => WishlistLocalDataSourceImpl(client: myinjection()),
  );

  myinjection.registerLazySingleton<MemberRemoteDataSource>(
    () => MemberRemoteDataSourceImpl(client: myinjection()),
  );
  myinjection.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDatasourceImplementation(client: myinjection()),
  );

  // ============================================
  // REPOSITORIES
  // ============================================
  myinjection.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplementation(localDataSource: myinjection()),
  );

  myinjection.registerLazySingleton<TypeRepository>(
    () => TypeRepositoryImplementation(typeRemoteDatasource: myinjection()),
  );

  myinjection.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImplementation(
      categoryRemoteDatasource: myinjection(),
    ),
  );

  myinjection.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImplementation(bannerRemoteDatasource: myinjection()),
  );

  myinjection.registerLazySingleton<BranchRepository>(
    () => BranchRepositoryImplementation(branchRemoteDatasource: myinjection()),
  );

  myinjection.registerLazySingleton<ProductRepository>(
    () =>
        ProductRepositoryImplementation(productRemoteDatasource: myinjection()),
  );

  myinjection.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(remoteDataSource: myinjection()),
  );

  myinjection.registerLazySingleton<MemberRepository>(
    () => MemberRepositoryImplementation(remoteDataSource: myinjection()),
  );

  // ============================================
  // USE CASES
  // ============================================

  // Auth UseCases
  myinjection.registerLazySingleton(() => CheckPhoneExists(myinjection()));
  myinjection.registerLazySingleton(() => RequestOtp(myinjection()));
  myinjection.registerLazySingleton(() => VerifyOtp(myinjection()));
  myinjection.registerLazySingleton(() => RegisterUser(myinjection()));
  myinjection.registerLazySingleton(() => LoginUser(myinjection()));
  myinjection.registerLazySingleton(() => LoginWithGoogle(myinjection()));
  myinjection.registerLazySingleton(() => CheckPassword(myinjection()));
  myinjection.registerLazySingleton(() => UpdateProfilePicture(myinjection()));
  myinjection.registerLazySingleton(() => UpdateFullName(myinjection()));
  myinjection.registerLazySingleton(() => UpdatePersonalProfile(myinjection()));
  myinjection.registerLazySingleton(() => UpdateUsername(myinjection()));
  myinjection.registerLazySingleton(() => RequestPhoneChange(myinjection()));
  myinjection.registerLazySingleton(() => VerifyPhoneChange(myinjection()));
  myinjection.registerLazySingleton(() => RequestEmailChange(myinjection()));
  myinjection.registerLazySingleton(() => VerifyEmailChange(myinjection()));
  myinjection.registerLazySingleton(() => VerifyOldPassword(myinjection()));
  myinjection.registerLazySingleton(() => ChangePassword(myinjection()));
  myinjection.registerLazySingleton(() => ResetPasswordWithOtp(myinjection()));

  // Type UseCases
  myinjection.registerLazySingleton(() => GetAllType(myinjection()));
  myinjection.registerLazySingleton(() => GetType(myinjection()));

  // Category UseCases
  myinjection.registerLazySingleton(() => GetAllCategory(myinjection()));
  myinjection.registerLazySingleton(() => GetByType(myinjection()));
  myinjection.registerLazySingleton(() => GetCategory(myinjection()));

  // Banner UseCases
  myinjection.registerLazySingleton(() => GetAllBanner(myinjection()));
  myinjection.registerLazySingleton(() => GetBanner(myinjection()));

  // Branch UseCases
  myinjection.registerLazySingleton(() => GetAllBranches(myinjection()));
  myinjection.registerLazySingleton(() => GetBranch(myinjection()));

  // Product UseCases
  myinjection.registerLazySingleton(() => GetAllProduct(myinjection()));
  myinjection.registerLazySingleton(() => GetProduct(myinjection()));

  myinjection.registerLazySingleton(() => GetHotDeals(myinjection()));

  // Wishlist UseCases
  myinjection.registerLazySingleton(() => GetWishlist(myinjection()));
  myinjection.registerLazySingleton(() => ToggleWishlist(myinjection()));
  myinjection.registerLazySingleton(() => CheckWishlist(myinjection()));
  myinjection.registerLazySingleton(() => BulkDeleteWishlist(myinjection()));
  myinjection.registerLazySingleton(() => RegisterOtp(myinjection()));

  // Member UseCases
  myinjection.registerLazySingleton(
    () => GetAllMemberRegistrations(myinjection()),
  );
  myinjection.registerLazySingleton(
    () => SaveMemberRegistration(myinjection()),
  );
  myinjection.registerLazySingleton(
    () => UpdateMemberRegistration(myinjection()),
  );
  myinjection.registerLazySingleton(
    () => GetMemberRegistrationById(myinjection()),
  );
  myinjection.registerLazySingleton(
    () => DeleteMemberRegistration(myinjection()),
  );
  myinjection.registerLazySingleton(
    () => GetMemberRegistrationsByUserId(myinjection()),
  );
  myinjection.registerLazySingleton(
    () => GetMemberRegistrationsByStatus(myinjection()),
  );
  myinjection.registerLazySingleton(() => GetApprovedGCIDs(myinjection()));
  myinjection.registerLazySingleton(
    () => GetActiveMemberCompaniesByUserId(myinjection()),
  );

  // ============================================
  // FACTORY BLOCS (Per Widget - Short-lived)
  // ============================================

  myinjection.registerFactory(
    () => AuthBloc(
      checkPassword: myinjection(),
      checkPhoneExists: myinjection(),
      requestOtp: myinjection(),
      changePassword: myinjection(),
      verifyOtp: myinjection(),
      registerUser: myinjection(),
      loginUser: myinjection(),
      loginWithGoogle: myinjection(),
      updateProfilePicture: myinjection(),
      googleAuthService: myinjection(), // ✅ Sekarang sudah terdaftar di atas
      registerOtp: myinjection(), // ✅ Sekarang sudah terdaftar di atas
    ),
  );

  myinjection.registerFactory(() => OtpTimerBloc());

  myinjection.registerFactory(
    () => TypeBloc(getAllType: myinjection(), getType: myinjection()),
  );

  myinjection.registerFactory(
    () => CategoryBloc(
      getAllCategory: myinjection(),
      getCategory: myinjection(),
      getByType: myinjection(),
    ),
  );

  myinjection.registerFactory(
    () => BannerCubit(getAllBanner: myinjection(), getBanner: myinjection()),
  );

  myinjection.registerFactory(
    () => BranchCubit(getAllBranches: myinjection(), getBranch: myinjection()),
  );

  myinjection.registerFactory(
    () => MemberRegistrationCubit(
      getAllMemberRegistrations: myinjection(),
      saveMemberRegistration: myinjection(),
      updateMemberRegistration: myinjection(),
      getMemberRegistrationsByUserId: myinjection(),
      getApprovedGCIDs: myinjection(),
      getActiveMemberCompaniesByUserId: myinjection(),
      deleteMemberRegistration: myinjection(),
    ),
  );
}
