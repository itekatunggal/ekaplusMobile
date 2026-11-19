import 'dart:io';

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ProfilePictureViewerPage extends StatelessWidget {
  final User user;

  const ProfilePictureViewerPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF171717),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Foto profil',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(child: _buildPicture()),
    );
  }

  Widget _buildPicture() {
    final profilePicture = user.profilePic.trim();
    if (profilePicture.startsWith('local:')) {
      final parts = profilePicture.substring(6).split('|');
      final backgroundValue = parts.length > 1 ? int.tryParse(parts[1]) : null;
      return PhotoView.customChild(
        childSize: const Size.square(1080),
        minScale: PhotoViewComputedScale.contained,
        initialScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        child: ColoredBox(
          color: backgroundValue == null
              ? AppColors.primaryColor
              : Color(backgroundValue),
          child: Image.asset(
            parts.first,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallback(),
          ),
        ),
      );
    }

    final imageProvider = _imageProvider(profilePicture);
    if (imageProvider == null) return _fallback();

    return PhotoView(
      imageProvider: imageProvider,
      minScale: PhotoViewComputedScale.contained,
      initialScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 4,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  ImageProvider? _imageProvider(String value) {
    if (value.isEmpty) return null;
    if (value.startsWith('assets/')) return AssetImage(value);

    final localFile = File(value);
    if (localFile.existsSync()) return FileImage(localFile);

    return NetworkImage(
      value.startsWith('http')
          ? ApiConfig.addImageUpdatedAt(value)
          : ApiConfig.getImageUrl(value),
    );
  }

  Widget _fallback() {
    final nameParts = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = nameParts.isEmpty
        ? 'ET'
        : nameParts.take(2).map((part) => part[0].toUpperCase()).join();

    return ColoredBox(
      color: AppColors.primaryColor,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontFamily: AppFonts.primaryFont,
            fontSize: 72,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
