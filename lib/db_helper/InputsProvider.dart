import 'package:flutter/cupertino.dart';

import 'InputsDBHelper.dart';

class InputsProvider with ChangeNotifier {
  static final InputsProvider _inputsProvider = InputsProvider._internal();
  InputsProvider._internal(){
    _inputsDBHelper = InputsDBHelper();
  }
  factory InputsProvider() {
    return _inputsProvider;
  }

  InputsDBHelper? _inputsDBHelper;

  List<String> inputStrings = ["지출/수입", "수단", "카테고리", "내용", "금액", "날짜", "메모", "사진"];
  List<bool> inputBoolArr = [];

  void edit(List<bool> newBoolArr){
    inputBoolArr = newBoolArr;
    notifyListeners();
  }

  void init() async {
    inputBoolArr = await _inputsDBHelper!.init();
  }

  void save() async {
    await _inputsDBHelper!.save(inputStrings, inputBoolArr);
  }

}

