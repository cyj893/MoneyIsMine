import 'package:flutter/material.dart';

enum ColorType { defaultColor, purple, blue }

List<List<Color>> allPalette = [
  [Colors.blue[100]!,Colors.blue[200]!, Colors.blue[300]!, Colors.blue],
  const [Color(0xffe8daf0), Color(0xffe0caed), Color(0xffd4abeb), Color(0xff8c22f3)],

];

class ColorProvider with ChangeNotifier {
  List<Color> _palette = allPalette[ColorType.defaultColor.index];

  List<Color> get palette => _palette;

  void changeColor(ColorType colorType){
    _palette = allPalette[colorType.index];
    notifyListeners();
  }
}
