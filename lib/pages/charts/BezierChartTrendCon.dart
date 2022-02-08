import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:provider/src/provider.dart';

import 'package:money_is_mine/pages/widgets/MyCard.dart';
import 'package:money_is_mine/db_helper/DBHelper.dart';
import 'package:money_is_mine/db_helper/ColorProvider.dart';

class TrendCon extends StatefulWidget {

  const TrendCon();

  @override
  TrendConState createState() => TrendConState();
}

class TrendConState extends State<TrendCon> {
  List<Color> paletteProvider = [];
  List<List<Color>> palette = [
    [Color.fromRGBO(225, 39, 0, 0.7), Color.fromRGBO(255, 78, 2, 0.7), Color.fromRGBO(254, 120, 39, 0.7), Color.fromRGBO(255, 162, 69, 0.7), Color.fromRGBO(254, 199, 105, 0.7), Color.fromRGBO(254, 220, 139, 0.7), Color(0xff9F2B2B)],
    [Color.fromRGBO(0, 39, 225, 0.7), Color.fromRGBO(2, 78, 255, 0.7), Color.fromRGBO(39, 120, 254, 0.7), Color.fromRGBO(69, 162, 255, 0.7), Color.fromRGBO(105, 199, 254, 0.7), Color.fromRGBO(139, 220, 254, 0.7), Color(0xff2B2B9F)],
  ];

  @override
  void initState() {
    super.initState();
    _getDateDB();
  }

  Future<List<Map<String, int>>> _getDateDB() async {
    List<Map<String, int>> newMap = await DaySpecDBHelper().getDateQuery(
        '''
        SELECT dateTime, expenditure, income FROM DaySpecs;
        ''');
    return newMap;
  }

  int maxVal = 0;
  BezierLine makeLine(int type, DateTime fromDate){
    List<DataPoint<DateTime>> list = [];
    DateTime t = fromDate;
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);
    while( t != now ){
      String s = DateFormat('yy/MM/dd').format(t);
      if( DateSpecsMap[type].containsKey(s) ){
        int m = type == 0 ? -1 : 1;
        maxVal = maxVal > m*DateSpecsMap[type][s]! ? maxVal : m*DateSpecsMap[type][s]!;
        list.add(DataPoint<DateTime>(value: m * DateSpecsMap[type][s]!.toDouble(), xAxis: t));
      }
      t = t.add(const Duration(days: 1));
    }
    String s = DateFormat('yy/MM/dd').format(t);
    if( DateSpecsMap[type].containsKey(s) ){
      int m = type == 0 ? -1 : 1;
      list.add(DataPoint<DateTime>(value: m * DateSpecsMap[type][s]!.toDouble(), xAxis: t));
    }
    return BezierLine(
      lineColor: palette[type][2],
      lineStrokeWidth: 2.0,
      label: type == 0 ? "지출" : "수입",
      data: list,
    );
  }

  BezierLine makeSumLine(DateTime fromDate){
    List<DataPoint<DateTime>> list = [];
    DateTime t = fromDate;
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);
    int sum = 0;
    while( t != now ){
      String s = DateFormat('yy/MM/dd').format(t);
      if( DateSpecsMap[2].containsKey(s) ){
        sum += DateSpecsMap[2][s]!;
      }
      list.add(DataPoint<DateTime>(value: sum.toDouble(), xAxis: t));
      t = t.add(const Duration(days: 1));
    }
    String s = DateFormat('yy/MM/dd').format(t);
    if( DateSpecsMap[2].containsKey(s) ){
      sum += DateSpecsMap[2][s]!;
    }
    list.add(DataPoint<DateTime>(value: sum.toDouble(), xAxis: t));
    return BezierLine(
      lineColor: Color(0x7fafdbbb),
      lineStrokeWidth: 2.0,
      label: "합계",
      data: list,
    );
  }

  List<Map<String, int>> DateSpecsMap = [{}, {}, {}];

  Widget sample2(BuildContext context, data) {
    DateSpecsMap = data;
    DateTime toDate = DateTime.now();
    DateTime fromDate = DateTime(toDate.year-1, toDate.month, toDate.day);
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: BezierChart(
          bezierChartScale: BezierChartScale.WEEKLY,
          fromDate: fromDate,
          toDate: toDate,
          selectedDate: toDate,
          series: [
            makeSumLine(fromDate),
            makeLine(0, fromDate),
            makeLine(1, fromDate),
          ],
          config: BezierChartConfig(
            footerHeight: 50,
            xAxisTextStyle: TextStyle(color: Colors.black12),
            displayYAxis: true,
            yAxisTextStyle: TextStyle(color: Colors.black12),
            stepsYAxis: 20000,
            pinchZoom: true,
            verticalIndicatorStrokeWidth: 2.0,
            verticalIndicatorColor: Colors.black12,
            showVerticalIndicator: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    paletteProvider = context.watch<ColorProvider>().palette;
    return MyCard(
      child: Column(
        children: <Widget>[
          SizedBox(height: 10,),
          Row(
            children: [
              SizedBox(width: 16,),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("최근 경향", style: TextStyle(
                      fontSize: 20,
                      color: paletteProvider[4],
                      fontWeight: FontWeight.bold,
                    ),),
                    const SizedBox(height: 2,),
                    Text("sadsdasda",
                      style: TextStyle(
                          color: paletteProvider[3],
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ]
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<List<Map<String, int>>>(
                    future: _getDateDB(),
                    initialData: [{}, {}, {}],
                    builder: (context, snapshot){
                      //return SizedBox.shrink();
                      return sample2(context, snapshot.data);
                    }
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

