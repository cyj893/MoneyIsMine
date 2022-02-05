import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DBHelper.dart';
import 'MyTheme.dart';

class CategoryEditPage extends StatefulWidget {

  @override
  CategoryEditPageState createState() => CategoryEditPageState();
}

class CategoryEditPageState extends State<CategoryEditPage> {
  List<Color> paletteProvider = [];

  String pageName = "카테고리 수정";

  final _icon = TextEditingController();
  final _name = TextEditingController();

  List<String> categoryNames = ["기타"];
  Map<String, String> categoryMap = {"기타": "*"};
  List<String> tempcategoryNames = [];
  Map<String, String> tempcategoryMap = {};

  @override
  void initState() {
    super.initState();

    categoryNames = context.read<CategoryProvider>().categories;
    categoryMap = context.read<CategoryProvider>().map;
    tempcategoryNames.addAll(categoryNames);
    tempcategoryMap.addAll(categoryMap);
  }

  Container makeAddCon(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: TextField(
              controller: _icon,
              maxLength: 2,
              decoration: const InputDecoration(
                hintText: "\u{1F4B0}",
                isDense: true,
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(
              child: TextField(
                controller: _name,
                maxLength: 10,
                decoration: const InputDecoration(
                  hintText: "Category Name",
                  isDense: true,
                ),
              )
          ),
          VerticalDivider(),
          SizedBox(
            width: 50,
            child: IconButton(
              icon: Icon(Icons.add_rounded),
              color: paletteProvider[2],
              iconSize: 20.0,
              onPressed: () {
                if( tempcategoryMap.containsKey(_name.text) ){
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text("이름이 달라야 합니다"),
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
                setState(() {
                  tempcategoryMap[_name.text] = _icon.text;
                  tempcategoryNames.insert(0, _name.text);
                  _icon.text = "";
                  _name.text = "";
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  ReorderableListView makeReorderListV(){
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if( oldIndex < newIndex ) newIndex -= 1;
          final String item = tempcategoryNames.removeAt(oldIndex);
          tempcategoryNames.insert(newIndex, item);
        });
      },
      children: <Widget>[
        for(int i = 0; i < tempcategoryNames.length; i++)
          ListTile(
            tileColor: Colors.white,
            key: Key('$i'),
            title: Container(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: CircleAvatar(
                    child: Text(tempcategoryMap[tempcategoryNames[i]]!),
                    backgroundColor: Colors.white,
                  ),
                  backgroundColor: paletteProvider[0],
                  label: Text(tempcategoryNames[i]),
                )
            ),
            trailing: tempcategoryNames[i] == "기타" ?
              SizedBox.shrink()
            : IconButton(
              icon: Icon(Icons.delete_forever_rounded),
              color: paletteProvider[2],
              iconSize: 25.0,
              onPressed: () {
                setState(() {
                  tempcategoryMap.removeWhere((key, value) => key == tempcategoryNames[i]);
                  tempcategoryNames.removeAt(i);
                });
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    paletteProvider = context.watch<ColorProvider>().palette;
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
        actions: [
          OutlinedButton(
            onPressed: () {
              context.read<CategoryProvider>().edit(tempcategoryNames, tempcategoryMap);
              context.read<CategoryProvider>().save();
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(Icons.save_rounded, color: Colors.white,),
                Text(" 저장", style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                makeAddCon(),
                Expanded(child: makeReorderListV()),
              ],
            )
        ),
      ),
    );
  }
}