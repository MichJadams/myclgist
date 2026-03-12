import 'package:flutter/material.dart';
import 'package:whote_is_there/Fungus/fungus_state.dart';

class FungusPainter extends CustomPainter {
  final FungusState state;

  FungusPainter(this.state) : super(repaint: state);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = state.isHeld
          ? Color.lerp(state.color, Colors.grey.shade300, 0.15)!
          : state.color
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    canvas.drawPath(state.getScaledPath(size), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}