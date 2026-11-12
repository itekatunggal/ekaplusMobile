import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/domain/entities/sales_profile.dart';
import 'package:flutter/material.dart';

class SalesProfileCard extends StatelessWidget {
  const SalesProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
    this.compact = false,
  });

  final SalesProfile profile;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => _CompactSalesProfileCard(
    profile: profile,
    onTap: onTap,
    compact: compact,
  );
}

class _CompactSalesProfileCard extends StatelessWidget {
  const _CompactSalesProfileCard({
    required this.profile,
    required this.onTap,
    required this.compact,
  });

  final SalesProfile profile;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Buka profil ${profile.name}, ${profile.position}',
    excludeSemantics: true,
    child: Material(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: compact ? 148 : double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SalesProfilePhoto(profile: profile),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.42, 1],
                    colors: [Colors.transparent, Color(0xD9000000)],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (profile.isDemo)
                      const Text(
                        'PROFIL DEMO',
                        style: TextStyle(
                          color: Color(0xFFFFD7DC),
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      profile.position,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SalesProfilePhoto extends StatelessWidget {
  const SalesProfilePhoto({super.key, required this.profile});

  final SalesProfile profile;

  @override
  Widget build(BuildContext context) {
    final source = profile.photoUrl?.trim() ?? '';
    if (source.startsWith('asset://')) {
      return Image.asset(
        source.substring('asset://'.length),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, _, _) => _fallback,
      );
    }
    if (source.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorWidget: (_, _, _) => _fallback,
        placeholder: (_, _) => _fallback,
      );
    }
    return _fallback;
  }

  Widget get _fallback => const ColoredBox(
    color: Color(0xFFFFF1F2),
    child: Center(
      child: Icon(
        Icons.person_rounded,
        size: 68,
        color: AppColors.primaryColor,
      ),
    ),
  );
}
