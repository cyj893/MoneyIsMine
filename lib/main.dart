import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'DaySpecCon.dart';
import 'BottomNaviBar.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'main',
      home: MyHomePage(),
    );
  }
}

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
    return MaterialApp(
        title: 'main',
        home: Scaffold(
          appBar: AppBar(
            title: Text("main"),
          ),
          bottomNavigationBar: buildBottomNaviBar(context, onGoBack),
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                DaySpecCon(DateFormat('yy/MM/dd').format(DateTime.now())),
              ],
            ),
          )
          ),
    );
  }

}

