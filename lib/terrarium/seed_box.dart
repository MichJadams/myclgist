import 'package:flutter/material.dart';
import 'package:whote_is_there/Fungus/fungus_state.dart';
import 'package:whote_is_there/terrarium/fungus_dish.dart';

class InvintorySlot extends StatefulWidget {
  final FungusState? fungusState;
  final GlobalKey slotKey;
  final void Function(FungusState fungus, Offset globalPosition)? onLongPressStart;

  const InvintorySlot({
    super.key,
    required this.fungusState,
    required this.slotKey,
    this.onLongPressStart,
  });

  @override
  State<InvintorySlot> createState() => _InvintorySlotState();
}

class _InvintorySlotState extends State<InvintorySlot> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.slotKey,
      onLongPressDown: widget.fungusState != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onLongPressStart: widget.fungusState != null && widget.onLongPressStart != null
          ? (details) {
              setState(() => _isPressed = false);
              widget.onLongPressStart!(widget.fungusState!, details.globalPosition);
            }
          : null,
      onLongPressCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.65 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: widget.fungusState != null
                  ? widget.fungusState!.color
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.fungusState != null
                ? Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset("assets/pearl.png"),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class SeedBox extends StatelessWidget {
  final GlobalKey<State<StatefulWidget>> inventoryKey;
  final List<DrawerState> slots;
  final void Function(DrawerState drawer, FungusState fungus, Offset position)? onSlotLongPress;
  final bool isDragging;

  const SeedBox({
    super.key,
    required this.inventoryKey,
    required this.slots,
    this.onSlotLongPress,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      key: inventoryKey,
      physics: isDragging ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
      crossAxisCount: slots.isEmpty ? 1 : slots.length.clamp(1, 4),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      children: [
        for (final slot in slots)
          InvintorySlot(
            fungusState: slot.fungusState,
            slotKey: slot.key,
            onLongPressStart: onSlotLongPress != null
                ? (fungus, pos) => onSlotLongPress!(slot, fungus, pos)
                : null,
          ),
      ],
    );
  }
}
