
import 'package:flutter/material.dart';
import 'package:whote_is_there/models/perl_data.dart';

class PearlSocket extends StatefulWidget {
  final void Function(PearlData) onPearlAccepted;

  const PearlSocket({required this.onPearlAccepted, super.key});

  @override
  State<StatefulWidget> createState() => _PearlSocket();
}

class _PearlSocket extends State<PearlSocket> {
  bool isHovering = false;
  bool isActivated = false;
  Widget _buildSocketVisual() {
    if (isActivated) {
      return Image.asset(
        'assets/socket_open.png',
        key: const ValueKey('activated'),
        // height: 75,
      );
    }

    if (isHovering) {
      return Image.asset(
        'assets/socket_open.png',
        key: const ValueKey('open'),
        // height: 75,
      );
    }

    return Image.asset(
      'assets/socket_closed.png',
      key: const ValueKey('closed'),
      // height: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<PearlData>(
      onWillAcceptWithDetails: (data) {
        setState(() {
          isHovering = true;
        });
        return true; // accept pearls
      },
      onLeave: (data) {
        setState(() {
          isHovering = false;
        });
      },
      onAcceptWithDetails: (details) {
        setState(() {
          isHovering = false;
          isActivated = true;
        });
        widget.onPearlAccepted(details.data);
      },
      builder: (BuildContext context, candidateData, rejectedData) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildSocketVisual(),
        );
      },
    );
  }
}
