import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

import 'package:money_is_mine/pages/widgets/MoneyTextField.dart';
import '../db_helper/ColorProvider.dart';
import '../db_helper/DBHelper.dart';

class MonthSummaryCon extends StatefulWidget {

  const MonthSummaryCon();

  @override
  MonthSummaryConState createState() => MonthSummaryConState();
}

class MonthSummaryConState extends State<MonthSummaryCon> {
  List<Color> paletteProvider = [];
  List<int> monthSummary = [0, 0, 0];

  @override
  void initState() {
    super.initState();
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      print("onGoBack");
    });
  }

  Future<List<int>> _getSummaryQuery() async {
    String month = DateFormat('yy/MM/').format(DateTime.now());
    List<int> newlist = await SpecDBHelper().getSummaryQuery(
        '''
        SELECT SUM(CASE WHEN type=0 THEN money END) as 'expenditure',
               SUM(CASE WHEN type=1 THEN money END) as 'income'
        FROM Specs
        WHERE dateTime BETWEEN '${month+"01"}' AND '${month+"31"}' ;
        ''');
    print("---------------${month+"01"} ~ ${month+"31"}");
    newlist.add(newlist[0] + newlist[1]);
    print(newlist);
    monthSummary = newlist;
    return newlist;
  }

  List<Widget> makeMonthSummary() {
    int p = monthSummary[1], m = monthSummary[0], sum = monthSummary[2];
    List<Widget> list = [];
    list.add(Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
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
        Expanded(
            child: Text("${moneyToString(p)} 원",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.blue),)),
        Expanded(child: Text(
          "${moneyToString(-m)} 원",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.orange),)),
        Expanded(child: Text(
          "${moneyToString(sum)} 원",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16, color: sum >= 0 ? Colors.blue : Colors.orange),)),
      ],
    ));
    return list;
  }

  Container makeMonthCon() {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        decoration: BoxDecoration(
          border: Border.all(color: paletteProvider[0], width: 4),
          borderRadius: BorderRadius.all(
              Radius.circular(20.0)
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              backgroundColor: paletteProvider[1],
              label: Text(
                DateFormat('yy/MM').format(DateTime.now()),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
            ),
            Column(
                children: makeMonthSummary()
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    paletteProvider = context.watch<ColorProvider>().palette;
    return FutureBuilder<List<int>>(
      future: _getSummaryQuery(),
      initialData: [],
      builder: (context, snapshot) {
        return makeMonthCon();
      },);

  }
}
