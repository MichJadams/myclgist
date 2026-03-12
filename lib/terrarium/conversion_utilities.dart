import 'package:flutter/material.dart';

Offset globalToLocal(GlobalKey key, Offset global) {
  final box = key.currentContext!.findRenderObject() as RenderBox;
  return box.globalToLocal(global);
}

Rect rectFromKey(GlobalKey key) {
  final box = key.currentContext!.findRenderObject() as RenderBox;
  final pos = box.localToGlobal(Offset.zero);
  return pos & box.size;
}