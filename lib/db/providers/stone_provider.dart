

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:whote_is_there/db/app_database.dart';
import 'package:whote_is_there/map_canvas_painter.dart';

class StoneProvider extends ChangeNotifier {
  final AppDatabase db;
  List<StoneData> _stones = [];

  List<StoneData> get stones => List.unmodifiable(_stones);

  StoneProvider({required this.db}) {
    getAllStones();
  }

  Future<void> getAllStones() async {
    try {
      _stones = await db.select(db.stones).get().then(
        (rows) => rows
            .map((row) => StoneData(
                  name: row.name,
                  offset: Offset(row.offsetX, row.offsetY),
                  remoteId: row.remoteId,
                  platformName: row.platformName,
                  timeStamp: row.timeStamp,
                  serviceData: row.serviceData,
                ))
            .toList(),
      );
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<Stone?> getStoneByRemoteId(String id) async {
    try {
      return await (db.select(db.stones)..where((tbl) => tbl.remoteId.equals(id))).getSingleOrNull();
    } catch (e) {
      // Handle error
      return null;
    }
  }

  Future<void> insertStone(StoneData stoneData) async {
    try {
      await db.into(db.stones).insert( StonesCompanion(
              name: Value(stoneData.name),
              offsetX: Value(stoneData.offset.dx),
              offsetY: Value(stoneData.offset.dy),
              remoteId: Value(stoneData.remoteId),
              platformName: Value(stoneData.platformName),
              timeStamp: Value(stoneData.timeStamp),
              serviceData: Value(stoneData.serviceData),
            ),);
      _stones.add(stoneData);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
  // This is a placeholder for the actual implementation of the StoneProvider.
  // You can replace this with your actual logic to fetch and manage stone data.
}