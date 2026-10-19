// lib/core/routes/my_router.dart
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/change_password_cubit.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/about_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/account_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/change_password_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_contact_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_full_name_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_username_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_profile_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/new_password_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/select_avatar_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/verify_contact_complete_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/verify_password_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/verify_email_initial_page.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/pages/member_registration_page.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/pages/member_list_page.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/pages/company_selection_page.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/pages/add_bcid_page.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/enums/member_registration_intent.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/change_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_email_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_phone_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/reset_password_with_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_full_name.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_personal_profile.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_username.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_email_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_old_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_phone_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/forgot_password_phone_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/login_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/register_form_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/register_page.dart';
import 'package:ekaplus_ekatunggal/features/search/presentation/bloc/search_bloc.dart';
import 'package:ekaplus_ekatunggal/features/search/presentation/pages/search_page.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:ekaplus_ekatunggal/features/report/presentation/pages/penjualan_page.dart';
import 'package:ekaplus_ekatunggal/features/transaksi/transaksi.dart';
import 'package:ekaplus_ekatunggal/features/customer/presentation/pages/customer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:ekaplus_ekatunggal/features/home/presentation/pages/home_page.dart';
import 'package:ekaplus_ekatunggal/features/home/presentation/pages/splash_screen_page.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/products_highlight_page.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';

import 'package:ekaplus_ekatunggal/core/shared_widgets/bottom_nav.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/exit_confirmation_wrapper.dart';
import 'package:ekaplus_ekatunggal/core/utils/global_navigator_key.dart';

final getIt = GetIt.instance;

CustomTransitionPage<void> _smoothPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      );
      final fadeOut = CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      );
      final scaleIn = Tween<double>(
        begin: 0.94,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
        child: FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(scale: scaleIn, child: pageChild),
        ),
      );
    },
  );
}

class MyRouter {
  GoRouter get router => GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: "/splash",
    // initialLocation: "/account",
    routes: [
      // ********** Splash Screen (tanpa bottom nav) **********
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (context, state) => const SplashScreenPage(),
      ),

      // ********** Routes dengan bottom nav **********
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(currentPath: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            name: 'home',
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            name: 'category',
            path: '/category',
            builder: (context, state) => const CategoryPage(),
          ),
          GoRoute(
            name: 'customer',
            path: '/customer',
            builder: (context, state) => const CustomerPage(),
          ),
          GoRoute(
            name: 'wishlist',
            path: '/wishlist',
            builder: (context, state) => const WishlistPage(),
          ),
          GoRoute(
            name: 'report',
            path: '/report',
            builder: (context, state) => const PenjualanPage(),
          ),
          // GoRoute(
          //   name: 'invoice',
          //   path: '/invoice',
          //   builder: (context, state) => const InvoicePage(),
          // ),
          GoRoute(
            name: 'transaksi',
            path: '/transaksi',
            builder: (context, state) => const TransaksiPage(),
          ),
          GoRoute(
            name: 'account',
            path: '/account',
            builder: (context, state) {
              return AccountPage();
            },
          ),
        ],
      ),

      // ********** Routes tanpa bottom nav *********

      // ============================================
      // AUTH ROUTES
      // ============================================
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterPage()),
      ),

      // ========== OTP VERIFICATION (REUSABLE) ==========
      // GoRoute(
      //   path: '/otp-verification',
      //   name: 'otp-verification',
      //   pageBuilder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>?;

      //     return MaterialPage(
      //       key: state.pageKey,
      //       child: MultiBlocProvider(
      //         providers: [
      //           BlocProvider(create: (context) => getIt<AuthBloc>()),
      //           BlocProvider(
      //             create: (context) =>
      //                 getIt<OtpTimerBloc>()
      //                   ..add(const StartOtpTimer(duration: 60)),
      //           ),
      //           // If cubit is passed (profile update flow), provide it
      //           if (extra?['cubit'] != null)
      //             BlocProvider.value(
      //               value: extra!['cubit'] as ProfileUpdateCubit,
      //             ),
      //         ],
      //         child: OtpVerificationPage(
      //           phoneNumber: extra?['phoneNumber'] as String? ?? '',
      //           title: extra?['title'] as String?,
      //           subtitle: extra?['subtitle'] as String?,
      //           nextRoute: extra?['nextRoute'] as String?,
      //           isPasswordReset: extra?['isPasswordReset'] as bool? ?? false,
      //           cubit: extra?['cubit'] as ProfileUpdateCubit?,
      //           userId: extra?['userId'] as String?,
      //           contactType: extra?['contactType'] as ContactType?,
      //         ),
      //       ),
      //     );
      //   },
      // ),

      // Legacy OTP route (untuk backward compatibility)
      GoRoute(
        path: '/otp',
        name: 'otp',
        pageBuilder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => getIt<AuthBloc>()),
                BlocProvider(
                  create: (context) =>
                      getIt<OtpTimerBloc>()
                        ..add(const StartOtpTimer(duration: 60)),
                ),
              ],
              child: OtpVerificationPage(phoneNumber: phoneNumber),
            ),
          );
        },
      ),

      // Register Form route (setelah OTP verified)
      GoRoute(
        path: '/registerForm',
        name: 'registerForm',
        pageBuilder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: RegisterFormPage(phoneNumber: phoneNumber),
          );
        },
      ),

      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) {
          return LoginPage();
        },
      ),

      GoRoute(
        name: 'about',
        path: '/about',
        builder: (context, state) {
          return AboutPage();
        },
      ),

      // Member Registration
      GoRoute(
        name: 'memberRegistration',
        path: '/member-registration',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MemberRegistrationPage(
            initialRegistration: extra?['registration'] as MemberRegistration?,
            resubmitAsNew: extra?['resubmitAsNew'] as bool? ?? false,
            intent: memberRegistrationIntentFromRouteValue(extra?['intent']),
            parentGcidId: extra?['selectedGcidId'] as int?,
            parentGcName: extra?['selectedGcName'] as String?,
            parentActiveCompany:
                extra?['selectedActiveCompany'] as ActiveMemberCompany?,
          );
        },
      ),

      // Member List
      GoRoute(
        name: 'memberList',
        path: '/member-list',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MemberListPage(
            initialTabIndex: extra?['initialTabIndex'] ?? 0,
          );
        },
      ),

      // Company Selection (pilih tambah GCID atau BCID)
      GoRoute(
        name: 'companySelection',
        path: '/company-selection',
        builder: (context, state) {
          return const CompanySelectionPage();
        },
      ),

      // Add BCID (tambah cabang)
      GoRoute(
        name: 'addBCID',
        path: '/add-bcid',
        builder: (context, state) {
          return const AddBCIDPage();
        },
      ),

      GoRoute(
        path: '/select-avatar',
        name: 'selectAvatar',
        builder: (context, state) {
          final user = state.extra as User;
          return SelectAvatarPage(user: user);
        },
      ),

      GoRoute(
        name: 'search',
        path: '/search',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => SearchBloc(
              getAllProduct: myinjection(),
              getAllCategory: myinjection(),
            ),
            child: const SearchPage(),
          );
        },
      ),

      GoRoute(
        name: 'categoryDetail',
        path: '/category/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return CategoryDetailPage(
            category: extra?['category'],
            categoryId: id,
          );
        },
      ),

      GoRoute(
        name: 'productPage',
        path: '/products',
        builder: (context, state) {
          final extra = state.extra as Category?;
          return ProductPage(categoryName: extra?.name, categoryId: extra?.id);
        },
      ),

      GoRoute(
        name: 'productDetail',
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(productId: id);
        },
      ),

      GoRoute(
        name: 'productsHighlight',
        path: '/products-highlight',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ProductsHighlight(
            hotDealsOnly: extra['hotDealsOnly'] ?? false,
            title: extra['title'] ?? 'Products',
            headerTitle: extra['headerTitle'] ?? '',
            headerSubTitle: extra['headerSubTitle'] ?? 'Products',
          );
        },
      ),

      // ============================================
      // ---------- PROFILE UPDATE ROUTES -----------
      // ============================================

      // 1. Edit Name (No password needed)
      GoRoute(
        path: '/account/edit-profile',
        name: 'edit-profile',
        pageBuilder: (context, state) => _smoothPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => ProfileUpdateCubit(
              updateFullName: getIt<UpdateFullName>(),
              updatePersonalProfile: getIt<UpdatePersonalProfile>(),
              updateUsername: getIt<UpdateUsername>(),
              requestPhoneChange: getIt<RequestPhoneChange>(),
              verifyPhoneChange: getIt<VerifyPhoneChange>(),
              requestEmailChange: getIt<RequestEmailChange>(),
              verifyEmailChange: getIt<VerifyEmailChange>(),
            ),
            child: const EditProfilePage(),
          ),
        ),
      ),

      GoRoute(
        path: '/account/edit-name',
        name: 'edit-name',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => ProfileUpdateCubit(
              updateFullName: getIt<UpdateFullName>(),
              updatePersonalProfile: getIt<UpdatePersonalProfile>(),
              updateUsername: getIt<UpdateUsername>(),
              requestPhoneChange: getIt<RequestPhoneChange>(),
              verifyPhoneChange: getIt<VerifyPhoneChange>(),
              requestEmailChange: getIt<RequestEmailChange>(),
              verifyEmailChange: getIt<VerifyEmailChange>(),
            ),
            child: EditFullNamePage(
              userId: extra['userId'] as String,
              currentName: extra['currentName'] as String,
            ),
          );
        },
      ),

      GoRoute(
        path: '/account/edit-username',
        name: 'edit-username',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => ProfileUpdateCubit(
              updateFullName: getIt<UpdateFullName>(),
              updatePersonalProfile: getIt<UpdatePersonalProfile>(),
              updateUsername: getIt<UpdateUsername>(),
              requestPhoneChange: getIt<RequestPhoneChange>(),
              verifyPhoneChange: getIt<VerifyPhoneChange>(),
              requestEmailChange: getIt<RequestEmailChange>(),
              verifyEmailChange: getIt<VerifyEmailChange>(),
            ),
            child: EditUsernamePage(
              userId: extra['userId'] as String,
              currentUsername: extra['currentUsername'] as String? ?? '',
            ),
          );
        },
      ),

      // 2. Verify Password Page (Reusable)
      GoRoute(
        path: '/account/verify-password',
        name: 'verify-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return VerifyPasswordPage(
            userId: extra['userId'] as String,
            title: extra['title'] as String,
            subtitle: extra['subtitle'] as String,
            nextRoute: extra['nextRoute'] as String,
            nextRouteExtra: extra['nextRouteExtra'] as Map<String, dynamic>?,
          );
        },
      ),

      // 3. Edit Contact (Unified for Phone & Email)
      GoRoute(
        path: '/account/edit-contact',
        name: 'edit-contact',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final type = extra['type'] as String;

          return _smoothPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => ProfileUpdateCubit(
                updateFullName: getIt<UpdateFullName>(),
                updatePersonalProfile: getIt<UpdatePersonalProfile>(),
                updateUsername: getIt<UpdateUsername>(),
                requestPhoneChange: getIt<RequestPhoneChange>(),
                verifyPhoneChange: getIt<VerifyPhoneChange>(),
                requestEmailChange: getIt<RequestEmailChange>(),
                verifyEmailChange: getIt<VerifyEmailChange>(),
              ),
              child: EditContactPage(
                userId: extra['userId'] as String,
                currentValue: type == 'phone'
                    ? extra['currentPhone'] as String
                    : extra['currentEmail'] as String,
                // verifiedPassword: extra['password'] as String,
                type: type == 'phone' ? ContactType.phone : ContactType.email,
              ),
            ),
          );
        },
      ),

      // 4. OTP Verification (Reusable)
      GoRoute(
        path: '/account/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final cubit = extra['cubit'] as ProfileUpdateCubit?;

          if (cubit != null) {
            return BlocProvider<ProfileUpdateCubit>.value(
              value: cubit,
              child: OtpVerificationPage(
                phoneNumber: extra['phoneNumber'] as String,
                title: extra['title'] as String?,
                subtitle: extra['subtitle'] as String?,
                nextRoute: extra['nextRoute'] as String?,
                isPasswordReset: extra['isPasswordReset'] as bool? ?? false,
                cubit: cubit,
                userId: extra['userId'] as String?,
                contactType: extra['contactType'] as ContactType?,
              ),
            );
          }

          // Fallback
          return const Scaffold(
            body: Center(child: Text('Error: Missing cubit')),
          );
        },
      ),

      // 5. Verify Contact Complete (Final verification)
      GoRoute(
        path: '/account/verify-contact-complete',
        name: 'verify-contact-complete',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final cubit = extra['cubit'] as ProfileUpdateCubit;

          return BlocProvider<ProfileUpdateCubit>.value(
            value: cubit,
            child: VerifyContactCompletePage(
              userId: extra['userId'] as String,
              newValue: extra['newValue'] as String,
              verificationCode: extra['verificationCode'] as String,
              type: extra['type'] as ContactType,
              cubit: cubit,
            ),
          );
        },
      ),

      // 6. Verify Email Initial (untuk email yang belum terverifikasi)
      GoRoute(
        path: '/account/verify-email-initial',
        name: 'verify-email-initial',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _smoothPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => ProfileUpdateCubit(
                updateFullName: getIt<UpdateFullName>(),
                updatePersonalProfile: getIt<UpdatePersonalProfile>(),
                updateUsername: getIt<UpdateUsername>(),
                requestPhoneChange: getIt<RequestPhoneChange>(),
                verifyPhoneChange: getIt<VerifyPhoneChange>(),
                requestEmailChange: getIt<RequestEmailChange>(),
                verifyEmailChange: getIt<VerifyEmailChange>(),
              ),
              child: VerifyEmailInitialPage(
                userId: extra['userId'] as String,
                email: extra['email'] as String,
              ),
            ),
          );
        },
      ),

      // ============================================
      // -------- PASSWORD MANAGEMENT ROUTES --------
      // ============================================

      // 1. Change Password (from Settings) - Step 1: Old Password
      GoRoute(
        path: '/account/change-password',
        name: 'change-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => ChangePasswordCubit(
              verifyOldPassword: getIt<VerifyOldPassword>(),
              changePassword: getIt<ChangePassword>(),
              resetPasswordWithOtp: getIt<ResetPasswordWithOtp>(),
            ),
            child: ChangePasswordPage(
              verifiedPassword: extra['verifyOldPassword'] as String,
            ),
          );
        },
      ),

      // 2. New Password Page (Reusable for Change & Reset)
      GoRoute(
        path: '/account/new-password',
        name: 'new-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final cubit = extra['cubit'] as ChangePasswordCubit?;

          // If cubit is passed (from change password flow), use BlocProvider.value
          if (cubit != null) {
            return BlocProvider<ChangePasswordCubit>.value(
              value: cubit,
              child: NewPasswordPage(
                userId: extra['userId'] as String?,
                phone: extra['phone'] as String?,
                flow: extra['flow'] as String,
                oldPassword: extra['old_password'] as String,
              ),
            );
          }

          // If no cubit, create new one
          return BlocProvider(
            create: (context) => ChangePasswordCubit(
              verifyOldPassword: getIt<VerifyOldPassword>(),
              changePassword: getIt<ChangePassword>(),
              resetPasswordWithOtp: getIt<ResetPasswordWithOtp>(),
            ),
            child: NewPasswordPage(
              userId: extra['userId'] as String?,
              phone: extra['phone'] as String?,
              flow: extra['flow'] as String,
              oldPassword: extra['old_password'] as String,
            ),
          );
        },
      ),

      // 3. Forgot Password - Phone Entry
      GoRoute(
        path: '/forgot-password-phone',
        name: 'forgot-password-phone',
        builder: (context, state) {
          return const ForgotPasswordPhonePage();
        },
      ),

      // 4. Forgot Password - OTP Verification (Reusing OTP Page)
      GoRoute(
        path: '/otp-forgot-password',
        name: 'otp-forgot-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<AuthBloc>()),
              BlocProvider(
                create: (context) =>
                    getIt<OtpTimerBloc>()
                      ..add(const StartOtpTimer(duration: 60)),
              ),
            ],
            child: OtpVerificationPage(
              phoneNumber: extra['phone'] as String,
              title: extra['title'] as String? ?? 'Atur Ulang Password',
              subtitle:
                  extra['subtitle'] as String? ??
                  'Masukkan kode OTP yang telah dikirim',
              nextRoute: 'new-password-reset',
              isPasswordReset: true,
            ),
          );
        },
      ),

      // 5. New Password after OTP (Reset Flow) - Create new cubit
      GoRoute(
        path: '/new-password-reset',
        name: 'new-password-reset',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => ChangePasswordCubit(
              verifyOldPassword: getIt<VerifyOldPassword>(),
              changePassword: getIt<ChangePassword>(),
              resetPasswordWithOtp: getIt<ResetPasswordWithOtp>(),
            ),
            child: NewPasswordPage(
              phone: extra['phone'] as String,
              flow: 'reset',
              oldPassword: extra['oldPassword'] as String,
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
}

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppShell({required this.child, required this.currentPath, super.key});

  int _locationToIndex(String path) {
    if (path.startsWith('/category')) return 1;
    if (path.startsWith('/customer')) return 2;
    if (path.startsWith('/transaksi')) return 3;
    if (path.startsWith('/account')) return 4;
    return 0;
  }

  static const List<String> _routeNames = [
    'home',
    'category',
    'customer',
    'transaksi',
    'account',
  ];

  void _refreshPage(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        break;

      case 1: // Category
        context.read<CategoryBloc>().add(
          const CategoryEventGetAllCategories(1),
        );
        break;

      case 2: // Customer
        break;

      case 3: // Transaksi
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(currentPath);

    return ExitConfirmationWrapper(
      alwaysShowConfirmation: true,
      child: Scaffold(
        body: child,
        bottomNavigationBar: BottomNavBar(
          currentIndex: currentIndex,
          onTap: (i) {
            final name = _routeNames[i];

            if (i == currentIndex) {
              GoRouter.of(context).goNamed(name);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  _refreshPage(context, i);
                } catch (e) {
                  // Ignore errors jika bloc tidak tersedia
                }
              });
              return;
            }

            GoRouter.of(context).goNamed(name);
          },
        ),
      ),
    );
  }
}
