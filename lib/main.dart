import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import './InputSpecsPage.dart';
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
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState  extends State<RandomWords> {
  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));
  List<Spec> daySpecs = [];

  @override void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
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
  Row makeDaySpec(Spec spec){
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
            child: Text("\₩ ${_formatNumber(spec.money.toString().replaceAll(',', ''))}",
              textAlign: TextAlign.end,
              style: TextStyle(color: spec.type == 1 ? Colors.blue : Colors.orange),)
        ),
      ],
    );
  }
  List<Widget> makeDaySpecs(){
    List<Widget> list = [];
    for(int i = 0; i < daySpecs.length; i++){
      list.add(InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InputSpecsPage(daySpecs[i])
              )
          ).then(onGoBack);
        },
        onLongPress: () {
          showDeleteDialog(daySpecs[i]);
        },
        child: makeDaySpec(daySpecs[i]),
      ));
      list.add(SizedBox(height: 10,));
    }
    return list;
  }

  ExpansionTile makeDayExpansionTile(){
    return ExpansionTile(
      title: Chip(
        backgroundColor: Colors.blue[100],
        label: Text("${DateFormat('yy/MM/dd').format(DateTime.now())} (${DateFormat.E('ko_KR').format(DateTime.now())})",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
      ),
      initiallyExpanded: false,
      children: makeDaySpecs(),
    );
  }
  Row makeDayHead(){
    return Row(
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
    );
  }
  Row makeDaySums(int p, int m, int sum){
    return Row(
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
    );
  }

  Container makeDayCon(List<Spec>? data) {
    if( data!.isEmpty ) data = [];
    daySpecs = data;
    print("Here ${data.length.toString()}");
    int p = 0, m = 0, sum = 0;
    for(int i = 0; i < data.length; i++){
      int pm = data[i].type == 0 ? -1 : 1;
      pm == 1 ? p += data[i].money : m -= data[i].money;
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
            makeDayExpansionTile(),
            makeDayHead(),
            Divider(),
            makeDaySums(p, m, sum),
          ],
        )
    );
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      _getDayQuery();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'main',
        home: Scaffold(
          appBar: AppBar(
            title: Text("main"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InputSpecsPage(Spec(type: -1, money: 0))
                  )
              ).then(onGoBack);
            },
            child: Icon(Icons.add),
          ),
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

