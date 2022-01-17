import 'dart:async';
import 'dart:typed_data';
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

  Future<List<int>> getSummaryQuery(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    if( maps.isEmpty ) return [0, 0];

    print(maps);
    List<int> list = [];
    list.add(maps[0]["expenditure"]);
    list.add(maps[0]["income"]);
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
    String path = join(await getDatabasesPath(), 'Piccs.db');

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