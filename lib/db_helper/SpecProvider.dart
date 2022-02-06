import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Pair.dart';
import 'models/SpecModel.dart';

class SpecProvider {
  static SpecProvider _specProvider = SpecProvider._internal();
  SpecProvider._internal();
  factory SpecProvider() {
    return _specProvider;
  }

  static late Database _database;
  final String tableName = 'Specs';

  Future<Database?> get database async {
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'Specs.db');
    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Specs(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type INTEGER NOT NULL,
              category TEXT,
              method INTEGER, 
              contents TEXT,
              money INT NOT NULL,
              dateTime TEXT,
              memo TEXT
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  Future<int?> insert(Spec spec) async {
    final db = await database;
    print("Specs insert ${spec.type} ${spec.category} ${spec.method} ${spec.contents} ${spec.money} ${spec.dateTime} ${spec.memo}");
    spec.id = await db?.insert(tableName, spec.toMap());
    return spec.id;
  }

  Future<void> update(Spec spec) async {
    final db = await database;
    print("Specs update ${spec.type} ${spec.category} ${spec.method} ${spec.contents} ${spec.money} ${spec.dateTime} ${spec.memo}");
    await db?.update(
      tableName,
      spec.toMap(),
      where: "id = ?",
      whereArgs: [spec.id],
    );
  }

  Future<void> delete(Spec spec) async {
    final db = await database;
    print("Specs delete ${spec.type} ${spec.category} ${spec.method} ${spec.contents} ${spec.money} ${spec.dateTime} ${spec.memo}");
    await db?.delete(
      tableName,
      where: "id = ?",
      whereArgs: [spec.id],
    );
  }

  Future<List<Spec>> getDB() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(tableName);
    if( maps.isEmpty ) return [];
    List<Spec> list = List.generate(maps.length, (index) {
      return Spec(
        id: maps[index]["id"],
        type: maps[index]["type"],
        category: maps[index]["category"],
        method: maps[index]["method"],
        contents: maps[index]["contents"],
        money: maps[index]["money"],
        dateTime: maps[index]["dateTime"],
        memo: maps[index]["memo"],
      );
    });
    return list;
  }

  Future<List<Spec>> getQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    if( maps.isEmpty ) return [];
    List<Spec> list = List.generate(maps.length, (index) {
      return Spec(
        id: maps[index]["id"],
        type: maps[index]["type"],
        category: maps[index]["category"],
        method: maps[index]["method"],
        contents: maps[index]["contents"],
        money: maps[index]["money"],
        dateTime: maps[index]["dateTime"],
        memo: maps[index]["memo"],
      );
    });
    return list;
  }

  Future<Map<String, int>> getSumQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    if( maps.isEmpty ) return {};

    Map<String, int> map = {};
    for(int i = 0; i < maps.length; i++){
      map[maps[i]["dateTime"]] = maps[i]["SUM(money)"];
    }
    return map;
  }

  Future<List<Pair>> getCategorySumQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    if( maps.isEmpty ) return [];

    List<Pair> list = [];
    for(int i = 0; i < maps.length; i++){
      list.add(Pair(maps[i]["category"], maps[i]["SUM(money)"]));
    }
    return list;
  }

  Future<List<int>> getSummaryQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    if( maps.isEmpty ) return [0, 0];

    List<int> list = [];
    list.add(maps[0]["expenditure"]);
    list.add(maps[0]["income"]);
    return list;
  }

}
