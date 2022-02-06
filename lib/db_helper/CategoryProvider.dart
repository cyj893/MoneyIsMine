import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CategoryProvider with ChangeNotifier {
  static CategoryProvider _categoryProvider = CategoryProvider._internal();
  CategoryProvider._internal();
  factory CategoryProvider() {
    return _categoryProvider;
  }

  List<String> categories = [];
  Map<String, String> map = {};

  static late Database _database;

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
    await db!.rawQuery("DELETE FROM Categories");
    for(int i = 0; i < categories.length; i++){
      await db.insert("Categories", {"name": categories[i], "icon": map[categories[i]]});
    }
  }

}
