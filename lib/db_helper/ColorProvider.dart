import 'package:flutter/material.dart';

enum ColorType { defaultColor, purple, blue }

List<List<Color>> allPalette = [
  [Colors.blue[100]!,Colors.blue[200]!, Colors.blue[300]!, Colors.blue, const Color(0xff043e6e)],
  const [Color(0xffe8daf0), Color(0xffe0caed), Color(0xffd4abeb), Color(0xff8c22f3), Color(0xff400875)],
  const [Color(0xffe8e8e8), Color(0xffc9c9c9), Color(0xffadadad), Color(0xff858585), Color(0xff545454)],

];

class ColorProvider with ChangeNotifier {
  int _nowIndex = ColorType.defaultColor.index;
  List<Color> _palette = allPalette[ColorType.defaultColor.index];

  List<Color> get palette => _palette;
  int get nowIndex => _nowIndex;

  void changeColor(int index){
    _palette = allPalette[index];
    _nowIndex = index;
    notifyListeners();
  }
}
