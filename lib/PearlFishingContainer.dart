
import 'package:flutter/material.dart';
import 'package:whote_is_there/map_canvas_painter.dart';
import 'package:whote_is_there/map_scaffold.dart';
import 'package:whote_is_there/pearl_scaffold.dart';
import 'package:whote_is_there/models/perl_data.dart';
import 'package:whote_is_there/permission_handler.dart';

class PerlFishingContainer extends StatefulWidget {
  final void Function(StoneData) onStoneTapped;
  
  const PerlFishingContainer({required this.onStoneTapped, super.key});

  @override
  State<StatefulWidget> createState() => _PerlFishingContainer();
}

class _PerlFishingContainer extends State<PerlFishingContainer> {
  final Set<int> placedPearls = {};

  void onPearlPlaced(PearlData data) {
    setState(() {
      placedPearls.add(data.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BluetoothPermissionHandler(
      child: Column(
      children: [
        Expanded(flex: 3, child: MapScaffild(onPearlPlaced: onPearlPlaced, onStoneTapped: widget.onStoneTapped)),
        Expanded(flex: 1, child: PearlScaffold(placedPearls: placedPearls)),
      ],
    ),
    );
  }
}