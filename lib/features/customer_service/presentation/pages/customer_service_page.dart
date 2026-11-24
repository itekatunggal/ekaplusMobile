import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/whatsapp_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  static final Uri _emailUri = Uri.parse(
    'mailto:ekatunggalofficial@gmail.com'
    '?subject=Layanan%20Pelanggan%20Ekatunggal'
    '&body=Halo%20Admin%20Vika%2C%0A%0A'
    'Saya%20ingin%20menanyakan%20mengenai%20Ekatunggal%20Tunas%20Mandiri',
  );

  Future<void> _openEmail(BuildContext context) async {
    try {
      if (await launchUrl(_emailUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // Pesan kegagalan ditampilkan di bawah.
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aplikasi email tidak dapat dibuka')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
          'CUSTOMER SERVICE',
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
              errorBuilder: (_, _, _) => const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primaryColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _InformationBanner(),
              const SizedBox(height: 14),
              const _SectionTitle('HUBUNGI KAMI'),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _ContactCard(
                      label: 'WHATSAPP',
                      icon: Image.asset(
                        'assets/icons/whatsapp.png',
                        width: 58,
                        height: 58,
                        fit: BoxFit.contain,
                      ),
                      onTap: () => WhatsAppHelper.openGeneral(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ContactCard(
                      label: 'EMAIL',
                      icon: Image.asset(
                        'assets/icons/email.png',
                        width: 58,
                        height: 58,
                        fit: BoxFit.contain,
                      ),
                      onTap: () => _openEmail(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const _SectionTitle('SARAN DAN KELUHAN'),
              const SizedBox(height: 9),
              _SupportCard(
                title: 'Beri Masukan',
                subtitle: 'Bagikan ide untuk layanan kami',
                icon: Icons.lightbulb_outline_rounded,
                onTap: () => context.pushNamed('customer-feedback'),
              ),
              const SizedBox(height: 10),
              _SupportCard(
                title: 'Laporkan Kendala',
                subtitle: 'Sampaikan kendala yang anda alami',
                icon: Icons.feedback_outlined,
                onTap: () => context.pushNamed('customer-complaint'),
              ),
              const SizedBox(height: 10),
              _SupportCard(
                title: 'Riwayat Pengajuan',
                subtitle: 'Lihat masukan, kendala, dan balasan admin',
                icon: Icons.history_rounded,
                onTap: () => context.pushNamed('customer-history'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformationBanner extends StatelessWidget {
  const _InformationBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 350 / 116,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/banner_informasi.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFFB00035),
                    const Color(0xFFB00035).withValues(alpha: .98),
                    const Color(0xFFB00035).withValues(alpha: .72),
                    Colors.transparent,
                  ],
                  stops: const [0, .38, .57, .78],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 12, 12, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi &\nPelayanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: .96,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Kenali layanan Ekatunggal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF252525),
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFF0DDE1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 86,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8EEF0),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: icon,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFF0DDE1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E9ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        // color: AppColors.primaryColor,
                        color: AppColors.blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        // color: AppColors.primaryColor,
                        color: AppColors.grayColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCF9BA6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
