import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'InputSpecsPage.dart';
import 'BottomNaviBar.dart';
import 'DBHelper.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'main',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage();

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState  extends State<MyHomePage> {
  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));
  List<Spec> _daySpecs = [];

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      _getDayQuery();
    });
  }

  Future<List<Spec>> _getDayQuery() async {
    String yy = DateFormat('yy').format(DateTime.now());
    String MM = DateFormat('MM').format(DateTime.now());
    String dd = DateFormat('dd').format(DateTime.now());
    List<Spec> newList = await SpecProvider().getQuery(
        '''
        SELECT * FROM Specs
        WHERE dateTime = '$yy\/$MM\/$dd'
        ORDER BY id;
        ''');
    return newList;
  }

  void showDeleteDialog(Spec spec){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("삭제하시겠습니까?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("no")),
              TextButton(
                  onPressed: () {
                    SpecProvider().delete(spec);
                    Navigator.of(context).pop();
                    onGoBack(null);
                  },
                  child: Text("yes"))
            ],
          );
        });
  }
  Row makeDayExpTileChild(Spec spec){
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text("${spec.category}"),
        ),
        Expanded(
          child: Text("${spec.contents}"),
        ),
        SizedBox(
            width: 100,
            child: Text("\₩ ${_formatNumber((spec.money < 0 ? -spec.money : spec.money).toString().replaceAll(',', ''))}",
              textAlign: TextAlign.end,
              style: TextStyle(color: spec.type == 1 ? Colors.blue : Colors.orange),)
        ),
      ],
    );
  }
  List<Widget> makeDayExpTileChildren(){
    List<Widget> list = [];
    for(int i = 0; i < _daySpecs.length; i++){
      list.add(InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InputSpecsPage(_daySpecs[i])
              )
          ).then(onGoBack);
        },
        onLongPress: () {
          showDeleteDialog(_daySpecs[i]);
        },
        child: makeDayExpTileChild(_daySpecs[i]),
      ));
      list.add(SizedBox(height: 10,));
    }
    return list;
  }
  ExpansionTile makeDayExpTile(){
    return ExpansionTile(
      title: Chip(
        backgroundColor: Colors.blue[100],
        label: Text("${DateFormat('yy/MM/dd').format(DateTime.now())} (${DateFormat.E('ko_KR').format(DateTime.now())})",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
      ),
      initiallyExpanded: false,
      children: makeDayExpTileChildren(),
    );
  }
  List<Widget> makeDaySummary(int p, int m, int sum){
    List<Widget> list = [];
    list.add(Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Text("수입", textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
        Expanded(child: Text("지출", textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
        Expanded(child: Text("합계", textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
      ],
    ));
    list.add(Divider());
    list.add(Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Text("${_formatNumber(p.toString().replaceAll(',', ''))} 원",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.blue),)),
        Expanded(child: Text("${_formatNumber((-m).toString().replaceAll(',', ''))} 원",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.orange),)),
        Expanded(child: Text("${_formatNumber(sum.toString().replaceAll(',', ''))} 원",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: sum >= 0 ? Colors.blue : Colors.orange),)),
      ],
    ));
    return list;
  }

  Container makeDayCon(List<Spec>? data) {
    if( data!.isEmpty ) data = [];
    _daySpecs = data;
    print("Here ${data.length.toString()}");
    int p = 0, m = 0, sum = 0;
    for(int i = 0; i < data.length; i++){
      data[i].type == 1 ? p += data[i].money : m += data[i].money;
    }
    sum = p + m;
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        decoration: BoxDecoration(
          border: Border.all(color: (Colors.blue[100])!, width: 4),
          borderRadius: BorderRadius.all(
              Radius.circular(20.0)
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            makeDayExpTile(),
            Column(
              children: makeDaySummary(p, m, sum)
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'main',
        home: Scaffold(
          appBar: AppBar(
            title: Text("main"),
          ),
          bottomNavigationBar: BottomNaviBarProvider().getBottomNaviBar(context, onGoBack),
          body: FutureBuilder<List<Spec>>(
            future: _getDayQuery(),
            initialData: <Spec>[],
            builder: (context, snapshot) {
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: makeDayCon(snapshot.data),
              );
            },
          )
          ),
    );
  }

}

