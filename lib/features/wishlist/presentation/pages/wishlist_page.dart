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
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isSelectionMode = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showComingSoon(BuildContext context, String feature) {
    AppSnackbar.show(
      context,
      message: '$feature akan segera tersedia',
      type: AppSnackbarType.info,
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
    });
  }

  void _exitSelectionMode() {
    if (!_isSelectionMode) return;

    setState(() {
      _isSelectionMode = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final media = MediaQuery.of(context);

    final scaler = media.textScaler.clamp(
      minScaleFactor: 0.90,
      maxScaleFactor: 1.0,
    );

    return MediaQuery(
      data: media.copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
                builder: (context, authState) {
                  if (authState is AuthSessionAuthenticated) {
                    final userId = authState.user.id;

                    if (userId != null) {
                      return WishlistContent(
                        key: ValueKey('wishlist_content_$userId'),
                        userId: userId,
                        searchQuery: _searchQuery,
                        isSelectionMode: _isSelectionMode,
                        onExitSelectionMode: _exitSelectionMode,
                      );
                    }
                  }

                  return const WishlistLockedState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 178,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomHeaderAppBar(
              title: 'Wishlist',
              brandStyle: true,
              showBackButton: false,
              height: 178,
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

                // Tombol Pilih / Batal
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: _toggleSelectionMode,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Text(
                          _isSelectionMode ? 'Batal' : 'Pilih',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x100F172A),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.primaryFont,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari SKU atau nama item wishlist...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFonts.primaryFont,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          splashRadius: 18,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF94A3B8),
                            size: 17,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
