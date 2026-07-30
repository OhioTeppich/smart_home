import 'package:flutter/material.dart';

/// Scales the entire app visually by [scale] while keeping layout logic
/// (breakpoints, responsive checks) working against the original logical size.
class AppScale extends StatelessWidget {
  const AppScale({required this.scale, required this.child, super.key});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final scaledSize = size / scale;

    return MediaQuery(
      data: mediaQuery.copyWith(size: scaledSize),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: scaledSize.width,
          maxWidth: scaledSize.width,
          minHeight: scaledSize.height,
          maxHeight: scaledSize.height,
          child: child,
        ),
      ),
    );
  }
}
