import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:whote_is_there/db/app_database.dart';
import 'package:whote_is_there/map_canvas_painter.dart';

class FungusState extends ChangeNotifier {
  int id;
  Color color;
  bool isHeld;
  int? inventoryIndex;
  double normalizedX;
  double normalizedY;
  double normalizedRadius;
  Path? cachedLocalPath;

  static const Duration growthDuration = Duration(seconds: 10);
  Timer? growthTimer;
  Duration timeUntilGrowth;

  FungusState({
    required this.id,
    required this.color,
    required this.normalizedX,
    required this.normalizedY,
    required this.normalizedRadius,
    required this.inventoryIndex,
    this.isHeld = false,
    this.timeUntilGrowth = growthDuration,
  });

  void notify() => notifyListeners();

  @override
  void dispose() {
    growthTimer?.cancel();
    super.dispose();
  }

  factory FungusState.fromJson(Map<String, dynamic> json) => FungusState(
    id: json['id'] as int,
    color: Color(json['color'] as int),
    normalizedX: json['normalizedX'] as double,
    normalizedY: json['normalizedY'] as double,
    normalizedRadius: json['normalizedRadius'] as double,
    inventoryIndex: json['inventoryIndex'] as int?,
  );

  factory FungusState.fromFungusCompanion(FungiCompanion companion) => FungusState(
    id: companion.id.value!,
    color: Color(companion.color.value),
    normalizedX: companion.perX.value!,
    normalizedY: companion.perY.value!,
    normalizedRadius: .20, // TODO fix this 
    inventoryIndex: companion.invintoryIndex.value,
  );
}

extension FungusOperations on FungusState {
  Map<String, dynamic> toJson() => {
    'id': id,
    'color': color.value,
    'normalizedX': normalizedX,
    'normalizedY': normalizedY,
    'normalizedRadius': normalizedRadius,
    'inventoryIndex': inventoryIndex,
  };
  Path _generateLocalPath() {
    const int pointCount = 32;
    const Offset center = Offset(50, 50);
    final double radius = normalizedRadius * 100;
    final rand = Random();
    final List<Offset> points = [];

    for (int i = 0; i < pointCount; i++) {
      final angle = (2 * pi * i) / pointCount;
      final offsetFactor = 1 + (rand.nextDouble() * 2 - 1) * 0.25;
      final r = radius * offsetFactor;

      points.add(
        Offset(
          (center.dx + r * cos(angle)).clamp(0, 100).toDouble(),
          (center.dy + r * sin(angle)).clamp(0, 100).toDouble(),
        ),
      );
    }

    return Path()
      ..moveTo(points.first.dx, points.first.dy)
      ..addPolygon(points.skip(1).toList(), true);
  }

  Path get localPath {
    cachedLocalPath ??= _generateLocalPath();
    return cachedLocalPath!;
  }

  void invalidateLocalPath() {
    cachedLocalPath = null;
  }

  Path getScaledPath(Size canvasSize) {
    final minSide = min(canvasSize.width, canvasSize.height);
    final scale = (normalizedRadius * minSide) / 100.0;
    final center = getCenter(canvasSize);

    final matrix = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByVector3(Vector3(scale, scale, 1))
      ..translateByDouble(-50.0, -50.0, 0, 1);

    return localPath.transform(matrix.storage);
  }

  Offset getCenter(Size canvasSize) =>
      Offset(canvasSize.width * normalizedX, canvasSize.height * normalizedY);

  double getRadius(Size canvasSize) =>
      normalizedRadius * min(canvasSize.width, canvasSize.height);

  void pickUp() {
    isHeld = true;
    notify();
  }

  void drop() {
    isHeld = false;
    notify();
  }

  void move(Offset point, Size canvasSize) {
    normalizedX = point.dx / canvasSize.width;
    normalizedY = point.dy / canvasSize.height;
    notify();
  }

  bool collidesWithPath(Path otherPath, Size canvasSize) {
    final intersection = Path.combine(
      PathOperation.intersect,
      otherPath,
      getScaledPath(canvasSize),
    );
    return !intersection.getBounds().isEmpty;
  }

  bool hitTest(Offset point, Size canvasSize) =>
      getScaledPath(canvasSize).contains(point);

  void startGrowthTimer() {
    growthTimer?.cancel();
    timeUntilGrowth = FungusState.growthDuration;

    growthTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeUntilGrowth -= const Duration(seconds: 1);

      if (timeUntilGrowth <= Duration.zero) {
        timer.cancel();
        growthTimer = null;
        _grow();
      }

      notify();
    });
  }

  void _grow() {
    normalizedRadius += 0.10;
    invalidateLocalPath();
    notify();
  }
}
