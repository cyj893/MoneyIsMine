import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

import 'package:money_is_mine/pages/widgets/MyCard.dart';
import 'package:money_is_mine/db_helper/DBHelper.dart';

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
    List<Pair> newList = await SpecDBHelper().getCategorySumQuery(
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
