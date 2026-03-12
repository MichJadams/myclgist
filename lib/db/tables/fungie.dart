import 'package:drift/drift.dart';

@DataClassName('Fungus')
class Fungi extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get invintoryIndex => integer().nullable()();
  BoolColumn get isNew => boolean()();
  RealColumn get perX => real().nullable()();
  RealColumn get perY => real().nullable()();
  IntColumn get color => integer()();
  TextColumn get remoteId => text()();
  TextColumn get platformName => text()();
  TextColumn get serviceData => text()();
  TextColumn get spottedTime => text()();
}
