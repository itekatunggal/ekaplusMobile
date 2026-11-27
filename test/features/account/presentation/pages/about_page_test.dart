import 'package:ekaplus_ekatunggal/features/account/presentation/pages/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tab menggulir ke bagian dalam satu halaman', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();

    expect(find.text('PROFIL PERUSAHAAN'), findsOneWidget);
    expect(find.text('KEUNGGULAN EKATUNGGAL'), findsOneWidget);

    await tester.tap(find.text('Keunggulan'));
    await tester.pumpAndSettle();
    expect(find.text('MUTU'), findsOneWidget);
    expect(find.text('MURAH'), findsOneWidget);
    expect(find.text('NON STOP'), findsOneWidget);
    expect(find.text('TERLENGKAP'), findsOneWidget);
    expect(find.text('LAYANAN CS'), findsOneWidget);

    await tester.tap(find.text('Visi & Misi'));
    await tester.pumpAndSettle();
    expect(find.text('VISI'), findsOneWidget);
    expect(find.text('MISI'), findsOneWidget);
    expect(
      find
          .textContaining('Menjadi perusahaan perdagangan bahan baku')
          .hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.text('MISI'));
    await tester.pumpAndSettle();
    expect(
      find
          .text('Memberikan harga yang sangat kompetitif dan bersaing')
          .hitTestable(),
      findsOneWidget,
    );
    expect(
      find
          .textContaining('Menjadi perusahaan perdagangan bahan baku')
          .hitTestable(),
      findsNothing,
    );

    await tester.tap(find.text('Budaya Kerja'));
    await tester.pumpAndSettle();
    expect(find.text('BUDAYA KERJA EKATUNGGAL'), findsOneWidget);
    expect(find.text('SEJUTA HATI'), findsOneWidget);
    expect(find.text('SETIA'), findsOneWidget);
    expect(find.text('JUJUR'), findsOneWidget);
    expect(find.text('TANGGUH'), findsOneWidget);
    expect(find.text('HARGAI'), findsOneWidget);
    expect(find.text('TELITI'), findsOneWidget);
    await tester.tap(find.text('Ikuti Ekatunggal'));
    await tester.pumpAndSettle();
    expect(find.text('MEDIA SOSIAL'), findsOneWidget);
    expect(find.text('INSTAGRAM'), findsOneWidget);
    expect(find.text('TIKTOK'), findsOneWidget);
  });

  testWidgets('tab visi dan misi berpindah otomatis tanpa menggeser section', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pump();

    await tester.tap(find.text('Visi & Misi'));
    await tester.pumpAndSettle();
    expect(
      find
          .textContaining('Menjadi perusahaan perdagangan bahan baku')
          .hitTestable(),
      findsOneWidget,
    );
    final cultureTopInVision = tester
        .getTopLeft(find.text('BUDAYA KERJA EKATUNGGAL'))
        .dy;

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(
      find
          .text('Memberikan harga yang sangat kompetitif dan bersaing')
          .hitTestable(),
      findsOneWidget,
    );
    final cultureTopInMission = tester
        .getTopLeft(find.text('BUDAYA KERJA EKATUNGGAL'))
        .dy;
    expect(cultureTopInMission, closeTo(cultureTopInVision, 0.1));
  });

  testWidgets('scroll manual memperbarui tab section yang aktif', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();

    final verticalScroll = find.byWidgetPredicate(
      (widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.vertical,
    );
    final viewportTop = tester.getTopLeft(verticalScroll).dy;
    final visionSectionTop = tester.getTopLeft(find.text('VISI & MISI')).dy;

    await tester.drag(
      verticalScroll,
      Offset(0, -(visionSectionTop - viewportTop + 10)),
    );
    await tester.pumpAndSettle();

    final activeTab = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('about-tab-Visi & Misi')),
    );
    final decoration = activeTab.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFFB11F23));
  });
}
