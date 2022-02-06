import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/PictureModel.dart';

class PicProvider {
  static PicProvider _picProvider = PicProvider._internal();
  PicProvider._internal();
  factory PicProvider() {
    return _picProvider;
  }

  static late Database _database;
  final String tableName = 'Pics';

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
    pic.id = await db?.insert(tableName, pic.toMap());
  }

  Future<void> delete(Picture pic) async {
    final db = await database;
    print("Pics delete ${pic.specID}");
    await db?.delete(
      tableName,
      where: "id = ?",
      whereArgs: [pic.id],
    );
  }

  Future<void> deleteSpec(int specID) async {
    final db = await database;
    print("Pics delete all ${specID}");
    await db?.delete(
      tableName,
      where: "specID = ?",
      whereArgs: [specID],
    );
  }

  Future<List<Picture>> getDB() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(tableName);
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
