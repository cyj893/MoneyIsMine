import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableName = 'Specs';

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
              type INTEGER,
              category TEXT,
              method INTEGER, 
              contents TEXT,
              money INT,
              dateTime TEXT
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion){}
     );
  }

  Future<Spec> insert(Spec spec) async {
    final db = await database;
    await db?.insert(tableName, spec.toMap());
    print("Spec insert");
    return spec;
  }

  Future<List<Spec>> getDB() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(tableName);
    if( maps.isEmpty ) return [];
    var res = await db.query(tableName);
    List<Spec> list = List.generate(maps.length, (index) {
      return Spec(
        maps[index]["type"],
        maps[index]["category"],
        maps[index]["method"],
        maps[index]["contents"],
        maps[index]["money"],
        maps[index]["dateTime"],
      );
    });
    return list;
  }
}

class Spec {
  int? type;
  String? category;
  int? method;
  String? contents;
  int? money;
  String? dateTime;

  Spec(this.type, this.category, this.method, this.contents, this.money, this.dateTime);

  Map<String, dynamic> toMap(){
    return {
      'type': type,
      'category': category,
      'method': method,
      'contents': contents,
      'money': money,
      'dateTime': dateTime,
    };
  }

}