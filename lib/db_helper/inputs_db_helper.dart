import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class InputsDBHelper {
  static final InputsDBHelper _inputsDBHelper = InputsDBHelper._internal();
  InputsDBHelper._internal();
  factory InputsDBHelper() {
    return _inputsDBHelper;
  }

  static Database? _database;

  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    print("Inputs Helper");
    String path = join(await getDatabasesPath(), 'Inputs.db');
    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE Inputs(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              isShow INTEGER
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  Future<List<bool>> init() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM Inputs
      ORDER BY id;
      '''
    );
    List<bool> tempBoolArr = [];
    if( maps.isEmpty ){
      tempBoolArr = List.generate(8, (index) => true);
    }
    else{
      for(int i = 0; i < maps.length; i++){
        tempBoolArr.add(maps[i]["isShow"] == 1);
      }
    }
    return tempBoolArr;
  }

  Future<void> save(List names, List boolArr) async {
    final db = await database;
    await db.rawQuery("DELETE FROM Inputs");
    for(int i = 0; i < names.length; i++){
      await db.insert("Inputs", {"name": names[i], "isShow": boolArr[i] ? 1 : 0});
    }
  }

}
