import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'day_spec_con.dart';
import 'bottom_navi_bar.dart';
import 'month_summary_con.dart';
import 'settings_page.dart';

class MyHomePage extends StatefulWidget {

  const MyHomePage();

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState  extends State<MyHomePage> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      print("onGoBack");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("홈"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsPage()
                      )
                  ).then(onGoBack);
                },
                icon: Icon(Icons.settings_rounded, color: Colors.white,))
          ],
        ),
        bottomNavigationBar: buildBottomNaviBar(context, onGoBack),
        body: Padding(
            padding: EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DaySpecCon(DateFormat('yy/MM/dd').format(DateTime.now())),
                  Divider(),
                  MonthSummaryCon(),
                ],
              ),
            )
        )
    );
  }

}

