import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'pair.dart';
import 'models/spec_model.dart';

class DaySpecDBHelper {
  static final DaySpecDBHelper _daySpecProvider = DaySpecDBHelper._internal();
  DaySpecDBHelper._internal();
  factory DaySpecDBHelper() {
    return _daySpecProvider;
  }

  static Database? _database;
  final String tableName = 'DaySpecs';

  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    print("DaySpec Helper");
    String path = join(await getDatabasesPath(), 'DaySpecs.db');
    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE DaySpecs(
              expenditure INT NOT NULL,
              income INT NOT NULL,
              dateTime TEXT NOT NULL,
              day INT NOT NULL
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  Future<void> insert(Spec spec, int day) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: "dateTime = ?",
        whereArgs: [spec.dateTime]);
    int expenditure = 0;
    int income = 0;
    if( maps.isEmpty ){
      print("no");
      await db.insert(
          tableName,
          {
            "expenditure": spec.type == 0 ? spec.money : 0,
            "income": spec.type == 1 ? spec.money : 0,
            "dateTime": spec.dateTime,
            "day": day
          });
      return ;
    }
    else{
      expenditure = maps[0]["expenditure"];
      income = maps[0]["income"];
    }

    await db.update(
      tableName,
      spec.type == 0 ? {"expenditure": expenditure + spec.money}
          : {"income": income + spec.money},
      where: "dateTime = ?",
      whereArgs: [spec.dateTime],
    );

    print("DaySpec ${spec.dateTime} ${expenditure} ${income} Added ${spec.money}");
  }

  Future<void> update(Spec spec, int day, Spec before) async {
    await delete(before);
    await insert(spec, day);

    print("DaySpec ${spec.dateTime} Updated");
  }

  Future<void> delete(Spec spec) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: "dateTime = ?",
        whereArgs: [spec.dateTime]);
    int expenditure = 0;
    int income = 0;
    if( maps.isEmpty ) return ;
    else{
      expenditure = maps[0]["expenditure"];
      income = maps[0]["income"];
    }

    await db.update(
      tableName,
      spec.type == 0 ? {"expenditure": expenditure - spec.money}
          : {"income": income - spec.money},
      where: "dateTime = ?",
      whereArgs: [spec.dateTime],
    );
    print("DaySpec ${spec.dateTime} Updated(delete)");
  }

  Future<List<List<Pair>>> getAvgQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if( maps.isEmpty ) return [];

    List<List<Pair>> list = [[], []];
    for(int i = 0; i < maps.length; i++){
      list[0].add(Pair(maps[i]["day"], maps[i]["expenditure"] ?? 0));
      list[1].add(Pair(maps[i]["day"], maps[i]["income"] ?? 0));
    }
    return list;
  }

  Future<List<Map<String, int>>> getDateQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if( maps.isEmpty ) return [{}, {}, {}];

    List<Map<String, int>> list = [{}, {}, {}];
    for(int i = 0; i < maps.length; i++){
      list[0][maps[i]["dateTime"]] = maps[i]["expenditure"] ?? 0;
      list[1][maps[i]["dateTime"]] = maps[i]["income"] ?? 0;
      list[2][maps[i]["dateTime"]] = (maps[i]["expenditure"] ?? 0) + (maps[i]["income"] ?? 0);
    }
    return list;
  }

  Future<List<List<Pair>>> getWeekQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if( maps.isEmpty ) return [[], []];

    List<List<Pair>> list = [[], []];
    for(int i = 0; i < maps.length; i++){
      list[0].add(Pair(maps[i]["dateTime"], maps[i]["expenditure"]));
      list[1].add(Pair(maps[i]["dateTime"], maps[i]["income"]));
    }
    return list;
  }
}
