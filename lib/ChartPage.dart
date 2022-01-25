import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';
import "dart:collection";
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

  @override
  void initState() {
    super.initState();
    _getCategoryDB();
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

    int hop = ind < 5 ? 200 : 100;

    for(int i = 0; i < ind && i < 9; i++){
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 70.0 : 60.0;

      String category = categoryMoney[i].a;
      int money = categoryMoney[i].b;
      double per = money/sum*100;

      String categoryIcon = "*";
      if( categoryMap.containsKey(category) ) categoryIcon = categoryMap[category]!;

      list.add(PieChartSectionData(
        color: Colors.orange[(ind-i) * hop],
        title: "",
        value: per,
        radius: radius,
        badgeWidget: Chip(
          avatar: CircleAvatar(
            child: Text(categoryIcon, style: TextStyle(color: Colors.orange),),
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.orange[(ind-i) * hop]!,
          label: isTouched ? TextOutline(
                              text: "${category}: ${(per).toStringAsFixed(2)}%",
                              textColor: Colors.white,
                              outlineColor: Colors.orange,
                            )
                           : TextOutline(
                              text: category,
                              textColor: Colors.white,
                              outlineColor: Colors.orange,
                            ),
        ),
        badgePositionPercentageOffset: .98,
      ));
    }

    return list;
  }

  int touchedIndex = -1;
  Widget makeCategoryChartCon(){
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            SizedBox(height: 10,),
            Text("카테고리 별 지출", style: TextStyle(
                fontSize: 20,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
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
            SizedBox(height: 10,),
          ],
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FutureBuilder(
                  future: _getCategoryDB(),
                  initialData: [],
                  builder: (context, snapshot) {
                    return makeCategoryChartCon();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
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