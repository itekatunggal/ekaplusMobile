// lib/features/home/presentation/pages/home_page.dart

import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_cubit.dart';
import 'package:ekaplus_ekatunggal/features/banner/presentation/cubit/banner_state.dart';
import 'package:ekaplus_ekatunggal/features/home/presentation/widgets/home_slider_widget.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/products_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/shared_widgets/profile_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/typeCategory_list.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TypeBloc>().add(TypeEventGetAllTypes(1));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final fixedMedia = media.copyWith(
      textScaleFactor: media.textScaleFactor.clamp(0.9, 1.0),
    );

    return MediaQuery(
      data: fixedMedia,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
            builder: (context, authState) {
              final bool isLoggedIn = authState is AuthSessionAuthenticated;

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 12,
                    ),
                    child: const ProfileHeader(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // 1. Konten Utama (Slider + Kategori)
                              Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child:
                                        BlocBuilder<BannerCubit, BannerState>(
                                          bloc: context.read<BannerCubit>()
                                            ..fetchBanners(),
                                          builder: (context, state) {
                                            if (state is BannerLoaded) {
                                              return HomeSliderWidget(
                                                banners: state.banners,
                                                enableTap: isLoggedIn,
                                              );
                                            }
                                            return const _BannerShimmer();
                                          },
                                        ),
                                  ),
                                  // const SizedBox(
                                  //   height: 5,
                                  // ), // Beri jarak agar kategori tidak tertutup search bar
                                  const TypeCategoryList(),
                                ],
                              ),

                              // 2. Search Bar (Diletakkan terakhir agar Z-Index paling tinggi)
                              Positioned(
                                top: 180,
                                left: 16,
                                right: 16,
                                child: const HomeSearchBar(),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 8),
                          ProductsSection(
                            title: 'Yang Baru Dari Kami🔥',
                            subtitle: 'Yang baru - baru, dijamin menarik !!!',
                            hotDealsOnly: false,
                            showCount: 6,
                            isLoggedIn: isLoggedIn,
                          ),
                          const SizedBox(height: 10),
                          ProductsSection(
                            title: 'Produk Terlaris 🤩',
                            subtitle: 'Siapa cepat, dia dapat, sikaaat ...',
                            hotDealsOnly: true,
                            showCount: 6,
                            isLoggedIn: isLoggedIn,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BannerShimmer extends StatelessWidget {
  const _BannerShimmer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.white,
          child: Container(
            width: double.infinity,
            height: 230,
            color: Colors.white,
          ),
        ),
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Container(
                width: i == 0 ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
