import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bezier_chart/bezier_chart.dart';
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
              AvgCon(),
              const SizedBox(height: 15,),
              const SizedBox(height: 200,),
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
    List<List<Pair>> newList = await DaySpecProvider().getWeekQuery(
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





class AvgCon extends StatefulWidget {

  const AvgCon();

  @override
  AvgConState createState() => AvgConState();
}

class AvgConState extends State<AvgCon> {
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
    List<Map<String, int>> newMap = await DaySpecProvider().getDateQuery(
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
        height: MediaQuery.of(context).size.width * 0.7,
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
                    const Text("최근 경향", style: TextStyle(
                      fontSize: 20,
                      color: Color(0xff205930),
                      fontWeight: FontWeight.bold,
                    ),),
                    const SizedBox(height: 2,),
                    Text("sadsdasda",
                      style: TextStyle(
                          color: Color(0xff419157),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ]
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 8,),
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
              SizedBox(width: 8,),
            ],
          ),
        ],
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
