import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import '../db_helper/DBHelper.dart';
import 'CalendarPage.dart';
import 'ChartPage.dart';
import 'InputSpecsPage.dart';
import 'HomePage.dart';
import '../db_helper/ColorProvider.dart';


void goHome(BuildContext context, onGoBack){
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MyHomePage()
      )
  ).then(onGoBack);
}

void goInputSpecsPage(BuildContext context, onGoBack){
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => InputSpecsPage(Spec(type: -1, money: 0))
      )
  ).then(onGoBack);
}

void goCalendarPage(BuildContext context, onGoBack){
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CalendarPage()
      )
  ).then(onGoBack);
}

void goChartPage(BuildContext context, onGoBack){
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChartPage()
      )
  ).then(onGoBack);
}

BottomNavigationBar buildBottomNaviBar(BuildContext context, onGoBack){
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    backgroundColor: context.watch<ColorProvider>().palette[1],
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white.withOpacity(.60),
    onTap: (int i) {
      if( i == 0 ) ;
      else if( i == 1 ) goInputSpecsPage(context, onGoBack);
      else if( i == 2 ) goInputSpecsPage(context, onGoBack);
      else if( i == 3 ) goCalendarPage(context, onGoBack);
      else if( i == 4 ) goChartPage(context, onGoBack);
    },
    items: const [
      BottomNavigationBarItem(
          label: "홈",
          icon: Icon(Icons.home_filled)),
      BottomNavigationBarItem(
          label: "내역 추가",
          icon: Icon(Icons.add_box_outlined)),
      BottomNavigationBarItem(
          label: "검색",
          icon: Icon(Icons.manage_search_rounded)),
      BottomNavigationBarItem(
          label: "달력",
          icon: Icon(Icons.calendar_today_rounded)),
      BottomNavigationBarItem(
          label: "차트",
          icon: Icon(Icons.bar_chart_rounded))
    ],
  );
}
