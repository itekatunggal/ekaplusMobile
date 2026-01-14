import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/exit_confirmation_wrapper.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_guest_view.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_logged_in_view.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_others_section.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ekaplus_ekatunggal/constant.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Get responsive padding
  double _getHorizontalPadding(double width) {
    if (width >= 1200) return 80;
    if (width >= 900) return 60;
    if (width >= 600) return 40;
    return 0;
  }

  // Get max content width for large screens
  double _getMaxContentWidth(double width) {
    if (width >= 1200) return 1000;
    if (width >= 900) return 800;
    if (width >= 600) return 600;
    return width;
  }

  @override
  Widget build(BuildContext context) {
    return ExitConfirmationWrapper(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomHeaderAppBar(
          title: 'Akun',
          onLeadingPressed: () => context.goNamed('home'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final horizontalPadding = _getHorizontalPadding(screenWidth);
            final maxContentWidth = _getMaxContentWidth(screenWidth);

            return BlocBuilder<AuthSessionCubit, AuthSessionState>(
              builder: (context, state) {
                if (state is AuthSessionLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat data akun...',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                Widget content;
                if (state is AuthSessionAuthenticated) {
                  content = Column(
                    children: [
                      // Profile section when logged in
                      Container(
                        width: double.infinity,
                        color: AppColors.whiteColor,
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: maxContentWidth,
                            ),
                            child: AccountLoggedInView(user: state.user),
                          ),
                        ),
                      ),

                      SizedBox(height: screenWidth >= 600 ? 20 : 16),

                      // Divider with responsive styling
                      Container(
                        height: screenWidth >= 600 ? 12 : 8,
                        color: Colors.grey[100],
                      ),

                      SizedBox(height: screenWidth >= 600 ? 20 : 16),

                      // Others section
                      Container(
                        width: double.infinity,
                        color: AppColors.whiteColor,
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: maxContentWidth,
                            ),
                            child: const AccountOthersSection(),
                          ),
                        ),
                      ),

                      // Bottom spacing
                      SizedBox(height: screenWidth >= 600 ? 32 : 24),
                    ],
                  );
                } else {
                  // Guest view
                  content = Column(
                    children: [
                      // Guest promotion section
                      Container(
                        width: double.infinity,
                        color: AppColors.whiteColor,
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: maxContentWidth,
                            ),
                            child: const AccountGuestView(),
                          ),
                        ),
                      ),

                      SizedBox(height: screenWidth >= 600 ? 20 : 16),

                      // Divider with responsive styling
                      Container(
                        height: screenWidth >= 600 ? 12 : 8,
                        color: Colors.grey[100],
                      ),

                      SizedBox(height: screenWidth >= 600 ? 20 : 16),

                      // Others section
                      Container(
                        width: double.infinity,
                        color: AppColors.whiteColor,
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: maxContentWidth,
                            ),
                            child: const AccountOthersSection(),
                          ),
                        ),
                      ),

                      // Bottom spacing
                      SizedBox(height: screenWidth >= 600 ? 32 : 24),
                    ],
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: content,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
