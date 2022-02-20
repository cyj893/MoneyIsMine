import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_is_mine/db_helper/category_provider.dart';
import 'package:money_is_mine/db_helper/db_helper.dart';
import 'package:money_is_mine/pages/spec_page.dart';
import 'package:money_is_mine/pages/widgets/money_textfield.dart';
import 'package:provider/src/provider.dart';
import 'package:money_is_mine/pages/widgets/custom_button.dart';
import 'package:money_is_mine/db_helper/color_provider.dart';

class SearchPage extends StatefulWidget {

  const SearchPage();

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState  extends State<SearchPage> {
  List<Color> paletteProvider = [];

  List<DateTime> dateRange = [DateTime.now().subtract(Duration(days: 7)), DateTime.now()];
  List<Spec> _resSpecs = [];

  List<String> categoryNames = ["기타"];

  List<List<String>> conditions = [
    ["지출/수입", "지출", "수입"],
    ["모든 카테고리"],
    ["최신순", "과거순"]
  ];
  List<int> conditionNum = [0, 0, 0];

  bool isEmptyRes = false;

  FutureOr onGoBack(dynamic value) {
    setState(() {
      print("onGoBack");
    });
  }

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
          // Todo: Toast
        }
      }
      else if( i == 1 ){
        if( picked.isAfter(dateRange[0]) || picked == dateRange[0] ){
          setState(() {
            dateRange[i] = picked;
          });
        }
        else{
          // Todo: Toast
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
      child: Row(
        children: [
          SizedBox(width: 10,),
          Text(conditions[ind][conditionNum[ind]]),
          Expanded(child: Container()),
          Icon(Icons.expand_more_rounded, color: paletteProvider[2],),
          SizedBox(width: 10,),
        ],
      ),
    );
  }

  Row makeOthers(){
    return Row(
      children: [
        Expanded(child: makeCondition(0),),
        Expanded(child: makeCondition(1),),
        Expanded(child: makeCondition(2),),
      ],
    );
  }

  final money = TextEditingController();
  bool isMoneyFocused = false;
  FocusNode focusNode = FocusNode();

  Row makeMoneyAndSearch(){
    return Row(
      children: [
        SizedBox(width: 10,),
        SizedBox(
          width: 200,
          child: MoneyTextField(
            controller: money,
            focusNode: focusNode,
          ),
        ),
        Expanded(child: Container()),
        IconButton(
          icon: Icon(Icons.search_rounded, color: paletteProvider[2],),
          onPressed: () {
            _getSearchQuery();
          },
        ),
      ],
    );
  }

  Future<List<Spec>> _getSearchQuery() async {
    String startDate = DateFormat('yy/MM/dd').format(dateRange[0]);
    String endDate = DateFormat('yy/MM/dd').format(dateRange[1]);
    String type = conditionNum[0] != 0 ? "AND type = ${conditionNum[0]-1}" : "";
    String category = conditionNum[1] != 0 ? "AND category = '${conditions[1][conditionNum[1]]}'" : "";

    String moneyCon = money.text != "" ? "AND money = ${int.parse(money.text.replaceAll(',', ''))}" : "";
    String order = conditionNum[2] == 0 ? "DESC" : "ASC";
    List<Spec> newList = await SpecDBHelper().getQuery(
        '''
        SELECT * FROM Specs
        WHERE dateTime BETWEEN '$startDate' AND '$endDate' $type $category $moneyCon
        ORDER BY dateTime $order;
        ''');
    setState(() {
      _resSpecs = newList;
      isEmptyRes = _resSpecs.isEmpty;
      print("Here ${_resSpecs.length.toString()}");
    });
    return newList;
  }

  ExpansionTile makeDetailedSearch(){
    List<Widget> list = [];

    list.add(makeDatePicker());
    list.add(const SizedBox(height: 10,));
    list.add(makeOthers());
    list.add(const SizedBox(height: 10,));
    list.add(makeMoneyAndSearch());
    list.add(const SizedBox(height: 10,));

    return ExpansionTile(
      initiallyExpanded: true,
      title: const Text("상세 검색"),
      children: list,
    );
  }

  ListView makeRes(){
    return ListView.separated(
      itemCount: _resSpecs.length+2,
      itemBuilder: (context, index) {
        if( index == 0 ) return makeDetailedSearch();
        if( index == _resSpecs.length+1 ){
          if( _resSpecs.isEmpty ){
            return isEmptyRes ? const Center(child: Text("결과가 없어요"),) : const Center(child: Text("검색해 보세요"));
          }
          else{
            return const SizedBox.shrink();
          }
        }
        Spec spec = _resSpecs[index-1];
        return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SpecPage(spec)
                  )
              ).then(onGoBack);
            },child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(children: [Text(spec.dateTime!,
                style: TextStyle(color: Colors.black54),),],),
              SizedBox(height: 8,),
              Row(
                children: [
                  SizedBox(width: 80,
                    child: Text(spec.category!,
                      style: TextStyle(
                          fontSize: 16
                      ),),),
                  Expanded(child: Text(spec.contents!),),
                  SizedBox(width: 100,
                    child: Text(moneyToString(spec.money) + " 원",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: spec.type == 1 ? Colors.blue : Colors.orange,
                          fontSize: 16, fontWeight: FontWeight.bold),),),
                ],
              ),
            ],
          ),
        ));
      },
      separatorBuilder: (context, index) { return const Divider(); },
    );
  }

  @override
  Widget build(BuildContext context) {
    paletteProvider = context.watch<ColorProvider>().palette;
    categoryNames = context.watch<CategoryProvider>().categories;
    conditions[1] = ["모든 카테고리"];
    conditions[1].addAll(categoryNames);
    return Scaffold(
        appBar: AppBar(
          title: Text("검색"),
        ),
        body: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: makeRes()
            ))
    );
  }

}

