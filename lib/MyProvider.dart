import 'package:flutter/material.dart';
import 'DBHelper.dart';

class MyProvider with ChangeNotifier {
  Map<String, List<Spec>> map = {};

  List<Spec> get(String s){
    return map.containsKey(s) ? map[s]! : [];
  }

  void add(s, list) {
    map[s] = list;
    notifyListeners();
  }

}