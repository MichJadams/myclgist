import 'dart:math';
import 'package:flutter/material.dart';

/// A stateless CustomPainter that fills the canvas with a dark pixelated void
/// aesthetic — overlapping rings of dark pixels radiating outward from the
/// center, using a grid of small squares ("pixels") in deep blacks, dark teals,
/// and dark purples with opacity variation per ring to simulate depth, like
/// looking down into a dark digital lake.
///
/// [animationValue] (0.0–1.0) drives continuous outward ring expansion.
/// One full cycle advances every ring outward by one [_ringWidth]. Animation
/// state is owned by the parent; this painter is purely stateless.
class AnimatedVoidPainter extends CustomPainter {
  final double animationValue;

  const AnimatedVoidPainter({required this.animationValue});

  static const double _pixelSize = 6.0;
  static const double _ringWidth = 26.0;

  /// Palette cycles per ring: deep blacks → dark teals → dark purples.
  static const List<Color> _palette = [
    Color(0xFF030308), // void black
    Color(0xFF031210), // dark teal
    Color(0xFF08030F), // dark purple
    Color(0xFF050509), // near black
    Color(0xFF051614), // deep teal
    Color(0xFF0B0510), // deep purple
    Color(0xFF020204), // absolute void
    Color(0xFF041310), // teal-black
    Color(0xFF090418), // rich purple
    Color(0xFF040406), // dark near-black
    Color(0xFF061A17), // teal shadow
    Color(0xFF0D061A), // purple shadow
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Base: pure void black behind all pixels.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF000000),
    );

    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxDist = sqrt(cx * cx + cy * cy);

    final paint = Paint()..style = PaintingStyle.fill;

    final cols = (size.width / _pixelSize).ceil() + 1;
    final rows = (size.height / _pixelSize).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        // Sample from the pixel centre so ring edges align to the grid cleanly.
        final px = col * _pixelSize;
        final py = row * _pixelSize;
        final dx = px + _pixelSize * 0.5 - cx;
        final dy = py + _pixelSize * 0.5 - cy;
        final dist = sqrt(dx * dx + dy * dy);

        // Shift the ring phase outward by animationValue each cycle. Multiplying
        // by _palette.length ensures one full 0→1 cycle advances rings by
        // exactly palette.length ring-widths, so the colour at every pixel is
        // identical at animationValue=0 and animationValue=1 — no visible jump
        // on loop reset. New rings continuously emerge from the centre and
        // disappear at the edges.
        final ringPhase = dist / _ringWidth - animationValue * _palette.length;
        final ringIndex = ringPhase.floor();
        // Dart % returns negative for negative operands — normalise to palette.
        final colorIndex =
            ((ringIndex % _palette.length) + _palette.length) % _palette.length;

        // Deterministic per-pixel noise — no Random(), fully reproducible.
        // Uses a LCG-style integer hash of the grid coordinate.
        final h = (col * 1664525 ^ row * 1013904223) & 0x7FFFFFFF;
        final noise = (h % 200) / 200.0; // 0.0 – 0.99

        // Depth gradient: rings near the centre are slightly brighter/more
        // opaque (the "surface" of the lake), fading to near-nothing at the
        // canvas edge (the abyss).
        final normalizedDist = (dist / maxDist).clamp(0.0, 1.0);
        final baseOpacity = 0.68 - normalizedDist * 0.42; // 0.68 → 0.26
        final jitter = noise * 0.18 - 0.09; // ±0.09 per pixel
        final opacity = (baseOpacity + jitter).clamp(0.08, 0.80);

        // Hard ring colour — no lerp keeps the blocky, pixelated look.
        final color = _palette[colorIndex];

        paint.color = color.withValues(alpha: opacity);
        canvas.drawRect(Rect.fromLTWH(px, py, _pixelSize, _pixelSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedVoidPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
