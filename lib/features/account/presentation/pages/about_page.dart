import 'dart:async';

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';

enum _AboutTab { profile, advantages, visionMission, workCulture }

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const _tabs = <(_AboutTab, String)>[
    (_AboutTab.profile, 'Profil'),
    (_AboutTab.advantages, 'Keunggulan'),
    (_AboutTab.visionMission, 'Visi & Misi'),
    (_AboutTab.workCulture, 'Budaya Kerja'),
  ];

  _AboutTab _selectedTab = _AboutTab.profile;
  final Map<_AboutTab, GlobalKey> _sectionKeys = {
    for (final tab in _AboutTab.values) tab: GlobalKey(),
  };

  void _scrollToTab(_AboutTab tab) {
    setState(() => _selectedTab = tab);

    final sectionContext = _sectionKeys[tab]?.currentContext;
    if (sectionContext == null) return;

    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        surfaceTintColor: AppColors.whiteColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 52,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
            size: 22,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'INFORMASI',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Image.asset(
              'assets/images/account/logoETM.png',
              width: 34,
              height: 34,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 20.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                10,
                horizontalPadding,
                0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 350 / 116,
                          child: Image.asset(
                            'assets/images/banner_informasi.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF5E8EB),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_outlined,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _AboutTabBar(
                        tabs: _tabs,
                        selectedTab: _selectedTab,
                        onSelected: _scrollToTab,
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KeyedSubtree(
                                key: _sectionKeys[_AboutTab.profile],
                                child: const _ProfileContent(),
                              ),
                              const SizedBox(height: 30),
                              KeyedSubtree(
                                key: _sectionKeys[_AboutTab.advantages],
                                child: const _AdvantagesContent(),
                              ),
                              const SizedBox(height: 30),
                              KeyedSubtree(
                                key: _sectionKeys[_AboutTab.visionMission],
                                child: const _VisionMissionContent(),
                              ),
                              const SizedBox(height: 30),
                              KeyedSubtree(
                                key: _sectionKeys[_AboutTab.workCulture],
                                child: const _WorkCultureContent(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AboutTabBar extends StatelessWidget {
  const _AboutTabBar({
    required this.tabs,
    required this.selectedTab,
    required this.onSelected,
  });

  final List<(_AboutTab, String)> tabs;
  final _AboutTab selectedTab;
  final ValueChanged<_AboutTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < tabs.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _AboutTabButton(
              label: tabs[index].$2,
              isSelected: selectedTab == tabs[index].$1,
              onTap: () => onSelected(tabs[index].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _AboutTabButton extends StatelessWidget {
  const _AboutTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.primaryColor : const Color(0xFFF8E7EA),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 34,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    color: isSelected
                        ? AppColors.whiteColor
                        : AppColors.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('PROFIL PERUSAHAAN'),
        _BodyText(
          'Perusahaan distributor bahan baku material springbed dan sofa, serta barang jadi. Didirikan oleh Alm. Bapak Gapo Suseno pada tahun 1997. Ekatunggal berkomitmen untuk menghadirkan produk dan layanan berkualitas tinggi yang memenuhi kebutuhan masyarakat Indonesia.',
        ),
        SizedBox(height: 30),
        _SectionTitle('LEBIH DARI 2 DEKADE BERDIRI'),
        _BodyText(
          'Ekatunggal terus berinovasi untuk memberikan solusi terbaik bagi pelanggan, sekaligus membangun hubungan jangka panjang berdasarkan kepercayaan, integritas, dan profesionalisme. Didukung oleh tim yang berpengalaman dan jaringan yang luas, Ekatunggal siap menjadi mitra terpercaya untuk masa depan yang lebih baik.',
        ),
      ],
    );
  }
}

class _AdvantagesContent extends StatelessWidget {
  const _AdvantagesContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('KEUNGGULAN EKATUNGGAL'),
        SizedBox(height: 4),
        _AdvantageCard(
          iconAsset: 'assets/icons/keunggulan/Ikon_Mutu.png',
          title: 'MUTU',
          description: 'Setiap Produk Terjaga Kualitasnya',
        ),
        _AdvantageCard(
          iconAsset: 'assets/icons/keunggulan/Ikon_Murah.png',
          title: 'MURAH',
          description: 'Menawarkan Produk dengan Harga Terbaik',
        ),
        _AdvantageCard(
          iconAsset: 'assets/icons/keunggulan/Ikon_Non_stop.png',
          title: 'NON STOP',
          description: 'Pelayanan 6 Hari Dalam Seminggu',
        ),
        _AdvantageCard(
          iconAsset: 'assets/icons/keunggulan/Ikon_Terlengkap.png',
          title: 'TERLENGKAP',
          description: 'Produk Selalu Lengkap Sesuai Kebutuhan Konsumen',
        ),
        _AdvantageCard(
          iconAsset: 'assets/icons/keunggulan/Ikon_Layanan_CS.png',
          title: 'LAYANAN CS',
          description: 'Sales Aktif dan Komunikatif',
        ),
      ],
    );
  }
}

enum _VisionMissionTab { vision, mission }

class _VisionMissionContent extends StatefulWidget {
  const _VisionMissionContent();

  @override
  State<_VisionMissionContent> createState() => _VisionMissionContentState();
}

class _VisionMissionContentState extends State<_VisionMissionContent> {
  static const _autoSwitchDuration = Duration(seconds: 3);

  _VisionMissionTab _selectedTab = _VisionMissionTab.vision;
  Timer? _autoSwitchTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSwitchTimer();
  }

  @override
  void dispose() {
    _autoSwitchTimer?.cancel();
    super.dispose();
  }

  void _startAutoSwitchTimer() {
    _autoSwitchTimer?.cancel();
    _autoSwitchTimer = Timer.periodic(_autoSwitchDuration, (_) {
      if (!mounted) return;
      setState(() {
        _selectedTab = _selectedTab == _VisionMissionTab.vision
            ? _VisionMissionTab.mission
            : _VisionMissionTab.vision;
      });
    });
  }

  void _selectTab(_VisionMissionTab tab) {
    if (_selectedTab != tab) {
      setState(() => _selectedTab = tab);
    }
    _startAutoSwitchTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('VISI & MISI'),
        const SizedBox(height: 10),
        Container(
          height: 54,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8E2E7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _VisionMissionTabButton(
                  label: 'VISI',
                  isSelected: _selectedTab == _VisionMissionTab.vision,
                  onTap: () => _selectTab(_VisionMissionTab.vision),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _VisionMissionTabButton(
                  label: 'MISI',
                  isSelected: _selectedTab == _VisionMissionTab.mission,
                  onTap: () => _selectTab(_VisionMissionTab.mission),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 350,
          child: AnimatedCrossFade(
            firstChild: AnimatedSlide(
              offset: _selectedTab == _VisionMissionTab.vision
                  ? Offset.zero
                  : const Offset(0, 0.1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutQuart,
              child: const _VisionPanel(key: ValueKey('vision-panel')),
            ),
            secondChild: AnimatedSlide(
              offset: _selectedTab == _VisionMissionTab.mission
                  ? Offset.zero
                  : const Offset(0, 0.1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutQuart,
              child: const _MissionPanel(key: ValueKey('mission-panel')),
            ),
            crossFadeState: _selectedTab == _VisionMissionTab.vision
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 420),
            firstCurve: Curves.easeOutQuart,
            secondCurve: Curves.easeOutQuart,
            sizeCurve: Curves.easeInOutQuart,
            alignment: Alignment.topCenter,
          ),
        ),
      ],
    );
  }
}

class _VisionMissionTabButton extends StatelessWidget {
  const _VisionMissionTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: isSelected
                    ? AppColors.whiteColor
                    : AppColors.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VisionPanel extends StatelessWidget {
  const _VisionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Menjadi perusahaan perdagangan bahan baku springbed dan sofa, serta bahan jadi skala nasional terlengkap dan menjadi pilihan utama pelanggan.',
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          color: AppColors.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
      ),
    );
  }
}

class _MissionPanel extends StatelessWidget {
  const _MissionPanel({super.key});

  static const _missions = [
    'Memberikan harga yang sangat kompetitif dan bersaing',
    'Memberikan pelayanan terbaik kepada pelanggan non stop selama 6 hari kerja',
    'Meningkatkan kepercayaan pelanggan dengan selalu menjaga kualitas produk',
    'Menjaga ketersediaan barang dan pengiriman tepat waktu',
    'Meningkatkan kesejahteraan karyawan dan kepuasan mitra bisnis',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < _missions.length; index++)
          _MissionCard(number: index + 1, description: _missions[index]),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.number, required this.description});

  final int number;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(color: const Color(0xFFF4DCE1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFBE7EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: AppColors.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: AppColors.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkCultureContent extends StatelessWidget {
  const _WorkCultureContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle('BUDAYA KERJA EKATUNGGAL'),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5DDE2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Bekerja dan Melayani dengan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: AppColors.blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'SEJUTA HATI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        color: AppColors.primaryColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 10.0;
                  final cardWidth = (constraints.maxWidth - gap) / 2;

                  return Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: const _CultureCard(
                              iconAsset: 'assets/icons/budaya/setia.png',
                              label: 'SETIA',
                            ),
                          ),
                          const SizedBox(width: gap),
                          SizedBox(
                            width: cardWidth,
                            child: const _CultureCard(
                              iconAsset: 'assets/icons/budaya/jujur.png',
                              label: 'JUJUR',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: gap),
                      Row(
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: const _CultureCard(
                              iconAsset: 'assets/icons/budaya/tangguh.png',
                              label: 'TANGGUH',
                            ),
                          ),
                          const SizedBox(width: gap),
                          SizedBox(
                            width: cardWidth,
                            child: const _CultureCard(
                              iconAsset: 'assets/icons/budaya/hargai.png',
                              label: 'HARGAI',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: gap),
                      Center(
                        child: SizedBox(
                          width: cardWidth,
                          child: const _CultureCard(
                            iconAsset: 'assets/icons/budaya/teliti.png',
                            label: 'TELITI',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CultureCard extends StatelessWidget {
  const _CultureCard({required this.iconAsset, required this.label});

  final String iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8E2E7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.favorite_border,
                  color: AppColors.primaryColor,
                  size: 58,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: AppColors.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppFonts.primaryFont,
          color: AppColors.blackColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppFonts.primaryFont,
        color: AppColors.blackColor,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
    );
  }
}

class _AdvantageCard extends StatelessWidget {
  const _AdvantageCard({
    required this.iconAsset,
    required this.title,
    required this.description,
  });

  final String iconAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(color: const Color(0xFFF4DCE1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBE7EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              iconAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.workspace_premium_outlined,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    color: AppColors.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
