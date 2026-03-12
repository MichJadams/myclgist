import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whote_is_there/Fungus/fungus_base.dart';
import 'package:whote_is_there/Fungus/fungus_state.dart';
import 'package:whote_is_there/db/providers/fungus_provider.dart';
import 'package:whote_is_there/terrarium/conversion_utilities.dart';
import 'package:whote_is_there/terrarium/fungus_drag_controller.dart';
import 'package:whote_is_there/terrarium/fungus_view.dart';
import 'package:whote_is_there/terrarium/seed_box.dart';

class FungusDishView extends StatefulWidget {

  const FungusDishView({super.key});

  @override
  State<FungusDishView> createState() => _FungusDishViewState();
}

class DrawerState {
  final GlobalKey key;
  bool hasFungus = false;
  FungusState? fungusState;
  DrawerState({required this.key, required this.hasFungus, this.fungusState});
}

class _FungusDishViewState extends State<FungusDishView>
    with FungusHitTestMixin, FungusInventoryMixin {
  final _drag = FungusDragController();
  final GlobalKey _dishKey = GlobalKey();
  final GlobalKey _inventoryKey = GlobalKey();
  List<DrawerState> _drawers = [];

  @override
  GlobalKey get dishKey => _dishKey;
  @override
  GlobalKey get inventoryKey => _inventoryKey;
  @override
  List<DrawerState> get drawers => _drawers;

  void _handlePointerDown(PointerDownEvent event, FungusDish dish) {
    final fungus = fungusAtPoint(event.position, dish);
    if (fungus != null) {
      _drag.startDrag(
        fungus: fungus,
        globalPosition: event.position,
        context: context,
        dishKey: _dishKey,
      );
    }
    // Inventory slots are lifted via long press — see _startDragFromDrawer.
  }

  void _startDragFromDrawer(DrawerState drawer, FungusState fungus, Offset position) {
    _drag.startDrag(
      fungus: fungus,
      globalPosition: position,
      context: context,
      dishKey: _dishKey,
    );
    // Clear inventoryIndex now so the next build filters this fungus out of
    // _drawers immediately, emptying the slot without waiting for a DB round-trip.
    fungus.inventoryIndex = null;
    context.read<FungusProvider>().updateFungusInventoryIndex(fungus.id, null);
    setState(() {});
  }

  void _handlePointerUp(PointerUpEvent event, FungusDish dish) {
    if (!_drag.isDragging) return;
    final fungus = _drag.heldFungus!;
    final dishRect = rectFromKey(_dishKey);

    if (dishRect.contains(event.position)) {
      final localPos = globalToLocal(_dishKey, event.position);
      final oldPos = fungus.getCenter(dishRect.size);
      fungus.move(localPos, dishRect.size);

      if (hasCollision(fungus, dishRect.size, dish)) {
        fungus.move(oldPos, dishRect.size);
      } else {
        removeFromInventory(fungus);
      }
    } else {
      final drawer = drawerAtPoint(event.position);
      if (drawer != null) placeIntoInventory(fungus, drawer);
    }

    setState(() => _drag.endDrag());
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_drag.isDragging) _drag.updateDrag(event.position);
  }

  @override
  Widget build(BuildContext context) {
    final fungi = context.watch<FungusProvider>().fungi;
    final dish = createDish(fungi);
    

        // Build one slot per fungus, indexed by inventoryIndex so that slot i
        // always shows the fungus whose inventoryIndex == i. This is what makes
        // a fungus visually land at the slot it was dropped on — changing
        // inventoryIndex changes which slot renders it, not just null/non-null.
        final allStates = dish.states.values.toList();
        final totalSlots = allStates.length;
        _drawers = List.generate(totalSlots, (i) {
          final state = allStates.where((s) => s.inventoryIndex == i).firstOrNull;
          return DrawerState(
            key: GlobalKey(),
            hasFungus: state != null,
            fungusState: state,
          );
        });
    return Listener(
      onPointerDown: (event) {
        _handlePointerDown(event, dish);
      },
      onPointerUp: (event) {
        _handlePointerUp(event, dish);
      },
      onPointerMove: (event) {
        _handlePointerMove(event);
      },
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasWidth = constraints.maxWidth;
                return Center(
                  child: SizedBox(
                    width: canvasWidth,
                    height: canvasWidth,
                    child: Stack(
                      key: _dishKey,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.brown.shade200,
                            shape: BoxShape.rectangle, // dish from above
                          ),
                        ),
                        for (final fun in dish.fungi)
                          if (dish.states[fun.id] case final state)
                            if (state?.inventoryIndex == null && state?.isHeld != true)
                              FungusView(fungus: fun, state: state!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: SeedBox(
            inventoryKey: _inventoryKey,
            slots: _drawers,
            onSlotLongPress: _startDragFromDrawer,
            isDragging: _drag.isDragging,
          ),
          ),
        ],
      ),
    );
  }
}

class FungusDish {
  final int id;
  final double humidity;
  final double lightLevel;

  final List<FungusBase> fungi;
  final Map<int, FungusState> states;

  FungusDish({
    required this.id,
    required this.humidity,
    required this.lightLevel,
    required this.fungi,
    required this.states,
  });
}


FungusDish createDish(List<FungusState> fungi) {
  final states = {for (var f in fungi) f.id: f};

  return FungusDish(
    id: 1,
    humidity: 0.5,
    lightLevel: 0.5,
    fungi: states.entries.map((e) => FungusBase(id: e.key, name: "")).toList(),
    states: states,
  );
}
