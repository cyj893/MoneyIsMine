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

  List<String> categoryNames = [];
  List<Pair> categoryMoney = [];
  Map<String, String> categoryMap = {};
  List<Color> palette = [Color.fromRGBO(225, 39, 0, 0.7), Color.fromRGBO(255, 78, 2, 0.7), Color.fromRGBO(254, 120, 39, 0.7), Color.fromRGBO(255, 162, 69, 0.7), Color.fromRGBO(254, 199, 105, 0.7), Color.fromRGBO(254, 220, 139, 0.7)];

  Map<int, int> weekSum = {};

  @override
  void initState() {
    super.initState();
    _getCategoryDB();
    _getWeekDB();
  }

  void onGoBack(dynamic value) {
    ;
  }

  Future<List<Pair>> _getCategoryDB() async {
    if( categoryMoney.length > 0 ) return [];
    String month = DateFormat('yy/MM/').format(DateTime.now());
    List<Pair> newList = await SpecProvider().getCategorySumQuery(
        '''
        SELECT category, SUM(money) FROM Specs
        WHERE dateTime BETWEEN '${month+"01"}' AND '${month+"31"}'
        GROUP BY category;
        ''');
    categoryMoney = newList..sort((p1, p2) => p1.b.compareTo(p2.b));
    print("After sort:---------");
    for(int i = 0; i < categoryMoney.length; i++){
      print("${categoryMoney[i].a} ${categoryMoney[i].b}");
    }
    return categoryMoney;
  }

  Future<Map<int, int>> _getWeekDB() async {
    if( categoryMoney.length > 0 ) return {};
    DateTime date = DateTime.now();
    List<String> weekDate = [];
    for(int i = 0; i < 7; i++){
      weekDate.add(DateFormat('yy/MM/dd').format(date.subtract(Duration(days: date.weekday - 1 - i))));
    }
    print("${weekDate[0]} ~ ${weekDate[6]}");
    List<Pair> newList = await SpecProvider().getWeekQuery(
        '''
        SELECT SUM(money), dateTime FROM Specs
        WHERE dateTime BETWEEN '${weekDate[0]}' AND '${weekDate[6]}'
        GROUP BY dateTime;
        ''');
    print("요일:---------");
    for(int i = 0; i < newList.length; i++){
      weekSum[weekDate.indexOf(newList[i].a)] = newList[i].b;
    }
    return weekSum;
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
          label: isTouched ? Text("${category}: ${(per).toStringAsFixed(2)}%",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            )
                           : Text(category,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
        ),
        badgePositionPercentageOffset: .98,
      ));
    }

    return list;
  }

  int touchedIndex = -1;
  Widget makeCategoryChartCon(){
    return MyCard(
      child: Column(
        children: <Widget>[
          SizedBox(height: 10,),
          const Text("카테고리 별 지출", style: TextStyle(
            fontSize: 20,
            color: Color(0xff9F2B2B),
            fontWeight: FontWeight.bold,
          ),),
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
  }





  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 250);
  List<String> weeks = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
  int touchedIndexx = -1;

  BarChartGroupData makeGroupData(
      int x,
      double y, {
        bool isTouched = false,
        Color barColor = Colors.white,
        double width = 22,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.lime[900]!, width: 1)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 100000,
            colors: [barBackgroundColor],
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
          getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff379982), fontWeight: FontWeight.bold, fontSize: 14),
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
        double val = weekSum.containsKey(i) ? -weekSum[i]!.toDouble() : 0.0;
        return makeGroupData(i, val, isTouched: i == touchedIndex);
      }),
      gridData: FlGridData(show: false),
    );
  }

  Widget makeWeekChartCon(){
    return MyCard(
      child: Column(
        children: <Widget>[
          SizedBox(height: 10,),
          Text("이번 주 지출", style: TextStyle(
            fontSize: 20,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),),
          Row(
            children: [
              SizedBox(width: 20,),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      const Text(
                        'Mingguan',
                        style: TextStyle(
                            color: Color(0xff0f4a3c),
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      const Text(
                        'Grafik konsumsi kalori',
                        style: TextStyle(
                            color: Color(0xff379982),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 38,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: BarChart(
                            mainBarData(),
                            swapAnimationDuration: animDuration,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 20,),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    categoryNames = context.watch<CategoryProvider>().categories;
    categoryMap = context.watch<CategoryProvider>().map;
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 15,),
              FutureBuilder(
                  future: _getCategoryDB(),
                  initialData: [],
                  builder: (context, snapshot) {
                    return makeCategoryChartCon();
                  }),
              SizedBox(height: 15,),
              FutureBuilder(
                  future: _getWeekDB(),
                  initialData: [],
                  builder: (context, snapshot) {
                    return makeWeekChartCon();
                  }),
              SizedBox(height: 15,),
            ],
          ),
        ),
      ),
    );
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