import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../db_helper/DBHelper.dart';
import 'package:money_is_mine/pages/widgets/MoneyTextField.dart';
import '../db_helper/ColorProvider.dart';
import 'input_specs/DateTimeCon.dart';
import 'input_specs/TypeCon.dart';
import 'input_specs/MethodCon.dart';
import 'input_specs/CategoryCon.dart';
import 'input_specs/ContentsCon.dart';
import 'input_specs/MoneyCon.dart';
import 'input_specs/MemoCon.dart';
import 'input_specs/PicCon.dart';

class InputSpecsPage extends StatefulWidget {
  final Spec nowInstance;

  const InputSpecsPage(this.nowInstance);

  @override
  InputSpecsPageState createState() => InputSpecsPageState();
}

class InputSpecsPageState extends State<InputSpecsPage> {
  List<Color> paletteProvider = [];

  String pageName = "내역 추가";
  bool isUpdateLoaded = false;

  List<int> typeBool = [-1];

  List<int> methodBool = [-1];

  List<int> categoryBool = [-1];
  List<String> categoryNames = ["기타"];
  Map<String, String> categoryMap = {"기타": "*"};

  final contents = TextEditingController();

  final money = TextEditingController();

  List<DateTime> dateTime = [DateTime.now()];
  List<int> nowPage = [0];
  List<int> mw = [0];
  List<List<bool>> mwBoolArr = [List.generate(31, (index) => false), List.generate(7, (index) => false),];
  List<bool> isFixed = [false];
  List<int> repeatVal = [1];

  final memo = TextEditingController();

  List<int> picbools = [];
  List<XFile> _images = [];
  List<Picture> _existingImages = [];
  // values end

  @override
  void initState() {
    super.initState();
  }

  void onGoBack(dynamic value) {
    ;
  }

  Future<List<Picture>> _getPicDB(int i) async {
    List<Picture> newlist = await PicDBHelper().getQuery(
      '''
      SELECT * FROM Pics
      WHERE specID = $i
      '''
    );
    setState(() {
      _existingImages = newlist;
    });
    print("Pic Here ${_existingImages.length}");
    return newlist;
  }

  void _submit(){
    int t = typeBool[0];
    int m = methodBool[0];
    int c = categoryBool[0];
    if( t == -1 || money.text.isEmpty ){
      print("reject submitting");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("지출/수입 여부와 금액을 입력해 주세요"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("ok"))
              ],
            );
          });
      return ;
    }
    if( isFixed[0] ) _insertFixed(t, m, c, dateTime[0]);
    else _insertDB(t, m, c, dateTime[0]);
  }

  Future<void> _insertFixed(int t, int m, int c, DateTime dt) async {
    if( mw[0] == 0 ){
      for(int i = 0; i < 31; i++){
        DateTime date = dt;
        if( mwBoolArr[mw[0]][i] == false ) continue;
        date = DateTime(date.year, date.month, i+1);
        for(int j = 0; j < repeatVal[0]; j++){
          await _insertDB(t, m, c, date);
          date = DateTime(date.year, date.month + 1, date.day);
        }
      }
    }
    else{
      for(int i = 0; i < 7; i++){
        DateTime date = DateTime.now();
        if( mwBoolArr[mw[0]][i] == false ) continue;
        date = date.subtract(Duration(days: date.weekday - 1 - i));
        for(int j = 0; j < repeatVal[0]; j++){
          await _insertDB(t, m, c, date);
          date = DateTime(date.year, date.month, date.day + 7);
        }
      }
    }
    Navigator.pop(context);
  }

  Future<void> _insertDB(int t, int m, int c, DateTime dt) async {
    m = m == -1 ? 0 : m;  // set to default
    String cate = c == -1 ? "기타" : categoryNames[c];  // set to default
    final ctxt = contents.text.isEmpty ? "." : contents.text;
    final mtxt = memo.text.isEmpty ? "." : memo.text;
    var provider = SpecDBHelper();
    var dayProvider = DaySpecDBHelper();
    var picProvider = PicDBHelper();

    int pm = t == 0 ? -1 : 1;
    var spec = Spec(
        type: t,
        category: cate,
        method: m,
        contents: ctxt,
        money: pm * int.parse(money.text.replaceAll(',', '')),
        dateTime: DateFormat('yy/MM/dd').format(dt),
        memo: mtxt);

    for(int i = 0; i < picbools.length; i++){
      int index = picbools[i];
      if( index > _existingImages.length ) _images.removeAt(index-_existingImages.length-1);
      else picProvider.delete(_existingImages[index-1]);
    }
    if( isUpdateLoaded ){
      spec.id = widget.nowInstance.id;
      provider.update(spec);
      for(int i = 0; i < _images.length; i++){
        picProvider.insert(Picture(specID: spec.id!, picture: await _images[i].readAsBytes()));
      }
      dayProvider.update(spec, dt.weekday, widget.nowInstance);
    }
    else{
      spec.id = await provider.insert(spec);
      for(int i = 0; i < _images.length; i++){
        picProvider.insert(Picture(specID: spec.id!, picture: await _images[i].readAsBytes()));
      }
      dayProvider.insert(spec, dt.weekday);
    }
    if( !isFixed[0]) Navigator.pop(context, spec);
  }

  void setInstance(){
    if( widget.nowInstance.type != -1 ){
      if( widget.nowInstance.type == -2 ){
        dateTime[0] = DateTime.parse('20'+widget.nowInstance.dateTime!.replaceAll('/', ''));
      }
      else{
        pageName = "내역 수정";
        typeBool[0] = widget.nowInstance.type;
        methodBool[0] = widget.nowInstance.method! == 0 ? 3 : widget.nowInstance.method!;
        for(int i = 0; i < categoryNames.length; i++){
          if( widget.nowInstance.category! == categoryNames[i] ){
            categoryBool[0] = i;
            break;
          }
        }
        contents.text = widget.nowInstance.contents! != "." ? widget.nowInstance.contents! : "";
        money.text = moneyToString(widget.nowInstance.money < 0 ? -widget.nowInstance.money : widget.nowInstance.money);
        dateTime[0] = DateTime.parse('20'+widget.nowInstance.dateTime!.replaceAll('/', ''));
        memo.text = widget.nowInstance.memo! != "." ? widget.nowInstance.memo! : "";
        isUpdateLoaded = true;
        _getPicDB(widget.nowInstance.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    paletteProvider = context.watch<ColorProvider>().palette;
    categoryNames = context.watch<CategoryProvider>().categories;
    categoryMap = context.watch<CategoryProvider>().map;
    if( !isUpdateLoaded ) setInstance();
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TypeCon(typeBool, paletteProvider[1]), const Divider(),
                MethodCon(methodBool, paletteProvider[1]), const Divider(),
                CategoryCon(categoryBool, categoryNames, categoryMap,
                    paletteProvider[0], paletteProvider[1], paletteProvider[3]), const Divider(),
                ContentsCon(contents), const Divider(),
                MoneyCon(money, paletteProvider[3]), const Divider(),
                DateTimeCon(dateTime, nowPage, mw, mwBoolArr,
                    isFixed, repeatVal, paletteProvider[0], paletteProvider[1], paletteProvider[3]), const Divider(),
                MemoCon(memo), const Divider(),
                PicCon(picbools, _images, _existingImages, paletteProvider[1]), const Divider(),
              ],
            ),
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){ _submit(); },
        child: const Icon(Icons.check_rounded),
      ),
    );
  }
}

