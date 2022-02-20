import 'package:flutter/material.dart';
import 'package:money_is_mine/db_helper/InputsProvider.dart';
import '../db_helper/ColorProvider.dart';
import 'package:provider/src/provider.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage();

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState  extends State<SettingsPage> {
  List<Color> paletteProvider = [];
  List<bool> colorBoolArr = List.generate(allPalette.length, (index) => false);
  int nowColorIndex = 0;

  ListTile makePalette(int ind){
    List<Widget> list = [];
    list.add(Checkbox(
        activeColor: allPalette[ind][1],
        value: colorBoolArr[ind],
        onChanged: (bool? value) {
          setState(() {
            colorBoolArr[ind] = value!;
            nowColorIndex = ind;
            if( value ){
              for(int i = 0; i < colorBoolArr.length; i++){
                if( i != ind && colorBoolArr[i] ) colorBoolArr[i] = false;
              }
            }
          });
        }));
    for(int i = 0; i < allPalette[ind].length; i++){
      list.add(Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border.all(color: allPalette[ind][i]),
          color: allPalette[ind][i],
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
      ));
      list.add(const SizedBox(width: 5,));
    }
    if( ind == 0 ){
      list.add(Expanded(child: Container(),));
      list.add(IconButton(
          onPressed: () {
            for(int i = 0; i < colorBoolArr.length; i++){
              if( colorBoolArr[i] ){
                context.read<ColorProvider>().changeColor(i);
                break;
              }
            }
          },
          icon: Icon(Icons.save_rounded, color: paletteProvider[2],)),);
    }
    return ListTile(title: Row(children: list),);
  }

  ExpansionTile makeColorSelect(){
    return ExpansionTile(
      title: const Text("색상"),
        children: List.generate(allPalette.length, (index) => makePalette(index)),
    );
  }

  @override
  void initState(){
    super.initState();

    inputStrings = context.read<InputsProvider>().inputStrings;
    inputBoolArr = context.read<InputsProvider>().inputBoolArr;
    tempInputBoolArr.addAll(inputBoolArr);
    print("inputStrings: $inputStrings");
  }

  List<String> inputStrings = [];
  List<bool> inputBoolArr = [];
  List<bool> tempInputBoolArr = [];

  ListTile makeCheckBoxes(int ind){
    List<Widget> list = [];
    list.add(Checkbox(
        activeColor: paletteProvider[1],
        value: tempInputBoolArr[ind],
        onChanged: (bool? value) {
          if( inputStrings[ind] == "지출/수입" || inputStrings[ind] == "금액" ) return ;
          setState(() {
            tempInputBoolArr[ind] = value!;
          });
        }));
    List<Widget> rowList = [];
    rowList.add(Text(inputStrings[ind]));
    if( inputStrings[ind] == "지출/수입" || inputStrings[ind] == "금액" ){
      rowList.add(const Text(" *(필수)", style: TextStyle(color: Colors.orange),));
    }
    else if( inputStrings[ind] == "카테고리" || inputStrings[ind] == "날짜" ){
      rowList.add(Text(" (권장)", style: TextStyle(color: paletteProvider[3]),));
    }
    list.add(Row(children: rowList,));
    list.add(const SizedBox(width: 5,));

    if( ind == 0 ){
      list.add(Expanded(child: Container(),));
      list.add(IconButton(
          onPressed: () {
            context.read<InputsProvider>().edit(tempInputBoolArr);
            context.read<InputsProvider>().save();
          },
          icon: Icon(Icons.save_rounded, color: paletteProvider[2],)),);
    }
    return ListTile(
      key: Key('$ind'),
      title: Row(children: list,),
    );
  }

  ExpansionTile makeInputSelect(){
    return ExpansionTile(
      title: const Text("내역 추가 페이지"),
      children: List.generate(inputStrings.length, (index) => makeCheckBoxes(index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    paletteProvider = context.watch<ColorProvider>().palette;
    return Scaffold(
        appBar: AppBar(
          title: const Text("설정"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                makeColorSelect(),
                const Divider(),
                makeInputSelect(),
                const Divider(),
              ],
            ),
        )
    );
  }

}

