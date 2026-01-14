import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/whatsapp_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountOthersSection extends StatelessWidget {
  const AccountOthersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lainnya',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildListItem(
            context: context,
            asset: 'assets/images/account/logoETM.png',
            title: 'Tentang Ekatunggal',
            fallbackIcon: Icons.info,
            onTap: () => context.pushNamed('about'),
          ),
          const Divider(height: 1),
          _buildListItem(
            context: context,
            asset: 'assets/images/account/tanyaVika.png',
            title: 'Tanya Vika',
            fallbackIcon: Icons.chat,
            onTap: () => _showInfoDialog(context),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required String asset,
    required String title,
    required IconData fallbackIcon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 36,
        height: 36,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(fallbackIcon, size: 28, color: Colors.black54),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: onTap,
    );
  }

  void _showInfoDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(horizontal: isSmall ? 18 : 28),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 18 : 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.green.shade50.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.chat, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                'Chat WhatsApp',
                style: TextStyle(
                  fontSize: isSmall ? 15 : 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tanyakan info mengenai Ekatunggal langsung via WhatsApp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 11.5 : 12.5,
                  fontFamily: AppFonts.secondaryFont,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmall ? 18 : 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(c),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(c);
                        WhatsAppHelper.openGeneral(context);
                      },
                      icon: const Icon(Icons.chat, size: 16),
                      label: Text(
                        'Chat Admin',
                        style: TextStyle(
                          fontSize: isSmall ? 11.5 : 12.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
