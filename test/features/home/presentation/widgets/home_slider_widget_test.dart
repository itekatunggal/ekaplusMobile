import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';
import 'package:ekaplus_ekatunggal/features/home/presentation/widgets/home_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('menampilkan CTA dan membuka internal route', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: HomeSliderWidget(
              banners: [
                BannerSlider(
                  name: 'Tentang kami',
                  img: 'assets/images/banner-tidak-ada.png',
                  disabled: false,
                  type: 'internal_route',
                  typeValue: 'about',
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          name: 'about',
          path: '/about',
          builder: (_, _) => const Scaffold(body: Text('Halaman Tentang')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    final visibleCta = find.text('Selengkapnya').hitTestable();
    expect(visibleCta, findsOneWidget);

    await tester.tap(visibleCta);
    await tester.pumpAndSettle();

    expect(find.text('Halaman Tentang'), findsOneWidget);
  });

  testWidgets('tidak menampilkan CTA untuk banner non', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeSliderWidget(
            banners: [
              BannerSlider(
                name: 'Informasi',
                img: 'assets/images/banner-tidak-ada.png',
                disabled: false,
                type: 'non',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Selengkapnya'), findsNothing);
  });
}
