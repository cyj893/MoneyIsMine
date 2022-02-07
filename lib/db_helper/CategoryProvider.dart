import 'package:flutter/cupertino.dart';
import 'CategoryDBHelper.dart';

class CategoryProvider with ChangeNotifier {
  static final CategoryProvider _categoryProvider = CategoryProvider._internal();
  CategoryProvider._internal(){
    _categoryHelper = CategoryDBHelper();
  }
  factory CategoryProvider() {
    return _categoryProvider;
  }

  CategoryDBHelper? _categoryHelper;

  List<String> categories = [];
  Map<String, String> map = {};

  void edit(List<String> newCategories, Map<String, String> newMap){
    map = newMap;
    categories = newCategories;
    notifyListeners();
  }

  void init() async {
    List list = await _categoryHelper!.init();
    categories = list[0];
    map = list[1];
  }

  void save() async {
    await _categoryHelper!.save(categories, map);
  }

}

