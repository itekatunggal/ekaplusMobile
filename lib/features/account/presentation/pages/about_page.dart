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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scrollViewportKey = GlobalKey();
  final Map<_AboutTab, GlobalKey> _sectionKeys = {
    for (final tab in _AboutTab.values) tab: GlobalKey(),
  };
  bool _isNavigatingToSection = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncTabWithScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncTabWithScroll)
      ..dispose();
    super.dispose();
  }

  void _syncTabWithScroll() {
    if (!mounted || _isNavigatingToSection || !_scrollController.hasClients) {
      return;
    }

    var activeTab = _AboutTab.profile;
    if (_scrollController.position.extentAfter <= 1) {
      activeTab = _AboutTab.workCulture;
    } else {
      final viewportBox = _scrollViewportKey.currentContext?.findRenderObject();
      if (viewportBox is! RenderBox || !viewportBox.hasSize) return;

      final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
      final activationLine = viewportTop + 40;

      for (final (tab, _) in _tabs) {
        final sectionBox = _sectionKeys[tab]?.currentContext
            ?.findRenderObject();
        if (sectionBox is! RenderBox || !sectionBox.hasSize) continue;

        final sectionTop = sectionBox.localToGlobal(Offset.zero).dy;
        if (sectionTop <= activationLine) {
          activeTab = tab;
        } else {
          break;
        }
      }
    }

    if (activeTab != _selectedTab) {
      setState(() => _selectedTab = activeTab);
    }
  }

  void _scrollToTab(_AboutTab tab) {
    _isNavigatingToSection = true;
    setState(() => _selectedTab = tab);

    final sectionContext = _sectionKeys[tab]?.currentContext;
    if (sectionContext == null) {
      _isNavigatingToSection = false;
      return;
    }

    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0,
    ).whenComplete(() {
      if (!mounted) return;
      _isNavigatingToSection = false;
      _syncTabWithScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
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
              'assets/icons/icon_app.png',
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
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: _majorCardDecoration,
                        clipBehavior: Clip.antiAlias,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: AspectRatio(
                            aspectRatio: 350 / 116,
                            child: Image.asset(
                              'assets/images/banner_informasi.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF8FAFC),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _AboutTabBar(
                        tabs: _tabs,
                        selectedTab: _selectedTab,
                        onSelected: _scrollToTab,
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: SingleChildScrollView(
                          key: _scrollViewportKey,
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KeyedSubtree(
                                key: _sectionKeys[_AboutTab.profile],
                                child: const _ProfileContent(),
                              ),
                              const SizedBox(height: 14),
                              KeyedSubtree(
                                key: _sectionKeys[_AboutTab.advantages],
                                child: const _AdvantagesContent(),
                              ),
                              const SizedBox(height: 14),
                              KeyedSubtree(
                                key: _sectionKeys[_AboutTab.visionMission],
                                child: const _VisionMissionContent(),
                              ),
                              const SizedBox(height: 14),
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

class _AboutTabBar extends StatefulWidget {
  const _AboutTabBar({
    required this.tabs,
    required this.selectedTab,
    required this.onSelected,
  });

  final List<(_AboutTab, String)> tabs;
  final _AboutTab selectedTab;
  final ValueChanged<_AboutTab> onSelected;

  @override
  State<_AboutTabBar> createState() => _AboutTabBarState();
}

class _AboutTabBarState extends State<_AboutTabBar> {
  final Map<_AboutTab, GlobalKey> _tabKeys = {
    for (final tab in _AboutTab.values) tab: GlobalKey(),
  };

  @override
  void didUpdateWidget(covariant _AboutTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTab == widget.selectedTab) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tabContext = _tabKeys[widget.selectedTab]?.currentContext;
      if (tabContext == null) return;
      Scrollable.ensureVisible(
        tabContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: .5,
      );
    });
  }

  Widget _buildButton(int index) {
    final tab = widget.tabs[index].$1;
    return KeyedSubtree(
      key: _tabKeys[tab],
      child: _AboutTabButton(
        label: widget.tabs[index].$2,
        isSelected: widget.selectedTab == tab,
        onTap: () => widget.onSelected(tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttons = <Widget>[
          for (var index = 0; index < widget.tabs.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            _buildButton(index),
          ],
        ];

        if (constraints.maxWidth < 440) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(children: buttons),
          );
        }

        return Row(
          children: [
            for (var index = 0; index < widget.tabs.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              Expanded(child: _buildButton(index)),
            ],
          ],
        );
      },
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
      label: label,
      button: true,
      selected: isSelected,
      child: AnimatedContainer(
        key: ValueKey('about-tab-$label'),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : const Color(0xFFFFF1F2),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFFECACA),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                height: 32,
                child: Center(
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
      ),
    );
  }
}

const _majorCardDecoration = BoxDecoration(
  color: AppColors.whiteColor,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9), width: 1)),
  boxShadow: [
    BoxShadow(color: Color(0x120F172A), blurRadius: 20, offset: Offset(0, 6)),
  ],
);

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
        SizedBox(height: 16),
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
  static const _transitionDuration = Duration(milliseconds: 420);

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
          height: 58,
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
        const SizedBox(height: 16),
        AnimatedSize(
          duration: _transitionDuration,
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 350),
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: _transitionDuration,
                switchInCurve: Curves.easeOutQuart,
                switchOutCurve: Curves.easeInQuart,
                child: _selectedTab == _VisionMissionTab.vision
                    ? const _VisionPanel(key: ValueKey('vision-panel'))
                    : const _MissionPanel(key: ValueKey('mission-panel')),
              ),
            ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 520),
                curve: Curves.easeInOutCubic,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: isSelected
                      ? AppColors.whiteColor
                      : AppColors.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                child: Text(label),
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
        color: const Color(0xFFFFF1F2),
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(16),
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
        border: Border.all(color: const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
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
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle('BUDAYA KERJA EKATUNGGAL'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
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
        color: Color(0xFF475569),
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        height: 1.5,
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
        border: Border.all(color: const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
                    fontSize: 14,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    // height: 1.35,
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
