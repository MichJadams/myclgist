import 'package:flutter/material.dart';

class DeviceMapView extends StatelessWidget {
  const DeviceMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PlaceholderPainter(),
      child: const Center(
        child: Text(
          'Once upon a time...',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 186, 34, 34),
          ),
        ),
      ),
    );
  }
}

class PlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // intentionally empty
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
