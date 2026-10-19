import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_locked_state.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final media = MediaQuery.of(context);
    final scaler = media.textScaler.clamp(
      minScaleFactor: 0.9,
      maxScaleFactor: 1.0,
    );

    return MediaQuery(
      data: media.copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: const CustomHeaderAppBar(
          title: 'Wishlist',
          showBackButton: false,
        ),
        body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
          builder: (context, authState) {
            final isLoggedIn = authState is AuthSessionAuthenticated;
            final userId = isLoggedIn ? authState.user.id : null;

            return SafeArea(
              top: false,
              child: isLoggedIn && userId != null
                  ? WishlistContent(
                      key: ValueKey(
                        'wishlist_content_$userId',
                      ), // Preserve state per user
                      userId: userId,
                    )
                  : const WishlistLockedState(),
            );
          },
        ),
      ),
    );
  }
}
