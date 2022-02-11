import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:money_is_mine/pages/widgets/CustomButton.dart';
import 'package:money_is_mine/pages/widgets/MoneyTextField.dart';
import 'package:provider/provider.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:io';
import 'CategoryEditPage.dart';
import '../db_helper/DBHelper.dart';
import '../db_helper/ColorProvider.dart';

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

  int typeBool = -1;
  final List<String> typeNames = ["지출", "수입"];

  int methodBool = -1;
  final List<String> methodNames = ["기타", "카드", "이체", "현금", "기타"];

  int categoryBool = -1;
  List<String> categoryNames = ["기타"];
  Map<String, String> categoryMap = {"기타": "*"};

  final contents = TextEditingController();

  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));
  final money = TextEditingController();

  late var dateTime = DateTime.now();
  int nowPage = 0;
  int mw = 0;
  List<List<String>> mwArr = [List.generate(31, (index) => (index+1).toString()), ["월", "화", "수", "목", "금", "토", "일"]];
  List<List<bool>> mwBoolArr = [List.generate(31, (index) => false), List.generate(7, (index) => false),];
  bool isFixed = false;
  int repeatVal = 1;

  final memo = TextEditingController();

  final ImagePicker picker = ImagePicker();
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
      WHERE specID = ${i}
      '''
    );
    setState(() {
      _existingImages = newlist;
    });
    print("Pic Here ${_existingImages.length}");
    return newlist;
  }

  void _submit(){
    int t = typeBool;
    int m = methodBool;
    int c = categoryBool;
    if( t == -1 || money.text.isEmpty ){
      print("reject submitting");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("지출/수입 여부와 금액을 입력해 주세요"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("ok"))
              ],
            );
          });
      return ;
    }
    if( isFixed ) _insertFixed(t, m, c);
    else _insertDB(t, m, c, dateTime);
  }
  void _insertFixed(int t, int m, int c){
    if( mw == 0 ){
      for(int i = 0; i < 31; i++){
        DateTime date = DateTime.now();
        if( mwBoolArr[mw][i] == false ) continue;
        date = DateTime(date.year, date.month, int.parse(mwArr[mw][i]));
        for(int j = 0; j < repeatVal; j++){
          _insertDB(t, m, c, date);
          date = DateTime(date.year, date.month + 1, date.day);
        }
      }
    }
    else{
      for(int i = 0; i < 7; i++){
        DateTime date = DateTime.now();
        if( mwBoolArr[mw][i] == false ) continue;
        date = date.subtract(Duration(days: date.weekday - 1 - i));
        for(int j = 0; j < repeatVal; j++){
          _insertDB(t, m, c, date);
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
    if( !isFixed) Navigator.pop(context, spec);
  }

  List<Widget> initTypes(int index){
    return <Widget>[
      Checkbox(
        activeColor: paletteProvider[1],
          value: typeBool == index,
          onChanged: (bool? value) {
            setState(() {
              if( value == true ) typeBool = index;
              else typeBool = -1;
            });
          }),
      Text(typeNames[index]),
    ];
  }
  Container makeTypeCon(){
    return Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        height: 50,
        child: Row(
          children: <Widget>[
          Text("*", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
          Expanded(child:Row(children: initTypes(0))),
          Expanded(child:Row(children: initTypes(1))),
        ],
        )
    );
  }

  List<Widget> initMethods(int index){
    return <Widget>[
      Checkbox(
        activeColor: paletteProvider[1],
          value: methodBool == index,
          onChanged: (bool? value) {
            setState(() {
              if( value == true ) methodBool = index;
              else methodBool = -1;
            });
          }),
      Text(methodNames[index]),
    ];
  }
  Container makeMethodCon(){
    return Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        height: 50,
        child: Row(
          children: <Widget>[
          Expanded(child:Row(children: initMethods(1))),
          Expanded(child:Row(children: initMethods(2))),
          Expanded(child:Row(children: initMethods(3))),
          Expanded(child:Row(children: initMethods(4))),
        ],
        )
    );
  }

  List<Widget> initCategories(){
    List<Widget> list = [];
    for(int i = 0; i < categoryNames.length; i++){
      list.add(
        InkWell(
          splashColor: Colors.transparent,
          child: Chip(
                avatar: CircleAvatar(
                  child: categoryBool == i ? Text("\u{2714}") : Text(categoryMap[categoryNames[i]]!),
                  backgroundColor: Colors.white,
                ),
                backgroundColor: categoryBool == i ? paletteProvider[3] : paletteProvider[0],
                label: categoryBool == i ? Text(categoryNames[i], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),) : Text(categoryNames[i]),
              ),
          onTap: () {
            setState(() {
                if( categoryBool == i ){
                  categoryBool = -1;
                  return ;
                }
                categoryBool = i;
                print("Tapped " + categoryMap[categoryNames[i]]!);
            });
          }
      ));
      list.add(SizedBox(width: 10));
    }
    return list;
  }
  Container makeCategoryCon(){
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: 50,
      child: Row(
        children: <Widget>[
          SizedBox(
              width: 100,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("카테고리"),
                    IconButton(
                      iconSize: 20,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoryEditPage()
                            )
                        );
                      },
                      icon: Icon(Icons.format_list_bulleted_rounded),
                      color: paletteProvider[1],
                    ),
                  ]
              )
          ),
          Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: initCategories(),
              )
          ),
        ],
      ),
    );
  }

  Container makeContentsCon(){
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: 50,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 100,
            child: Text("내용"),
          ),
          Expanded(
              child: TextField(
                controller: contents,
                decoration: const InputDecoration(
                  hintText: "내용을 입력하세요",
                  isDense: true,
                ),
              )
          ),
        ],
      ),
    );
  }

  void addMoney(int addVal){
    if( money.text == "" ) money.text = '${_formatNumber(addVal.toString().replaceAll(',', ''))}';
    else{
      int newVal = int.parse(money.text.replaceAll(',', '')) + addVal;
      money.text = '${_formatNumber(newVal.toString().replaceAll(',', ''))}';
    }
  }

  Widget makeButtons(){
    return isMoneyFocused
    ? Column(
      children: [
        SizedBox(height: 10,),
        Row(
          children: [
            CustomButton( onTap: () { addMoney(1000); }, text: "+1천", textColor: paletteProvider[3], ),
            CustomButton( onTap: () { addMoney(5000); }, text: "+5천", textColor: paletteProvider[3], ),
            CustomButton( onTap: () { addMoney(10000); }, text: "+1만", textColor: paletteProvider[3], ),
            CustomButton( onTap: () { addMoney(50000); }, text: "+5만", textColor: paletteProvider[3], ),
            CustomButton( onTap: () { addMoney(100000); }, text: "+10만", textColor: paletteProvider[3], ),
            CustomButton( onTap: () { addMoney(1000000); }, text: "+100만", textColor: paletteProvider[3], ),
          ],
        )
      ],
    )
    : SizedBox.shrink();
  }

  bool isMoneyFocused = false;
  FocusNode focusNode = FocusNode();
  AnimatedContainer makeMoneyCon(){
    focusNode.addListener(() { isMoneyFocused = focusNode.hasFocus; });
    return AnimatedContainer(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: isMoneyFocused ? 100 : 50,
      duration: Duration(milliseconds: 300),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: <Widget>[
                SizedBox(
                    width: 100,
                    child: Row(
                      children: const [
                        Text("금액 "),
                        Text("*", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                      ],
                    )
                ),
                Expanded(
                  child: MoneyTextField(
                    controller: money,
                    focusNode: focusNode,
                  ),
                ),
              ],
            ),
            makeButtons(),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if( picked != null && picked != dateTime ){
      setState(() {
        dateTime = picked;
      });
    }
  }
  void showFixedDialog(){
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                    title: Text("고정 지출/수입일"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            isFixed = false;
                            Navigator.of(context).pop();
                          },
                          child: Text("취소")),
                      TextButton(
                          onPressed: () {
                            isFixed = true;
                            Navigator.of(context).pop();
                          },
                          child: Text("저장")),
                    ],
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() { mw = 1 - mw; });
                              },
                              child: Chip(
                                label: Text(mw == 0 ? "매월" : "매주",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                backgroundColor: paletteProvider[1],
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Container(
                                height: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        children: List.generate(
                                            mwBoolArr[mw].length,
                                                (index) => mwBoolArr[mw][index]
                                                ? Text("${mwArr[mw][index]}, ")
                                                : SizedBox.shrink()),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showDialog(context: context, builder: (context) {
                                            return AlertDialog(
                                              content: Wrap(
                                                children: List.generate(mwArr[mw].length, (index) => InkWell(
                                                    onTap: () {
                                                      mwBoolArr[mw][index] = !mwBoolArr[mw][index];
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Chip(
                                                      label: Text(mwArr[mw][index], style: TextStyle(color: mwBoolArr[mw][index] ? Colors.white : Colors.black, fontWeight: mwBoolArr[mw][index] ? FontWeight.bold : FontWeight.normal),),
                                                      backgroundColor: mwBoolArr[mw][index] ? paletteProvider[3] : paletteProvider[0],
                                                    ))),
                                              ),
                                            );
                                          });
                                        },
                                        icon: Icon(Icons.add_circle_outline_rounded, color: paletteProvider[1],)),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text(mw == 0 ? "일" : "요일"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NumberPicker(
                                selectedTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: paletteProvider[3]),
                                minValue: 1,
                                maxValue: 100,
                                value: repeatVal,
                                textStyle: TextStyle(color: Colors.grey),
                                onChanged: (val){
                                  setState(() { repeatVal = val; });
                                }),
                            Text("회  반복"),
                          ],
                        )
                      ],
                    )
                );
              });
        }).then((value) => setState(() {}));
  }
  PageController _controller = PageController(initialPage: 0);
  Container makeDateTimeCon(){
    String mwStr = mw == 0 ? "매월" : "매주";
    String things = "";
    for(int i = 0; i < mwArr[mw].length; i++){
      if( mwBoolArr[mw][i] ) things += mwArr[mw][i] + ", ";
    }
    things = things == "" ? "?" : things.substring(0, things.length-2);
    String mwStr2 = mw == 0 ? "일" : "요일";
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: 50,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(nowPage == 0 ? "날짜" : "고정일자"),
                IconButton(
                  onPressed: () {
                    if( nowPage == 0 ) _controller.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeIn);
                    else _controller.previousPage(duration: Duration(milliseconds: 400), curve: Curves.easeIn);
                  },
                  icon: nowPage == 0 ? const Icon(Icons.arrow_forward_ios_rounded) : const Icon(Icons.arrow_back_ios_rounded),
                  color: paletteProvider[1],),
              ],
            ),
          ),
          Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    nowPage = index;
                  });
                },
                children: [
                  Center(
                    child: InkWell(
                      child: Text("${dateTime.toLocal()}".split(' ')[0],
                        style: TextStyle(decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dashed,
                            fontSize: 16),
                        textAlign: TextAlign.center,),
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                  ),
                  Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () { showFixedDialog(); },
                            child: Text("$mwStr $things$mwStr2 $repeatVal회 반복"),
                          ),
                          IconButton(
                              onPressed: () { showFixedDialog(); },
                              icon: Icon(Icons.edit_rounded, color: paletteProvider[1],))
                        ],
                      )
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Container makeMemoCon(){
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: 50,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 100,
            child: Text("메모"),
          ),
          Expanded(
              child: TextField(
                controller: memo,
                decoration: const InputDecoration(
                  hintText: "메모를 입력하세요",
                  isDense: true,
                ),
              )
          ),
        ],
      ),
    );
  }

  Container makePicCon(){
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: MediaQuery.of(context).size.width / 3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + _existingImages.length + 1,
        itemBuilder: (context, index) {
          if( index == 0 ) {
            return IconButton(
                iconSize: 25,
                icon: Icon(Icons.add_circle, color: paletteProvider[1],),
                onPressed: () async {
                  List<XFile>? images = await picker.pickMultiImage();
                  if( images != null ){
                    setState(() {
                      _images.addAll(images);
                    });
                  }
                },
              );
          }
          if( picbools.contains(index) ) return SizedBox.shrink();
          if( index <= _existingImages.length ){
            return InkWell(
              onLongPress: () {
                setState(() {
                  picbools.add(index);
                });
              },
              child: Image.memory(_existingImages[index-1].picture),
            );
          }
          return InkWell(
            onLongPress: () {
              setState(() {
                picbools.add(index);
              });
            },
            child: Image.file(File(_images[index-_existingImages.length-1].path)),
          );
        },
      )
    );
  }

  void setInstance(){
    if( widget.nowInstance.type != -1 ){
      if( widget.nowInstance.type == -2 ){
        dateTime = DateTime.parse('20'+widget.nowInstance.dateTime!.replaceAll('/', ''));
      }
      else{
        pageName = "내역 수정";
        typeBool = widget.nowInstance.type;
        methodBool = widget.nowInstance.method! == 0 ? 3 : widget.nowInstance.method!;
        for(int i = 0; i < categoryNames.length; i++){
          if( widget.nowInstance.category! == categoryNames[i] ){
            categoryBool = i;
            break;
          }
        }
        contents.text = widget.nowInstance.contents! != "." ? widget.nowInstance.contents! : "";
        money.text = _formatNumber((widget.nowInstance.money < 0 ? -widget.nowInstance.money : widget.nowInstance.money).toString().replaceAll(',', ''));
        dateTime = DateTime.parse('20'+widget.nowInstance.dateTime!.replaceAll('/', ''));
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
                makeTypeCon(), Divider(),
                makeMethodCon(), Divider(),
                makeCategoryCon(), Divider(),
                makeContentsCon(), Divider(),
                makeMoneyCon(), Divider(),
                makeDateTimeCon(), Divider(),
                makeMemoCon(), Divider(),
                makePicCon(), Divider(),
              ],
            ),
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _submit();
        },
        child: Icon(Icons.check_rounded),
      ),
    );
  }
}

