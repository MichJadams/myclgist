

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whote_is_there/Fungus/fungus_painter.dart';
import 'package:whote_is_there/Fungus/fungus_state.dart';
import 'package:whote_is_there/db/providers/fungus_provider.dart';
import 'package:whote_is_there/terrarium/conversion_utilities.dart';
import 'package:whote_is_there/terrarium/fungus_dish.dart';


mixin FungusHitTestMixin on State<FungusDishView> {
  GlobalKey get dishKey;
  GlobalKey get inventoryKey;
  List<DrawerState> get drawers;

  FungusState? fungusAtPoint(Offset globalPosition, FungusDish dish) {
    final dishRect = rectFromKey(dishKey);
    if (!dishRect.contains(globalPosition)) return null;

    final local = globalToLocal(dishKey, globalPosition);
    return dish.states.values
        .where((s) => s.hitTest(local, dishRect.size))
        .firstOrNull;
  }

  DrawerState? drawerAtPoint(Offset globalPosition) {
    final inventoryRect = rectFromKey(inventoryKey);
    if (!inventoryRect.contains(globalPosition)) return null;

    return drawers
        .where((d) => rectFromKey(d.key).contains(globalPosition))
        .firstOrNull;
  }

  bool hasCollision(FungusState fungus, Size canvasSize, FungusDish dish) {
    return dish.states.values
        .where((s) => s.id != fungus.id)
        .any(
          (s) =>
              s.collidesWithPath(fungus.getScaledPath(canvasSize), canvasSize),
        );
  }
}

mixin FungusInventoryMixin on State<FungusDishView> {
  List<DrawerState> get drawers;

  void placeIntoInventory(FungusState fungus, DrawerState targetDrawer) {
    final targetIndex = drawers.indexOf(targetDrawer);
    print("target drawer is ${targetDrawer.key} and fungus state of target drawer is ${targetIndex}");
    
    if (targetDrawer.fungusState != null){
      swapInInventory(fungus, targetDrawer);
      return;
    }

    setState(() {
      final oldSlot = drawers.where((d) => d.fungusState?.id == fungus.id).firstOrNull;
      if (oldSlot != null) oldSlot.fungusState = null;
      drawers[targetIndex].fungusState = fungus;
      fungus.inventoryIndex = targetIndex;
    });
    print("this is the fungus id ${fungus.id} and the inventory index is ${fungus.inventoryIndex}");
    context.read<FungusProvider>().updateFungusInventoryIndex(fungus.id, targetIndex);
  }

  void swapInInventory(FungusState fungus, DrawerState targetDrawer) {
    final targetIndex = drawers.indexOf(targetDrawer);
    final targetFungus = targetDrawer.fungusState!;
    final sourceDrawer = drawers.where((d) => d.fungusState?.id == fungus.id).firstOrNull;
    final sourceIndex = sourceDrawer != null ? drawers.indexOf(sourceDrawer) : null;

    setState(() {
      if (sourceDrawer != null) sourceDrawer.fungusState = targetFungus;
      targetDrawer.fungusState = fungus;
      fungus.inventoryIndex = targetIndex;
      targetFungus.inventoryIndex = sourceIndex;
    });
    final provider = context.read<FungusProvider>();
    provider.updateFungusInventoryIndex(fungus.id, targetIndex);
    provider.updateFungusInventoryIndex(targetFungus.id, sourceIndex);
  }

  void removeFromInventory(FungusState fungus) {
    if (fungus.inventoryIndex == null) return;
    final originDrawer = drawers
        .where((d) => d.fungusState?.id == fungus.id)
        .firstOrNull;
    if (originDrawer != null) originDrawer.fungusState = null;
    fungus.inventoryIndex = null;
    context.read<FungusProvider>().updateFungusInventoryIndex(fungus.id, null);
  }
}


class FungusDragController {
  FungusState? heldFungus;
  Offset? cursorPos;
  OverlayEntry? _dragOverlay;

  bool get isDragging => heldFungus != null;

  void startDrag({
    required FungusState fungus,
    required Offset globalPosition,
    required BuildContext context,
    required GlobalKey dishKey,
  }) {
    heldFungus = fungus;
    cursorPos = globalPosition;
    fungus.pickUp();

    _dragOverlay = OverlayEntry(
      builder: (_) {
        final dishRect = rectFromKey(dishKey);
        return Positioned(
          left: cursorPos!.dx - (fungus.normalizedX * dishRect.width),
          top: cursorPos!.dy - (fungus.normalizedY * dishRect.height),
          child: IgnorePointer(
            child: _DragOverlayContent(fungus: fungus, dishSize: dishRect.size),
          ),
        );
      },
    );
    Overlay.of(context).insert(_dragOverlay!);
  }

  void updateDrag(Offset globalPosition) {
    cursorPos = globalPosition;
    _dragOverlay?.markNeedsBuild();
  }

  void endDrag() {
    heldFungus?.drop();
    heldFungus = null;
    cursorPos = null;
    _dragOverlay?.remove();
    _dragOverlay = null;
  }
}

class _DragOverlayContent extends StatefulWidget {
  final FungusState fungus;
  final Size dishSize;

  const _DragOverlayContent({required this.fungus, required this.dishSize});

  @override
  State<_DragOverlayContent> createState() => _DragOverlayContentState();
}

class _DragOverlayContentState extends State<_DragOverlayContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    // easeOutBack gives a slight overshoot (the "pop") then settles at 1.15×.
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.dishSize.width;
    final h = widget.dishSize.height;
    final fx = widget.fungus.normalizedX;
    final fy = widget.fungus.normalizedY;

    // Scale is anchored to the fungus centre within the dish-sized canvas so
    // the item appears to lift from exactly where it was sitting.
    final alignment = Alignment(fx * 2 - 1, fy * 2 - 1);

    return ScaleTransition(
      scale: _scale,
      alignment: alignment,
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Soft shadow ellipse rendered just below the fungus centre.
            Positioned(
              left: fx * w - 22,
              top: fy * h + 10,
              child: Container(
                width: 44,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 198, 11, 11),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.40),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            // Fungus painted at its normalised position, same as the canvas.
            CustomPaint(painter: FungusPainter(widget.fungus)),
          ],
        ),
      ),
    );
  }
}
