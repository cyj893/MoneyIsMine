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
  List<Widget> _weekPages = [Center(child: WeekCon(DateTime.now()),), Center(child: WeekCon(DateTime.now().subtract(Duration(days: 7))),),];
  var _controller = PageController(initialPage: 0);
  int _prevCount = 1;
  bool isFirstPage = true;
  Duration swipeDuration = const Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
  }

  void onGoBack(dynamic value) {
    ;
  }

  Widget makeWeekConPageView(){
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width*0.5 + 110 + 40,
          child: PageView.builder(
            reverse: true,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (pageId) {
              if( pageId == 0 ){
                isFirstPage = true;
                setState(() {});
                return ;
              }
              if( pageId == 1 && isFirstPage && _weekPages.length > 2 ){
                isFirstPage = false;
                setState(() {});
                return ;
              }
              if( pageId == _weekPages.length - 1 ){
                isFirstPage = false;
                print("Add last");
                _prevCount = _prevCount + 1;
                _weekPages.add(Center(child: WeekCon(DateTime.now().subtract(Duration(days: 7*_prevCount))),));
                setState(() {});
              }
            },
            controller: _controller,
            itemCount: _weekPages.length,
            itemBuilder: (context, i) { return _weekPages[i]; },
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _controller.nextPage(duration: swipeDuration,
                        curve: Curves.easeIn);
                  },
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  color: const Color(0x7f7f7f7f),),
                Expanded(child: Container()),
                IconButton(
                  onPressed: () {
                    if( isFirstPage ) return;
                    _controller.previousPage(duration: swipeDuration,
                        curve: Curves.easeIn);
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  color: isFirstPage ? const Color(0x007f7f7f) : const Color(0x7f7f7f7f),),
              ],
            ),
          ),),
      ],
    );
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
              const SizedBox(height: 15,),
              CategorySumCon(),
              const SizedBox(height: 15,),
              makeWeekConPageView(),
              const SizedBox(height: 15,),
            ],
          ),
        ),
      ),
    );
  }
}


class CategorySumCon extends StatefulWidget {

  const CategorySumCon();

  @override
  CategorySumConState createState() => CategorySumConState();
}

class CategorySumConState extends State<CategorySumCon> {
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
        WHERE type = 0 AND dateTime BETWEEN '${monthDate[0]}' AND '${monthDate[1]}'
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

  Widget makePieChart(){
    if( categoryMoney.length == 0 || categoryMoney[0].b > 0 ){
      return Center(
        child: Text("지출 데이터가 없습니다",
            style: TextStyle(
              color: palette[0],
              fontWeight: FontWeight.bold,
            ),),
      );
    }
    return PieChart(
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
    );
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
                        child: makePieChart(),
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
    _getAvgWeekDB();
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
    List<List<Pair>> newList = await SpecProvider().getWeekQuery(
        '''
        SELECT SUM(CASE WHEN type=0 THEN money END) as 'expenditure',
               SUM(CASE WHEN type=1 THEN money END) as 'income',
               dateTime
        FROM Specs
        WHERE dateTime BETWEEN '${weekDate[0]}' AND '${weekDate[6]}'
        GROUP BY dateTime;
        ''');
    for(int i = 0; i < newList[0].length; i++){
      weekSum[0][weekDate.indexOf(newList[0][i].a)] = newList[0][i].b;
      weekSum[1][weekDate.indexOf(newList[1][i].a)] = newList[1][i].b;
      maxVal[0] = maxVal[0] > -newList[0][i].b ? maxVal[0] : -newList[0][i].b;
      maxVal[1] = maxVal[1] > newList[1][i].b ? maxVal[1] : newList[1][i].b;
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
    return weekSum;
  }

  List<List<int>> avgWeek = [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]];
  Future<List<List<int>>> _getAvgWeekDB() async {
    List<List<Pair>> newList = await DaySpecProvider().getAvgQuery(
        '''
        SELECT AVG(expenditure) as 'expenditure',
               AVG(income) as 'income',
               day
        FROM DaySpecs
        GROUP BY day;
        ''');
    print("AVG-----");
    for(int i = 0; i < newList[0].length; i++){
      print("AVG$i----- ${newList[0][i].a-1} ${newList[0][i].b}");
      avgWeek[0][newList[0][i].a-1] = -newList[0][i].b.toInt();
      avgWeek[1][newList[1][i].a-1] = newList[1][i].b.toInt();
    }
    for(int i = 0; i < 7; i++){
      print("${avgWeek[0][i]}, ${avgWeek[1][i]}");
    }
    return avgWeek;
  }

  BarChartGroupData makeGroupData(int x, double y,
          {bool isTouched = false, double width = 22, List<int> showTooltips = const [],}){
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y,
          colors: isTouched ? [palette[nowType][0]] : [palette[nowType][2].withOpacity(0.5)],
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.lime[900]!, width: 1)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: sliderVal[sliderNow[nowType].toInt()],
            colors: [palette[nowType][5].withOpacity(0.7)],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  BarChartData mainBarData() {
    double horizontalInterval = sliderVal[sliderNow[nowType].toInt()]/5 > 10000 ? sliderVal[sliderNow[nowType].toInt()]/5 : 10000;
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
            color: palette[nowType][5].withOpacity(0.5),
            dashArray: [5, 3],
          );
        },
      ),
    );
  }

  BarChartGroupData makeAvgGroupData(int x, double y, { bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: avgWeek[nowType][x].toDouble(),
          colors: [palette[nowType][3]],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: sliderVal[sliderNow[nowType].toInt()],
            colors: [const Color(0x00000000)],
          ),
        ),
      ],
    );
  }

  BarChartData avgBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchCallback: (FlTouchEvent event, barTouchResponse) {},
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
              color: Color(0x00000000)),
          margin: 16,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
              color: Color(0x00000000), fontSize: 10),
          margin: 0,
        ),
      ),
      borderData: FlBorderData(show: false,),
      barGroups: List.generate(7, (i) {
        return makeAvgGroupData(i, 0, isTouched: false);
      }),
      gridData: FlGridData(show: false,),
    );
  }

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
                        child: Stack(
                          children: [
                            BarChart(
                              avgBarData(),
                            ),
                            BarChart(
                              mainBarData(),
                              swapAnimationDuration: animDuration,
                            ),
                          ],
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
    return Column(
      children: [
        Container(
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
        ),
        SizedBox(height: 10,),
      ],
    );
  }

}
