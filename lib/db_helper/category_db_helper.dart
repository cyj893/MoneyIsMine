import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CategoryDBHelper {
  static final CategoryDBHelper _categoryProvider = CategoryDBHelper._internal();
  CategoryDBHelper._internal();
  factory CategoryDBHelper() {
    return _categoryProvider;
  }

  static Database? _database;

  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    print("Category Helper");
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

  Future<List> init() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
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
    return [tempcategories, tempmap];
  }

  Future<void> save(List categories, Map map) async {
    final db = await database;
    await db.rawQuery("DELETE FROM Categories");
    for(int i = 0; i < categories.length; i++){
      await db.insert("Categories", {"name": categories[i], "icon": map[categories[i]]});
    }
  }

}
