import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableName = 'Specs';
final String picTableName = 'Pics';

class SpecProvider {
  late Database _database;

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

class DaySpecProvider {
  late Database _database;

  Future<Database?> get database async {
    _database = await initDB();
    return _database;
  }

  initDB() async {
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

    final List<Map<String, dynamic>> maps = await db!.query(
        "DaySpecs",
        where: "dateTime = ?",
        whereArgs: [spec.dateTime]);
    int expenditure = 0;
    int income = 0;
    if( maps.isEmpty ){
      print("no");
      await db.insert("DaySpecs", {"expenditure": 0, "income": 0, "dateTime": spec.dateTime, "day": day});
    }
    else{
      expenditure = maps[0]["expenditure"];
      income = maps[0]["income"];
    }

    await db.update(
      "DaySpecs",
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

    final List<Map<String, dynamic>> maps = await db!.query(
        "DaySpecs",
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
      "DaySpecs",
      spec.type == 0 ? {"expenditure": expenditure - spec.money}
                     : {"income": income - spec.money},
      where: "dateTime = ?",
      whereArgs: [spec.dateTime],
    );
    print("DaySpec ${spec.dateTime} Updated(delete)");
  }

  Future<List<List<Pair>>> getAvgQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    print("!!!!!!-----------${maps.length}");
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
    final List<Map<String, dynamic>> maps = await db!.rawQuery(query);
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
    final List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    if( maps.isEmpty ) return [[], []];

    List<List<Pair>> list = [[], []];
    for(int i = 0; i < maps.length; i++){
      list[0].add(Pair(maps[i]["dateTime"], maps[i]["expenditure"]));
      list[1].add(Pair(maps[i]["dateTime"], maps[i]["income"]));
    }
    return list;
  }
}

class Spec {
  int? id;
  int type;
  String? category;
  int? method;
  String? contents;
  int money;
  String? dateTime;
  String? memo;

  Spec({this.id, required this.type, this.category, this.method, this.contents, required this.money, this.dateTime, this.memo});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'type': type,
      'category': category,
      'method': method,
      'contents': contents,
      'money': money,
      'dateTime': dateTime,
      'memo' : memo,
    };
  }

}


class PicProvider {
  late Database _database;

  Future<Database?> get database async {
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'Pics.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Pics(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              specID INTEGER NOT NULL,
              picture BLOB NOT NULL
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  Future<void> insert(Picture pic) async {
    final db = await database;
    print("Pics insert ${pic.specID}");
    pic.id = await db?.insert(picTableName, pic.toMap());
  }

  Future<void> delete(Picture pic) async {
    final db = await database;
    print("Pics delete ${pic.specID}");
    await db?.delete(
      picTableName,
      where: "id = ?",
      whereArgs: [pic.id],
    );
  }

  Future<void> deleteSpec(int specID) async {
    final db = await database;
    print("Pics delete all ${specID}");
    await db?.delete(
      picTableName,
      where: "specID = ?",
      whereArgs: [specID],
    );
  }

  Future<List<Picture>> getDB() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(picTableName);
    if( maps.isEmpty ) return [];
    List<Picture> list = List.generate(maps.length, (index) {
      return Picture(
        id: maps[index]["id"],
        specID: maps[index]["specID"],
        picture: maps[index]["picture"],
      );
    });
    return list;
  }

  Future<List<Picture>> getQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    if( maps.isEmpty ) return [];
    List<Picture> list = List.generate(maps.length, (index) {
      return Picture(
        id: maps[index]["id"],
        specID: maps[index]["specID"],
        picture: maps[index]["picture"],
      );
    });
    return list;
  }

}

class Picture {
  int? id;
  int specID;
  Uint8List picture;

  Picture({this.id, required this.specID, required this.picture});

  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "specID": specID,
      "picture" : picture,
    };
  }
}

class CategoryProvider with ChangeNotifier {
  List<String> categories = [];
  Map<String, String> map = {};

  late Database _database;

  void edit(List<String> newCategories, Map<String, String> newMap){
    map = newMap;
    categories = newCategories;
    notifyListeners();
  }

  Future<Database?> get database async {
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'Categories.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Categories(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              icon TEXT
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  void init() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.rawQuery(
      '''
      SELECT * FROM Categories
      ORDER BY id;
      '''
    );

    List<String> tempcategories = [];
    Map<String, String> tempmap = {};
    if( maps.isEmpty ){
      tempcategories.add("기타");
      tempmap["기타"] = "*";
    }
    else{
      for(int i = 0; i < maps.length; i++){
        tempcategories.add(maps[i]["name"]);
        tempmap[maps[i]["name"]] = maps[i]["icon"];
      }
    }
    categories = tempcategories;
    map = tempmap;
  }

  void save() async {
    final db = await database;
    await db!.rawQuery(
      '''
      DELETE FROM Categories
      '''
    );
    for(int i = 0; i < categories.length; i++){
      await db.insert("Categories", {"name": categories[i], "icon": map[categories[i]]});
    }
  }

}

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}