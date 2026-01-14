import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/member_registration_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dart:async';
import 'constant.dart';
import 'injection.dart';
import 'observer.dart';

import 'cubit/connection_status_cubit.dart';
import 'core/shared_widgets/no_internet_dialog.dart';
import 'core/utils/global_navigator_key.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'features/auth/presentation/cubit/auth_session_cubit.dart';
import 'features/auth/presentation/cubit/auth_session_state.dart';

import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/type/presentation/bloc/type_bloc.dart';
import 'features/wishlist/presentation/bloc/wishlist_bloc.dart';

import 'core/routes/my_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('auth_user_box');

  await init();

  Bloc.observer = MyObserver();
  await initializeDateFormatting('id_ID', null);
  runApp(const EkaplusApp());
}

class EkaplusApp extends StatefulWidget {
  const EkaplusApp({super.key});

  @override
  State<EkaplusApp> createState() => _EkaplusAppState();
}

class _EkaplusAppState extends State<EkaplusApp> {
  bool _isDialogShowing = false;
  Timer? _retryTimer;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConnectionCubit()..startMonitoringConnection(),
        ),
        BlocProvider(
          create: (_) => myinjection<AuthSessionCubit>()..refreshUser(),
        ),
        BlocProvider(
          create: (_) {
            final bloc = myinjection<ProductBloc>();
            bloc.add(const ProductEventLoadFirstPage());
            return bloc;
          },
        ),
        BlocProvider(
          create: (context) {
            final bloc = myinjection<WishlistBloc>();
            // final state = context.read<AuthSessionCubit>().state;
            // if (state is AuthSessionAuthenticated) {
            //   bloc.add(LoadWishlist(state.user.id));
            // }
            return bloc;
          },
        ),
        BlocProvider(create: (_) => myinjection<BranchCubit>()),
        BlocProvider(create: (_) => myinjection<BannerCubit>()),
        BlocProvider(create: (_) => myinjection<MemberRegistrationCubit>()),
        BlocProvider(create: (_) => myinjection<TypeBloc>()),
        BlocProvider(create: (_) => myinjection<CategoryBloc>()),
        BlocProvider(create: (_) => myinjection<AuthBloc>()),
        BlocProvider(create: (_) => myinjection<OtpTimerBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ConnectionCubit, ConnectionStateCubit>(
            listener: (context, state) {
              final navigatorContext = globalNavigatorKey.currentContext;
              if (navigatorContext == null) return;

              if (state.status == ConnectionStatus.offline) {
                // Cancel any pending timer
                _retryTimer?.cancel();

                if (!_isDialogShowing) {
                  _showNoInternetDialog(
                    navigatorContext,
                    context.read<ConnectionCubit>(),
                  );
                }
              } else if (state.status == ConnectionStatus.online) {
                // Connection restored - close dialog and cancel timer
                _retryTimer?.cancel();
                if (_isDialogShowing) {
                  globalNavigatorKey.currentState?.pop();
                  _isDialogShowing = false;

                  // Trigger data refresh on current screen
                  _refreshCurrentScreen(navigatorContext);
                }
              }
            },
          ),
          // BlocListener<AuthSessionCubit, AuthSessionState>(
          //   listener: (context, state) {
          //     // if (state is AuthSessionAuthenticated) {
          //     //   context.read<WishlistBloc>().add(LoadWishlist(state.user.id));
          //     // }
          //   },
          // ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: MyRouter().router,
          theme: ThemeData(
            primaryColor: AppColors.primaryColor,
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: AppFonts.primaryFont,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  void _showNoInternetDialog(
    BuildContext navigatorContext,
    ConnectionCubit cubit,
  ) {
    _isDialogShowing = true;
    NoInternetDialog.show(navigatorContext).then((action) {
      if (!mounted) return;
      _isDialogShowing = false;

      if (action == 'retry') {
        // User clicked "Hubungkan Kembali" - check connection
        cubit.checkConnection().then((_) {
          if (!mounted) return;
          // After check, if still offline, show dialog again
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            if (cubit.state.status == ConnectionStatus.offline &&
                !_isDialogShowing) {
              _showNoInternetDialog(navigatorContext, cubit);
            }
          });
        });
      } else if (action == 'close') {
        // User clicked "Tutup" - set timer to show again after 5 seconds if still offline
        _retryTimer?.cancel();
        _retryTimer = Timer(const Duration(seconds: 5), () {
          if (!mounted) return;
          if (cubit.state.status == ConnectionStatus.offline &&
              !_isDialogShowing) {
            _showNoInternetDialog(navigatorContext, cubit);
          }
        });
      }
    });
  }

  void _refreshCurrentScreen(BuildContext context) {
    // Refresh ProductBloc if exists
    try {
      context.read<ProductBloc>().add(const ProductEventRefresh());
    } catch (_) {}

    // Refresh TypeBloc if exists
    try {
      context.read<TypeBloc>().add(TypeEventGetAllTypes(1));
    } catch (_) {}
  }
}
