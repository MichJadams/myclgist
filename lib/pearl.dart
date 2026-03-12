
import 'package:flutter/material.dart';
import 'package:whote_is_there/models/perl_data.dart';

class Perl extends StatelessWidget {
  final double size;
  final PearlData data;
  final bool isPlaced;

  const Perl({
    required this.size,
    required this.data,
    required this.isPlaced,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<PearlData>(
      data: data,
      feedback: SizedBox(
        height: size,
        width: size,
        child: Image.asset("assets/pearl_dragging.png"),
      ),
      childWhenDragging: SizedBox(
        height: size,
        width: size,
        child: Image.asset("assets/pearl_socket.png"),
      ),
      child: SizedBox(
        height: size,
        width: size,
        child: Image.asset(
          isPlaced
              ? "assets/pearl_socket.png"
              : "assets/pearl.png",
        ),
      ),
    );
  }
}