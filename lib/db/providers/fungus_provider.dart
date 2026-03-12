import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:whote_is_there/Fungus/fungus_state.dart';
import 'package:whote_is_there/db/app_database.dart';
import 'package:whote_is_there/terrarium/invintory_page.dart';

class FungusProvider extends ChangeNotifier {
  final AppDatabase db;
  List<FungusState> _fungi = [];
  bool isLoading = false;
  String? error;

  FungusProvider({required this.db}) {
    print('FungusProvider created');
    getAllFungus();
  }

  List<FungusState> get fungi => List.unmodifiable(_fungi);

  Future<void> getAllFungus() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _fungi = await db
          .select(db.fungi)
          .get()
          .then((rows) => rows.map(fungusFromDb).toList());
    } catch (e) {
      error = e.toString();
      print("Error fetching fungi: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> getAllFungusAsJson() async {
    final rows = await db.select(db.fungi).get();
    final json = rows.map(fungusToJson).join(",\n");

    return json;
  }

  Future<void> updateFungusInventoryIndex(int id, int? inventoryIndex) async {
    // Notify immediately — the FungusState object in _fungi is the same
    // reference mutated by the caller, so _fungi already reflects the change.
    notifyListeners();
    try {
      await (db.update(db.fungi)..where((tbl) => tbl.id.equals(id)))
          .write(FungiCompanion(invintoryIndex: Value(inventoryIndex)));
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> returnAllToSeedbox() async {
    final terrariumFungi = _fungi.where((f) => f.inventoryIndex == null).toList();
    if (terrariumFungi.isEmpty) return;

    final usedIndexes = _fungi.map((f) => f.inventoryIndex).toSet();
    for (final fungus in terrariumFungi) {
      int index = 0;
      while (usedIndexes.contains(index)) {
        index++;
      }
      fungus.inventoryIndex = index;
      usedIndexes.add(index);
    }

    notifyListeners();

    for (final fungus in terrariumFungi) {
      try {
        await (db.update(db.fungi)..where((tbl) => tbl.id.equals(fungus.id)))
            .write(FungiCompanion(invintoryIndex: Value(fungus.inventoryIndex)));
      } catch (e) {
        error = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> insertFungus(FungiCompanion newFungus) async {
    error = null;

    try {
      await db.into(db.fungi).insert(newFungus);
      await getAllFungus();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

FungusState fungusFromDb(Fungus f) {
  final state = FungusState(
    id: f.id,
    normalizedRadius: 0.5,
    normalizedX: f.perX ?? 0.5,
    normalizedY: f.perY ?? 0.5,
    color: Color(f.color),
    inventoryIndex: f.invintoryIndex,
  );

  return state;
}
