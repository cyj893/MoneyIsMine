import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';
import 'DBHelper.dart';

class ChartPage extends StatefulWidget {

  const ChartPage();

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {
  String pageName = "차트";

  @override
  void initState() {
    super.initState();
  }

  void onGoBack(dynamic value) {
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 15,),
              categorySumCon(),
              SizedBox(height: 15,),
              WeekCon(),
              SizedBox(height: 15,),
            ],
          ),
        ),
      ),
    );
  }
}


class categorySumCon extends StatefulWidget {

  const categorySumCon();

  @override
  categorySumConState createState() => categorySumConState();
}

class categorySumConState extends State<categorySumCon> {
  List<String> categoryNames = [];
  List<Pair> categoryMoney = [];
  Map<String, String> categoryMap = {};
  List<String> monthDate = [];
  List<Color> palette = [Color.fromRGBO(225, 39, 0, 0.7), Color.fromRGBO(255, 78, 2, 0.7), Color.fromRGBO(254, 120, 39, 0.7), Color.fromRGBO(255, 162, 69, 0.7), Color.fromRGBO(254, 199, 105, 0.7), Color.fromRGBO(254, 220, 139, 0.7)];
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _getCategoryDB();
  }

  Future<List<Pair>> _getCategoryDB() async {
    if( categoryMoney.length > 0 ) return [];
    DateTime now = DateTime.now();
    monthDate.add(DateFormat('yy/MM/').format(now)+"01");
    monthDate.add(DateFormat('yy/MM/dd').format(DateTime(now.year, now.month + 1, 0)));
    List<Pair> newList = await SpecProvider().getCategorySumQuery(
        '''
        SELECT category, SUM(money) FROM Specs
        WHERE dateTime BETWEEN '${monthDate[0]}' AND '${monthDate[1]}'
        GROUP BY category;
        ''');
    categoryMoney = newList..sort((p1, p2) => p1.b.compareTo(p2.b));
    print("After sort:---------");
    for(int i = 0; i < categoryMoney.length; i++){
      print("${categoryMoney[i].a} ${categoryMoney[i].b}");
    }
    return categoryMoney;
  }


  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> list = [];

    int sum = 0;
    int ind = 0;
    for(int i = 0; i < categoryMoney.length; i++){
      int money = categoryMoney[i].b;
      if( money > 0 ) break;
      sum += money;
      ind++;
    }
    print("Sum: ${sum}");

    for(int i = 0; i < ind && i < 6; i++){
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 70.0 : 60.0;

      String category = categoryMoney[i].a;
      int money = categoryMoney[i].b;
      double per = money/sum*100;

      String categoryIcon = "*";
      if( categoryMap.containsKey(category) ) categoryIcon = categoryMap[category]!;

      list.add(PieChartSectionData(
        color: palette[i],
        title: "",
        value: 15+per,
        radius: radius,
        badgeWidget: Chip(
          avatar: CircleAvatar(
            child: Text(categoryIcon, style: TextStyle(color: palette[i]),),
            backgroundColor: Colors.white,
          ),
          backgroundColor: palette[i],
          label: Text(isTouched ? "${category}: ${(per).toStringAsFixed(2)}%" : category,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ),
        badgePositionPercentageOffset: .98,
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    categoryNames = context.watch<CategoryProvider>().categories;
    categoryMap = context.watch<CategoryProvider>().map;
    return FutureBuilder(
        future: _getCategoryDB(),
        initialData: [],
        builder: (context, snapshot) {
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
                          const Text("카테고리 별 지출", style: TextStyle(
                            fontSize: 20,
                            color: Color(0xff9F2B2B),
                            fontWeight: FontWeight.bold,
                          ),),
                          const SizedBox(height: 2,),
                          Text("${monthDate[0]} ~ ${monthDate[1]}",
                            style: TextStyle(
                                color: palette[0],
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ]
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.3,
                        child: PieChart(
                          PieChartData(
                              pieTouchData: PieTouchData(touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              }),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              sectionsSpace: 5,
                              centerSpaceRadius: 30,
                              sections: showingSections()),
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                  ],
                ),
              ],
            ),
          );
        });
  }

}

class WeekCon extends StatefulWidget {

  const WeekCon();

  @override
  WeekConState createState() => WeekConState();
}

class WeekConState extends State<WeekCon> {
  final Duration animDuration = const Duration(milliseconds: 250);
  List<String> weeks = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
  List<String> weekDate = [];
  List<Map<int, int>> weekSum = [{}, {}];
  List<List<Color>> palette = [
    [Color.fromRGBO(225, 39, 0, 0.7), Color.fromRGBO(255, 78, 2, 0.7), Color.fromRGBO(254, 120, 39, 0.7), Color.fromRGBO(255, 162, 69, 0.7), Color.fromRGBO(254, 199, 105, 0.7), Color.fromRGBO(254, 220, 139, 0.7), Color(0xff9F2B2B)],
    [Color.fromRGBO(0, 39, 225, 0.7), Color.fromRGBO(2, 78, 255, 0.7), Color.fromRGBO(39, 120, 254, 0.7), Color.fromRGBO(69, 162, 255, 0.7), Color.fromRGBO(105, 199, 254, 0.7), Color.fromRGBO(139, 220, 254, 0.7), Color(0xff2B2B9F)],
  ];
  int touchedIndex = -1;
  int nowType = 0;

  @override
  void initState() {
    super.initState();
    _getWeekDB();
  }

  void onGoBack(dynamic value) {
    ;
  }

  Future<List<Map<int, int>>> _getWeekDB() async {
    if( weekSum[0].length > 0 ) return [{}, {}];
    DateTime date = DateTime.now();
    for(int i = 0; i < 7; i++){
      weekDate.add(DateFormat('yy/MM/dd').format(date.subtract(Duration(days: date.weekday - 1 - i))));
    }
    print("${weekDate[0]} ~ ${weekDate[6]}");
    List<List<Pair>> newList = await SpecProvider().getWeekQuery(
        '''
        SELECT SUM(CASE WHEN type=0 THEN money END) as 'expenditure',
               SUM(CASE WHEN type=1 THEN money END) as 'income',
               dateTime
        FROM Specs
        WHERE dateTime BETWEEN '${weekDate[0]}' AND '${weekDate[6]}'
        GROUP BY dateTime;
        ''');

    print("요일:---------");
    print(newList);
    for(int i = 0; i < newList[0].length; i++){
      print("${newList[0][i].a}: ${newList[0][i].b}");
      print("${newList[1][i].a}: ${newList[1][i].b}");
      weekSum[0][weekDate.indexOf(newList[0][i].a)] = newList[0][i].b;
      weekSum[1][weekDate.indexOf(newList[1][i].a)] = newList[1][i].b;
    }
    return weekSum;
  }

  BarChartGroupData makeGroupData(
      int x,
      double y, {
        bool isTouched = false,
        double width = 22,
        List<int> showTooltips = const [],
      }) {
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
            y: 100000,
            colors: [palette[nowType][5]],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  BarChartData mainBarData() {
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
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(7, (i) {
        int m = nowType == 0 ? -1 : 1;
        double val = weekSum[nowType].containsKey(i) ? m*weekSum[nowType][i]!.toDouble() : 0.0;
        return makeGroupData(i, val, isTouched: i == touchedIndex);
      }),
      gridData: FlGridData(show: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getWeekDB(),
        initialData: [],
        builder: (context, snapshot) {
          return MyCard(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10,),
                Row(
                  children: [
                    SizedBox(width: 16,),
                    Expanded(child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("주간 ${nowType == 0 ? "지출" : "수입"}", style: TextStyle(
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
                    SizedBox(width: 16,),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 2.0,
                        child: BarChart(
                          mainBarData(),
                          swapAnimationDuration: animDuration,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        });
  }

}

class TextOutline extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color outlineColor;

  const TextOutline({
    Key? key,
    required this.text,
    required this.textColor,
    required this.outlineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = outlineColor,
          ),),
        Text(text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),)
      ],
    );
  }
}

class MyCard extends StatelessWidget {
  final Widget child;

  const MyCard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

}
