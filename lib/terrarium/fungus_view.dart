
import 'package:flutter/material.dart';
import 'package:whote_is_there/Fungus/fungus_base.dart';
import 'package:whote_is_there/Fungus/fungus_painter.dart';
import 'package:whote_is_there/Fungus/fungus_state.dart';

class FungusView extends StatelessWidget {
  final FungusBase fungus;
  final FungusState state;

  const FungusView({
    super.key,
    required this.fungus,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FungusPainter(state),
      child: SizedBox.expand(),
    );
  }
}





