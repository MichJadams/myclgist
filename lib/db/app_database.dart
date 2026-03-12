import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whote_is_there/db/tables/fungie.dart';
import 'package:whote_is_there/db/tables/stones.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Stones, Fungi])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/app.db');

    return NativeDatabase(file);
  });
}

Future<void> nukeDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/app.db');
  
  if (await file.exists()) {
    await file.delete();
    print('Database nuked');
  }
}
