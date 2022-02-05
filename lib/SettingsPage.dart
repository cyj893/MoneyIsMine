import 'package:flutter/material.dart';
import 'package:money_is_mine/MyTheme.dart';
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

  Row makePalette(int ind){
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
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
      ));
      list.add(SizedBox(width: 5,));
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
          icon: Icon(Icons.save_rounded, color: allPalette[nowColorIndex][2],)),);
    }
    return Row(
      children: list,
    );
  }

  ExpansionTile makeColorSelect(){
    return ExpansionTile(
      title: Text("색상"),
        children: [makePalette(0),makePalette(1),],
    );
  }

  @override
  Widget build(BuildContext context) {
    paletteProvider = context.watch<ColorProvider>().palette;
    return Scaffold(
        appBar: AppBar(
          title: Text("설정"),
          backgroundColor: allPalette[nowColorIndex][3],
        ),
        body: Padding(
            padding: EdgeInsets.all(8.0),
            child: ListView(
              children: [
                makeColorSelect(),
                Divider(),
              ],
            ),
        )
    );
  }

}

