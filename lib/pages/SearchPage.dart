import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:money_is_mine/pages/widgets/CustomButton.dart';
import 'package:money_is_mine/db_helper/ColorProvider.dart';

class SearchPage extends StatefulWidget {

  const SearchPage();

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState  extends State<SearchPage> {
  List<Color> paletteProvider = [];

  List<DateTime> dateRange = [DateTime.now().subtract(Duration(days: 7)), DateTime.now()];

  Future<void> _selectDate(BuildContext context, int i) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateRange[i],
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if( picked != null && picked != dateRange[i] ){
      if( i == 0 ){
        if( picked.isBefore(dateRange[1]) || picked == dateRange[1] ){
          setState(() {
            dateRange[i] = picked;
          });
        }
        else{

        }
      }
      else if( i == 1 ){
        if( picked.isAfter(dateRange[0]) || picked == dateRange[0] ){
          setState(() {
            dateRange[i] = picked;
          });
        }
        else{

        }
      }
    }
  }

  Row makeDatePicker(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
            text: "${dateRange[0].toLocal()}".split(' ')[0],
            onTap: () {
              _selectDate(context, 0);
            }),
        const Text("  ~  ", style: TextStyle(fontSize: 20),),
        CustomButton(
            text: "${dateRange[1].toLocal()}".split(' ')[0],
            onTap: () {
              _selectDate(context, 1);
            })
      ],
    );
  }

  List<List<String>> conditions = [
    ["지출/수입", "지출", "수입"],
    ["모든 카테고리"],
    ["최신순", "과거순"]
  ];
  List<int> conditionNum = [0, 0, 0];
  InkWell makeCondition(int ind){
    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          builder: (BuildContext context) {
            return Container(
              height: 300,
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(child: Container()),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: paletteProvider[2],),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Expanded(child: ListView(
                    children: List.generate(conditions[ind].length,
                            (index) => TextButton(
                                onPressed: () {
                                  conditionNum[ind] = index;
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                    index == conditionNum[ind] ? paletteProvider[0] : Colors.white
                                  ),),
                                child: Text(conditions[ind][index],
                                  style: TextStyle(
                                    color: paletteProvider[4],
                                    fontWeight: index == conditionNum[ind] ? FontWeight.bold : FontWeight.normal),)
                            )
                    ),
                  )),
                ],
              ),
            );
          },
        ).then((value) { setState(() { }); });
      },
      child: Text(conditions[ind][conditionNum[ind]]),
    );
  }

  Row makeOthers(){
    return Row(
      children: [
        SizedBox(width: 8,),
        Expanded(child: Center(child: makeCondition(0),),),
        Expanded(child: Center(child: makeCondition(1),),),
        Expanded(child: Center(child: makeCondition(2),),),
        SizedBox(width: 8,),
      ],
    );
  }

  ExpansionTile makeDetailedSearch(){
    List<Widget> list = [];

    list.add(makeDatePicker());
    list.add(SizedBox(height: 10,));
    list.add(makeOthers());
    list.add(SizedBox(height: 10,));
    list.add(IconButton(
      icon: Icon(Icons.search_rounded, color: paletteProvider[2],),
      onPressed: () {

      },
    ));
    list.add(SizedBox(height: 10,));

    return ExpansionTile(
      initiallyExpanded: true,
      title: Text("상세 검색"),
      children: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    paletteProvider = context.watch<ColorProvider>().palette;
    return Scaffold(
        appBar: AppBar(
          title: Text("검색"),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: makeDetailedSearch(),
          )
        )
    );
  }

}

