import 'package:flutter/material.dart';

class StoneData {
  final Offset offset;
  final String name;
  final String remoteId;
  final String platformName;
  final String serviceData;
  final String timeStamp;

  const StoneData({
    required this.offset,
    required this.name,
    required this.remoteId,
    required this.platformName,
    required this.serviceData,
    required this.timeStamp,
  });

}

class BurriedStone extends StatelessWidget {
  final StoneData stoneData;
  final VoidCallback onTap;

  const BurriedStone({required this.stoneData, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 50,
        width: 50,
        child: stoneData.name.contains("5")
            ? Image.asset("assets/stone_one.png")
            : Image.asset("assets/stone_two.png"),
      ),
    );
  }
}

class MapCanvasPainter extends CustomPainter {
  final List<StoneData> stones;

  MapCanvasPainter(this.stones);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    for (final s in stones) {
      final o = s.offset;

      final canvasOffset = Offset(o.dx * size.width, o.dy * size.height);
      canvas.drawLine(center, canvasOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MapCanvasPainter oldDelegate) {
    return oldDelegate.stones != stones;
  }
}
