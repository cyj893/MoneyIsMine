import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'DBHelper.dart';

class InputSpecsPage extends StatefulWidget {
  final Spec nowInstance;

  const InputSpecsPage(this.nowInstance);

  @override
  InputSpecsPageState createState() => InputSpecsPageState();
}

class InputSpecsPageState extends State<InputSpecsPage> {
  String pageName = "내역 추가";
  bool isUpdateLoaded = false;

  List<bool> typebools = [false, false];
  final List<String> typeNames = ["지출", "수입"];

  List<bool> methodbools = [false, false, false, false, false];
  final List<String> methodNames = ["기타", "카드", "이체", "현금", "기타"];

  List<bool> categorybools = [false, false, false, false, false];
  final List<String> categoryAvatars = ["\u{2733}", "\u{1F354}", "\u{1F68C}", "\u{1F455}", "\u{2733}"];
  final List<String> categoryNames = ["기타", "식비", "교통비", "의류비", "기타"];

  final contents = TextEditingController();

  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));
  final money = TextEditingController();

  late var dateTime = DateTime.now();

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
    List<Picture> newlist = await PicProvider().getQuery(
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

  int _findIndex(List<bool> list){
    for(int i = 0; i < list.length; i++){
      if( list[i] ) return i;
    }
    return -1;
  }
  void _submit(){
    int t = _findIndex(typebools);
    int m = _findIndex(methodbools);
    int c = _findIndex(categorybools);
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
    _insertDB(t, m, c);
  }
  Future<void> _insertDB(int t, int m, int c) async {
    if( m == -1 ) m = 0;  // set to default
    if( c == -1 ) c = 0;  // set to default
    final ctxt = contents.text.isEmpty ? "." : contents.text;
    var provider = SpecProvider();
    var picProvider = PicProvider();

    int pm = t == 0 ? -1 : 1;
    var spec = Spec(
        type: t,
        category: categoryNames[c],
        method: m,
        contents: ctxt,
        money: pm * int.parse(money.text.replaceAll(',', '')),
        dateTime: DateFormat('yy/MM/dd').format(dateTime));

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
    }
    else{
      spec.id = await provider.insert(spec);
      for(int i = 0; i < _images.length; i++){
        picProvider.insert(Picture(specID: spec.id!, picture: await _images[i].readAsBytes()));
      }
    }
    Navigator.pop(context, spec);
  }

  List<Widget> initTypes(int index){
    return <Widget>[
      Checkbox(
          value: typebools[index],
          onChanged: (bool? value) {
            setState(() {
              typebools[index] = value!;
              if( value ){
                for(int i = 0; i < typebools.length; i++){
                  if( i != index && typebools[i] ) typebools[i] = false;
                }
              }
            });
          }),
      Text(typeNames[index]),
    ];
  }
  Container makeTypeCon(){
    return Container(
        padding: const EdgeInsets.all(8.0),
        height: 50,
        child: Row(children: <Widget>[
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
          value: methodbools[index],
          onChanged: (bool? value) {
            setState(() {
              methodbools[index] = value!;
              if( value ){
                for(int i = 1; i < methodbools.length; i++){
                  if( i != index && methodbools[i] ) methodbools[i] = false;
                }
              }
            });
          }),
      Text(methodNames[index]),
    ];
  }
  Container makeMethodCon(){
    return Container(
        padding: const EdgeInsets.all(8.0),
        height: 50,
        child: Row(children: <Widget>[
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
    for(int i = 1; i < categoryNames.length; i++){
      list.add(
        InkWell(
          splashColor: Colors.transparent,
          child: Chip(
                avatar: CircleAvatar(
                  child: categorybools[i] ? Text("\u{2714}") : Text(categoryAvatars[i]),
                  backgroundColor: Colors.white,
                ),
                backgroundColor: categorybools[i] ? Colors.blueAccent : Colors.blue[100],
                label: categorybools[i] ? Text(categoryNames[i], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),) : Text(categoryNames[i]),
              ),
          onTap: () {
            setState(() {
                if( categorybools[i] ){
                  categorybools[i] = false;
                  return ;
                }
                categorybools[i] = true;
                print("Tapped " + categoryAvatars[i]);
                for(int j = 0; j < categorybools.length; j++){
                  if( i != j && categorybools[j] ) categorybools[j] = false;
                }
            });
          }
      ));
      list.add(SizedBox(width: 10));
    }
    return list;
  }
  Container makeCategoryCon(){
    return Container(
      padding: const EdgeInsets.all(8.0),
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
                        onPressed: () {
                          setState(() {

                          });
                        },
                        icon: Icon(Icons.format_list_bulleted)
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
      padding: const EdgeInsets.all(8.0),
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

  Container makeMoneyCon(){
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 50,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Row(
              children: <Widget>[
                Text("금액 "),
                Text("*", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
              ],
            )
          ),
          Expanded(
              child: TextField(
                controller: money,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "금액을 입력하세요",
                  isDense: true,
                  suffixText: "\₩",
                ),
                onChanged: (string) {
                  if( string.isEmpty ) return ;
                  string = '${_formatNumber(string.replaceAll(',', ''))}';
                  money.value = TextEditingValue(
                    text: string,
                    selection: TextSelection.collapsed(offset: string.length),
                  );
                },
              )
          ),
        ],
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
  Container makeDateTimeCon(){
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 50,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 100,
            child: Text("날짜"),
          ),
          Expanded(
              child: InkWell(
                child: Text("${dateTime.toLocal()}".split(' ')[0],
                          style: TextStyle(decoration: TextDecoration.underline,
                                      decorationStyle: TextDecorationStyle.dashed,
                                      fontSize: 16),
                          textAlign: TextAlign.center,),
                onTap: () {
                  _selectDate(context);
                },
              )
          ),
        ],
      ),
    );
  }
  // functions end

  Container makeMemoCon(){
    return Container(
      padding: const EdgeInsets.all(8.0),
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
                icon: Icon(Icons.add_circle, color: Colors.blue[200],),
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
        typebools[widget.nowInstance.type] = true;
        methodbools[widget.nowInstance.method! == 0 ? 3 : widget.nowInstance.method!] = true;
        if( widget.nowInstance.category == "기타" ) categorybools[categorybools.length-1] = true;
        else{
          for(int i = 0; i < categoryNames.length; i++){
            if( widget.nowInstance.category! == categoryNames[i] ){
              categorybools[i] = true;
              break;
            }
          }
        }
        contents.text = widget.nowInstance.contents!;
        money.text = _formatNumber((widget.nowInstance.money < 0 ? -widget.nowInstance.money : widget.nowInstance.money).toString().replaceAll(',', ''));
        dateTime = DateTime.parse('20'+widget.nowInstance.dateTime!.replaceAll('/', ''));
        isUpdateLoaded = true;
        _getPicDB(widget.nowInstance.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if( !isUpdateLoaded ) setInstance();
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListView(
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