import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

/// Lets the user position and zoom a picture before it is uploaded.
///
/// The exported file is always a 1080 x 1080 PNG. The circular guide is only
/// a preview of the area that will be visible in the profile avatar.
class AdjustProfilePicturePage extends StatefulWidget {
  final String imagePath;

  const AdjustProfilePicturePage({super.key, required this.imagePath});

  @override
  State<AdjustProfilePicturePage> createState() =>
      _AdjustProfilePicturePageState();
}

class _AdjustProfilePicturePageState extends State<AdjustProfilePicturePage> {
  static const int _outputSize = 1080;

  final GlobalKey _cropKey = GlobalKey();
  final PhotoViewController _photoController = PhotoViewController();
  StreamSubscription<PhotoViewControllerValue>? _photoStateSubscription;
  double? _minimumScale;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _photoStateSubscription = _photoController.outputStateStream.listen((
      state,
    ) {
      if (state.scale != null) _minimumScale ??= state.scale;
    });
  }

  @override
  void dispose() {
    _photoStateSubscription?.cancel();
    _photoController.dispose();
    super.dispose();
  }

  void _changeZoom(double factor) {
    final currentScale = _photoController.scale;
    if (currentScale == null) return;
    final minimumScale = _minimumScale ?? currentScale;
    _photoController.scale = (currentScale * factor).clamp(
      minimumScale,
      minimumScale * 5,
    );
  }

  void _rotateClockwise() {
    final nextRotation =
        (_photoController.rotation + (math.pi / 2)) % (math.pi * 2);
    _photoController.updateMultiple(
      position: Offset.zero,
      rotation: nextRotation,
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      // Wait until the last pan/zoom frame has been painted.
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Area foto belum siap');
      }

      final logicalSize = boundary.size.shortestSide;
      final image = await boundary.toImage(
        pixelRatio: _outputSize / logicalSize,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        throw StateError('Foto gagal diproses');
      }

      final tempDirectory = await getTemporaryDirectory();
      final output = File(
        '${tempDirectory.path}${Platform.pathSeparator}'
        'profile_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await output.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
        flush: true,
      );

      if (mounted) Navigator.of(context).pop(output.path);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memproses foto: $error')));
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171717),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Batal',
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          'Atur foto profil',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, color: Colors.white),
            label: Text(
              _isSaving ? 'Memproses' : 'Gunakan',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
              child: Text(
                'Geser foto untuk mengatur posisi. Cubit atau gunakan kontrol '
                'di bawah untuk memperbesar, memperkecil, dan memutar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cropSize = constraints.biggest.shortestSide;
                    return SizedBox.square(
                      dimension: cropSize,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          RepaintBoundary(
                            key: _cropKey,
                            child: ClipRect(
                              child: PhotoView(
                                controller: _photoController,
                                imageProvider: FileImage(
                                  File(widget.imagePath),
                                ),
                                minScale: PhotoViewComputedScale.covered,
                                initialScale: PhotoViewComputedScale.covered,
                                maxScale: PhotoViewComputedScale.covered * 5,
                                // Double-tap is intentionally a no-op to avoid
                                // accidental zoom while positioning the photo.
                                scaleStateCycle: (state) => state,
                                backgroundDecoration: const BoxDecoration(
                                  color: Colors.black,
                                ),
                                enableRotation: false,
                                tightMode: true,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.white54,
                                        size: 64,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const IgnorePointer(
                            child: CustomPaint(
                              painter: _CircleCropGuidePainter(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Perkecil',
                      onPressed: _isSaving ? null : () => _changeZoom(0.8),
                      color: Colors.white,
                      icon: const Icon(Icons.remove),
                    ),
                    Container(width: 1, height: 28, color: Colors.white24),
                    IconButton(
                      tooltip: 'Perbesar',
                      onPressed: _isSaving ? null : () => _changeZoom(1.25),
                      color: Colors.white,
                      icon: const Icon(Icons.add),
                    ),
                    Container(width: 1, height: 28, color: Colors.white24),
                    IconButton(
                      tooltip: 'Putar 90 derajat',
                      onPressed: _isSaving ? null : _rotateClockwise,
                      color: Colors.white,
                      icon: const Icon(Icons.rotate_right),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleCropGuidePainter extends CustomPainter {
  const _CircleCropGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final circle = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide * 0.43,
    );
    final outsideCircle = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addOval(circle),
    );

    canvas.drawPath(
      outsideCircle,
      Paint()..color = Colors.black.withValues(alpha: 0.56),
    );
    canvas.drawOval(
      circle,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleCropGuidePainter oldDelegate) => false;
}
