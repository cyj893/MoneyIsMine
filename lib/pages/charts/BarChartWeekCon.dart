import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:money_is_mine/pages/widgets/MyCard.dart';
import 'package:money_is_mine/db_helper/DBHelper.dart';

class WeekCon extends StatefulWidget {
  final DateTime _dateTime;

  const WeekCon(this._dateTime);

  @override
  WeekConState createState() => WeekConState();
}

//  with AutomaticKeepAliveClientMixin
class WeekConState extends State<WeekCon> with AutomaticKeepAliveClientMixin {
  final Duration animDuration = const Duration(milliseconds: 250);
  List<String> weeks = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
  List<String> weekDate = [];
  List<Map<int, int>> weekSum = [{}, {}];
  List<int> sum = [0, 0];
  List<List<Color>> palette = [
    [Color.fromRGBO(225, 39, 0, 0.7), Color.fromRGBO(255, 78, 2, 0.7), Color.fromRGBO(254, 120, 39, 0.7), Color.fromRGBO(255, 162, 69, 0.7), Color.fromRGBO(254, 199, 105, 0.7), Color.fromRGBO(254, 220, 139, 0.7), Color(0xff9F2B2B)],
    [Color.fromRGBO(0, 39, 225, 0.7), Color.fromRGBO(2, 78, 255, 0.7), Color.fromRGBO(39, 120, 254, 0.7), Color.fromRGBO(69, 162, 255, 0.7), Color.fromRGBO(105, 199, 254, 0.7), Color.fromRGBO(139, 220, 254, 0.7), Color(0xff2B2B9F)],
  ];
  int touchedIndex = -1;
  int nowType = 0;

  List<int> maxVal = [0, 0];
  List<double> sliderNow = [2, 2];
  List<double> sliderVal = [10000, 50000, 100000, 300000, 500000, 1000000];
  List<String> sliderValString = ["1만", "5만", "10만", "30만", "50만", "100만"];

  @override
  void initState() {
    super.initState();
    _getWeekDB();
  }

  @override
  bool get wantKeepAlive => true;

  Future<List<Map<int, int>>> _getWeekDB() async {
    if( weekSum[0].length > 0 ) return [{}, {}];
    DateTime date = widget._dateTime;
    for(int i = 0; i < 7; i++){
      weekDate.add(DateFormat('yy/MM/dd').format(date.subtract(Duration(days: date.weekday - 1 - i))));
    }
    print("${weekDate[0]} ~ ${weekDate[6]}");
    List<List<Pair>> newList = await DaySpecDBHelper().getWeekQuery(
        '''
        SELECT expenditure,
               income,
               dateTime
        FROM DaySpecs
        WHERE dateTime BETWEEN '${weekDate[0]}' AND '${weekDate[6]}'
        GROUP BY dateTime;
        ''');
    sum[0] = 0;
    sum[1] = 0;
    for(int i = 0; i < newList[0].length; i++){
      int exp = newList[0][i].b;
      int inc = newList[1][i].b;
      weekSum[0][weekDate.indexOf(newList[0][i].a)] = exp;
      weekSum[1][weekDate.indexOf(newList[1][i].a)] = inc;
      maxVal[0] = maxVal[0] > -exp ? maxVal[0] : -exp;
      maxVal[1] = maxVal[1] > inc ? maxVal[1] : inc;
      sum[0] -= exp;
      sum[1] += inc;
    }
    for(int i = 0; i < sliderVal.length; i++){
      if( maxVal[0] <= sliderVal[i] ){
        maxVal[0] = i;
        sliderNow[0] = i.toDouble();
        break;
      }
    }
    for(int i = 0; i < sliderVal.length; i++){
      if( maxVal[1] <= sliderVal[i] ){
        maxVal[1] = i;
        sliderNow[1] = i.toDouble();
        break;
      }
    }
    if( maxVal[0] > 1000000 ) sliderNow[0] = 5;
    if( maxVal[1] > 1000000 ) sliderNow[1] = 5;
    return weekSum;
  }

  BarChartGroupData makeGroupData(int x, double y,
      {bool isTouched = false, double width = 22, List<int> showTooltips = const [],}){
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y,
          colors: isTouched ? [palette[nowType][0]] : [palette[nowType][2]],
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.lime[900]!, width: 1)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: sliderVal[sliderNow[nowType].toInt()],
            colors: [palette[nowType][5]],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  BarChartData mainBarData() {
    double verMax = sliderVal[sliderNow[nowType].toInt()];
    verMax = verMax > maxVal[nowType] ? verMax : maxVal[nowType].toDouble();
    double horizontalInterval = verMax/5 > 10000 ? verMax/5 : 10000;
    if( sliderNow[nowType].toInt() == 0 ) horizontalInterval = 2000;
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                weeks[group.x.toInt()] + '\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: rod.y.toInt().toString() + "원",
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => TextStyle(
              color: palette[nowType][1], fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            return weeks[value.toInt()][0];
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          reservedSize: 35,
          getTextStyles: (context, value) => TextStyle(
              color: palette[nowType][1], fontWeight: FontWeight.bold, fontSize: 10),
          margin: 0,
          getTitles: (double value) {
            int val = value.toInt();
            if( val < 1000 ) return "$val";
            if( 1000 <= val && val < 10000 ) return "${val~/1000}천";
            return "${val~/10000}만";
          },
        ),
      ),
      borderData: FlBorderData(show: false,),
      barGroups: List.generate(7, (i) {
        int m = nowType == 0 ? -1 : 1;
        double val = weekSum[nowType].containsKey(i) ? m*weekSum[nowType][i]!.toDouble() : 0.0;
        return makeGroupData(i, val, isTouched: i == touchedIndex);
      }),
      gridData: FlGridData(show: true,
        drawVerticalLine: false,
        horizontalInterval: horizontalInterval,
        getDrawingHorizontalLine: (double val) {
          return FlLine(
            color: palette[nowType][5],
            dashArray: [5, 3],
          );
        },
      ),
    );
  }

  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: _getWeekDB(),
        initialData: [],
        builder: (context, snapshot) {
          return MyCard(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10,),
                Row(
                  children: [
                    SizedBox(width: 16,),
                    Expanded(child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("주간 ${nowType == 0 ? "지출" : "수입"}: ${_formatNumber(sum[nowType].toString())}원", style: TextStyle(
                            fontSize: 20,
                            color: nowType == 0 ? palette[0][6] : palette[1][6],
                            fontWeight: FontWeight.bold,
                          ),),
                          const SizedBox(height: 2,),
                          Text("${weekDate[0]} ~ ${weekDate[6]}",
                            style: TextStyle(
                                color: palette[nowType][0],
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ]
                    ),),
                    InkWell(
                      onTap: () {
                        setState(() {
                          nowType = 1 - nowType;
                        });
                      },
                      child: Chip(
                        backgroundColor: palette[nowType][2],
                        label: Text(nowType == 0 ? "지출" : "수입",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16,),
                  ],
                ),
                const SizedBox( height: 20,),
                Row(
                  children: [
                    const SizedBox( height: 20,),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 2.0,
                        child: BarChart(
                          mainBarData(),
                          swapAnimationDuration: animDuration,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 8,),
                    SizedBox(
                      width: 70,
                      child: Chip(
                        backgroundColor: palette[nowType][2],
                        label: Text(sliderValString[sliderNow[nowType].toInt()],
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: palette[nowType][2],
                        inactiveTrackColor: palette[nowType][4],
                        thumbColor: palette[nowType][2],
                        activeTickMarkColor: palette[nowType][2],
                        valueIndicatorColor: palette[nowType][2],
                        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      ),
                      child: Slider(
                        value: sliderNow[nowType],
                        min: 0,
                        max: 5,
                        divisions: 5,
                        label: sliderValString[sliderNow[nowType].toInt()],
                        onChanged: (newValue) {
                          print(maxVal[nowType]);
                          if( newValue < maxVal[nowType] ) return;
                          setState(() {
                            sliderNow[nowType] = newValue;
                          });
                        },
                      ),
                    ),)
                  ],
                ),
              ],
            ),
          );
        });
  }

}
