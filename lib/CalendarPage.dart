import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'db_helper/DBHelper.dart';
import 'DaySpecCon.dart';

class CalendarPage extends StatefulWidget {

  const CalendarPage();

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));

  int nowIndex = 0;
  List<String> nowType = ["지출", "수입", "합계"];

  var _selectedDay;
  var _focusedDay = DateTime.now();
  var _calendarFormat = CalendarFormat.month;
  List<Map<String, int>> DateSpecsMap = [{}, {}, {}];

  void onGoBack(dynamic value) {

  }

  Future<List<Map<String, int>>> _getSumQuery() async {
    List<Map<String, int>> newMap = await DaySpecDBHelper().getDateQuery(
        '''
        SELECT dateTime, expenditure, income FROM DaySpecs;
        ''');
    return newMap;
  }

  int palette(int k){
    k = k < 0 ? -k : k;
    if( k < 10000 ) return 50;
    if( k < 50000 ) return 100;
    if( k < 100000 ) return 200;
    if( k < 500000 ) return 300;
    if( k < 1000000 ) return 400;
    return 500;
  }

  Widget CalendarCellBuilder(BuildContext context, DateTime dateTime, _, int type){
    String date = DateFormat('yy/MM/dd').format(dateTime);
    int money = DateSpecsMap[nowIndex].containsKey(date) ? DateSpecsMap[nowIndex][date]! : 0;

    var color = Colors.grey[200];
    var nowIndexColor;
    if( nowIndex == 0 ) nowIndexColor = Colors.orange;
    else if( nowIndex == 1 ) nowIndexColor = Colors.blue;
    else nowIndexColor = (money < 0 ? Colors.orange : Colors.blue);
    if( money != 0 ) color = nowIndexColor[palette(money)];

    var borderColor;
    if( type == 0 ) borderColor = Colors.white.withOpacity(0.0);
    else if( type == 1 ){
      if( nowIndex == 0 ) borderColor = Colors.deepOrangeAccent;
      else if( nowIndex == 1 ) borderColor = Colors.lightBlue;
      else borderColor = (money < 0 ? Colors.deepOrangeAccent : Colors.lightBlue);
    }
    else if( type == 2 ) borderColor = Colors.grey;

    date = date.substring(6, 8);
    date[0] == '0' ? date = date.substring(1) : date;

    money = money < 0 ? -money : money;
    String moneyString = _formatNumber(money.toString().replaceAll(',', ''));
    if( money >= 100000 ) moneyString = moneyString.substring(0, moneyString.length-3) + "-";
    if( money >= 1000000 ) moneyString = (money ~/ 10000).toString();
    return Container(
      padding: EdgeInsets.all(3),
      child: Container(
        padding: EdgeInsets.only(top: 3, bottom: 3),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(7)),
          color: color,
        ),
        child: Column(
          children: [
            Text(date, style: TextStyle(fontSize: 17),),
            Expanded(child: Text("")),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(moneyString,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: money >= 1000000 ? Colors.black54 : nowIndexColor[900]),),
                money >= 1000000 ? const Text("만",
                                   textAlign: TextAlign.center,
                                   style: TextStyle(fontSize: 9, color: Colors.black54, fontWeight: FontWeight.bold),)
                                 : const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableCalendar _makeTableCalendar(data) {
    DateSpecsMap = data;
    print("Calendar Here ${data.length.toString()}");
    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime.now().subtract(Duration(days: 365*10 + 2)),
      lastDay: DateTime.now().add(Duration(days: 365*10 + 2)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, dateTime, _) {
          return CalendarCellBuilder(context, dateTime, _, 0);
        },
        todayBuilder: (context, dateTime, _) {
          return CalendarCellBuilder(context, dateTime, _, 1);
        },
        selectedBuilder: (context, dateTime, _) {
          return CalendarCellBuilder(context, dateTime, _, 2);
        },
      ),
    );
  }

  Widget selectedDayCon(){
    if( _selectedDay == null ) return const SizedBox.shrink();
    return DaySpecCon(DateFormat('yy/MM/dd').format(_selectedDay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("달력"),
        actions: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                nowIndex = (nowIndex + 1) % 3;
              });
            },
            child: Row(
              children: [
                Icon(Icons.insert_invitation_rounded, color: Colors.white,),
                Text(" " + nowType[nowIndex],
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<List<Map<String, int>>>(
                future: _getSumQuery(),
                initialData: [{},{},{}],
                builder: (context, snapshot) {
                  return _makeTableCalendar(snapshot.data);
                },
              ),
              Divider(),
              selectedDayCon(),
            ],
          ),
        )
        ),
      );
  }
}