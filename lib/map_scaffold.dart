import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whote_is_there/animated_void_painter.dart';
import 'package:whote_is_there/bluetooth_scanner.dart';
import 'package:whote_is_there/map_canvas_painter.dart';
import 'package:whote_is_there/models/perl_data.dart';
import 'package:whote_is_there/pearl_socket.dart';

class MapScaffild extends StatefulWidget {
  final void Function(PearlData) onPearlPlaced;
  final void Function(StoneData) onStoneTapped;
  const MapScaffild({
    required this.onPearlPlaced,
    required this.onStoneTapped,
    super.key,
  });

  @override
  State<MapScaffild> createState() => _MapScaffildState();
}

double randomValue() {
  final rand = Random();
  double value;

  do {
    value = rand.nextDouble() * (0.98 - 0.01) + 0.01;
  } while (value >= 0.48 && value <= 0.55);

  return value;
}

class _MapScaffildState extends State<MapScaffild>
    with SingleTickerProviderStateMixin {
  final List<StoneData> stones = [];
  late final AnimationController _voidController;

  @override
  void initState() {
    super.initState();
    _voidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 48),
    )..repeat();
  }

  @override
  void dispose() {
    _voidController.dispose();
    super.dispose();
  }

  Future<void> onPearlAccepted(PearlData pearlData) async {
    widget.onPearlPlaced(pearlData);
    var results = await blueScan();
    print("scan complete ${results.length} results found");
    List<StoneData> stonesInter = [];
    for (final result in results.entries) {
      // print('--------------------------- ${result.value}');

      final manufacturerData = result
          .value
          .advertisementData
          .manufacturerData
          .entries
          .map(
            (e) => e.value
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(' '),
          )
          .join('; ');
      var stone = StoneData(
        offset: Offset(randomValue(), randomValue()),
        name: manufacturerData,
        remoteId: result.value.device.remoteId.toString(),
        platformName: result.value.device.platformName,
        timeStamp: result.value.timeStamp.toString(),
        serviceData: result.value.advertisementData.serviceData.entries.map((e) => e.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')).join('; '),
      );
      stonesInter.add(stone);
    }
    print("settings");
    setState(() {
      stones
        ..clear()
        ..addAll(stonesInter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            AnimatedBuilder(
              animation: _voidController,
              builder: (context, _) => CustomPaint(
                size: Size.infinite,
                painter: AnimatedVoidPainter(
                  animationValue: _voidController.value,
                ),
              ),
            ),
            CustomPaint(size: Size.infinite, painter: MapCanvasPainter(stones)),
            Center(
              child: SizedBox(
                height: 75,
                child: PearlSocket(onPearlAccepted: onPearlAccepted),
              ),
            ),
            for (final stoneData in stones)
              Positioned(
                left: stoneData.offset.dx * width - 25,
                top: stoneData.offset.dy * height - 25,
                child: BurriedStone(
                  stoneData: stoneData,
                  onTap: () => widget.onStoneTapped(stoneData),
                ),
              ),
          ],
        );
      },
    );
  }
}
