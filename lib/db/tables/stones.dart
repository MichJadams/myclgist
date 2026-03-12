// tables/stone.dart
import 'package:drift/drift.dart';

class Stones extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get offsetX => real()();
  RealColumn get offsetY => real()();
  TextColumn get name => text()();
  TextColumn get remoteId => text()();
  TextColumn get platformName => text()();
  TextColumn get serviceData => text()();
  TextColumn get timeStamp => text()();
}