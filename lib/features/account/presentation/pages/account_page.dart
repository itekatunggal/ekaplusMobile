import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/exit_confirmation_wrapper.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_guest_view.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_logged_in_view.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_others_section.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExitConfirmationWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: CustomHeaderAppBar(
          title: 'Akun Saya',
          showBackButton: false,
          actions: [
            CustomHeaderActionButton(
              tooltip: 'Notifikasi',
              onPressed: () => AppSnackbar.show(
                context,
                message: 'Notifikasi akun akan segera tersedia',
                type: AppSnackbarType.info,
              ),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
          builder: (context, state) {
            if (state is AuthSessionLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }
            if (state is AuthSessionAuthenticated) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 14),
                child: AccountLoggedInView(user: state.user),
              );
            }
            return const SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [AccountGuestView(), AccountOthersSection()],
              ),
            );
          },
        ),
      ),
    );
  }
}
