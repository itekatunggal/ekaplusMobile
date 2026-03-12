import 'dart:async';

import 'package:flutter/material.dart';

enum AppSnackbarType { success, error, info, warning }

class AppSnackbar {
  static const double _messageFontSize = 15;
  static const double _actionFontSize = 15;
  static OverlayEntry? _currentEntry;
  static AnimationController? _currentController;
  static Timer? _dismissTimer;

  static Color _bg(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return const Color(0xFF065F46);
      case AppSnackbarType.error:
        return const Color(0xFF7F1D1D);
      case AppSnackbarType.warning:
        return const Color(0xFF78350F);
      case AppSnackbarType.info:
        return const Color(0xFF111827);
    }
  }

  static IconData _icon(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return Icons.check_circle_rounded;
      case AppSnackbarType.error:
        return Icons.error_rounded;
      case AppSnackbarType.warning:
        return Icons.warning_amber_rounded;
      case AppSnackbarType.info:
        return Icons.info_rounded;
    }
  }

  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    showRaw(
      context,
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: _bg(type),
      ),
      type: type,
    );
  }

  static void showRaw(
    BuildContext context,
    SnackBar snackBar, {
    AppSnackbarType type = AppSnackbarType.info,
  }) {
    _dismissTimer?.cancel();
    _currentController?.dispose();
    _currentEntry?.remove();

    final overlay = Overlay.of(context, rootOverlay: true);
    final navigator = Navigator.of(context, rootNavigator: true);

    final controller = AnimationController(
      vsync: navigator,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );

    const resolvedPadding = EdgeInsets.fromLTRB(16, 10, 46, 10);
    const resolvedMargin = EdgeInsets.fromLTRB(16, 0, 16, 132);
    final resolvedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    final resolvedBackground = snackBar.backgroundColor ?? _bg(type);
    final resolvedDuration = snackBar.duration;
    final resolvedMessage = _extractMessage(snackBar.content);

    late final OverlayEntry entry;
    Future<void> dismiss() async {
      _dismissTimer?.cancel();
      if (controller.status != AnimationStatus.dismissed) {
        await controller.reverse();
      }
      if (_currentEntry == entry) {
        _currentEntry = null;
        _currentController = null;
      }
      entry.remove();
      controller.dispose();
    }

    entry = OverlayEntry(
      builder: (overlayContext) => _AnimatedSnackbarOverlay(
        animation: controller,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: resolvedMargin,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(overlayContext).size.width * 0.78,
                  ),
                  child: Material(
                    color: resolvedBackground,
                    elevation: 0,
                    shape: resolvedShape,
                    clipBehavior: Clip.antiAlias,
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: _messageFontSize,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      child: IconTheme(
                        data: const IconThemeData(
                          color: Colors.white,
                          size: 18,
                        ),
                        child: Padding(
                          padding: resolvedPadding,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_icon(type)),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  resolvedMessage,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (snackBar.action != null) ...[
                                const SizedBox(width: 8),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        textStyle: const TextStyle(
                                          fontSize: _actionFontSize,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: snackBar.action!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _currentEntry = entry;
    _currentController = controller;
    overlay.insert(entry);
    controller.forward();
    _dismissTimer = Timer(resolvedDuration, dismiss);
  }

  static String _extractMessage(Widget widget) {
    if (widget is Text) {
      return widget.data ?? widget.textSpan?.toPlainText() ?? '';
    }
    if (widget is RichText) {
      return widget.text.toPlainText();
    }
    if (widget is Expanded) {
      return _extractMessage(widget.child);
    }
    if (widget is Flexible) {
      return _extractMessage(widget.child);
    }
    if (widget is Padding) {
      return _extractMessage(widget.child ?? const SizedBox.shrink());
    }
    if (widget is Center) {
      return _extractMessage(widget.child ?? const SizedBox.shrink());
    }
    if (widget is Align) {
      return _extractMessage(widget.child ?? const SizedBox.shrink());
    }
    if (widget is DefaultTextStyle) {
      return _extractMessage(widget.child);
    }
    if (widget is Row) {
      return widget.children
          .map(_extractMessage)
          .where((text) => text.trim().isNotEmpty)
          .join(' ');
    }
    if (widget is Column) {
      return widget.children
          .map(_extractMessage)
          .where((text) => text.trim().isNotEmpty)
          .join(' ');
    }
    if (widget is SizedBox && widget.child != null) {
      return _extractMessage(widget.child!);
    }
    if (widget is Container && widget.child != null) {
      return _extractMessage(widget.child!);
    }
    return '';
  }
}

class _AnimatedSnackbarOverlay extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _AnimatedSnackbarOverlay({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, _) {
          final slide = Tween<Offset>(
            begin: const Offset(-1.0, 0),
            end: Offset.zero,
          ).evaluate(curved);
          final opacity = Tween<double>(begin: 0, end: 1).evaluate(curved);

          return Opacity(
            opacity: opacity,
            child: FractionalTranslation(translation: slide, child: child),
          );
        },
      ),
    );
  }
}
