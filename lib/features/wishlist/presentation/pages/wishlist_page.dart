import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_content.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_locked_state.dart';
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
  bool get wantKeepAlive => true;

  void _showComingSoon(BuildContext context, String feature) {
    AppSnackbar.show(
      context,
      message: '$feature akan segera tersedia',
      type: AppSnackbarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final media = MediaQuery.of(context);

    final scaler = media.textScaler.clamp(
      minScaleFactor: 0.9,
      maxScaleFactor: 1.0,
    );

    return MediaQuery(
      data: media.copyWith(textScaler: scaler),
      child: CustomHeaderScaffold(
        title: 'Wishlist',
        showBackButton: false,

        // Posisi overlap wishlist.
        contentTop: 70,

        // Sama seperti halaman Customer.
        actions: [
          CustomHeaderActionButton(
            tooltip: 'Bantuan',
            onPressed: () => _showComingSoon(context, 'Panduan wishlist'),
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          CustomHeaderActionButton(
            tooltip: 'Notifikasi',
            onPressed: () => _showComingSoon(context, 'Notifikasi'),
            icon: const Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 19,
                ),
                Positioned(
                  right: -1,
                  top: -1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 7, height: 7),
                  ),
                ),
              ],
            ),
          ),
        ],

        body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
          builder: (context, authState) {
            final isLoggedIn = authState is AuthSessionAuthenticated;

            final userId = isLoggedIn ? authState.user.id : null;

            if (isLoggedIn && userId != null) {
              return WishlistContent(
                key: ValueKey('wishlist_content_$userId'),
                userId: userId,
              );
            }

            return const WishlistLockedState();
          },
        ),
      ),
    );
  }
}
