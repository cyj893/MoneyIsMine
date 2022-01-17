import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'InputSpecsPage.dart';
import 'DBHelper.dart';

class DaySpecCon extends StatefulWidget {

  final String date;

  const DaySpecCon(this.date);

  @override
  DaySpecConState createState() => DaySpecConState();
}

class DaySpecConState extends State<DaySpecCon> {
  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));
  List<Spec> _daySpecs = [];

  @override
  void initState() {
    super.initState();
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      print("onGoBack");
    });
  }

  Future<List<Spec>> _getDayQuery() async {
    String yy = widget.date.substring(0, 2);
    String MM = widget.date.substring(3, 5);
    String dd = widget.date.substring(6, 8);
    List<Spec> newList = await SpecProvider().getQuery(
        '''
        SELECT * FROM Specs
        WHERE dateTime = '$yy\/$MM\/$dd'
        ORDER BY id;
        ''');
    _daySpecs = newList;
    print("Here ${_daySpecs.length.toString()}");
    return newList;
  }

  void showDeleteDialog(Spec spec) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("삭제하시겠습니까?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("no")),
              TextButton(
                  onPressed: () {
                    SpecProvider().delete(spec);
                    PicProvider().deleteSpec(spec.id!);
                    _daySpecs.removeWhere((item) => item.id == spec.id);
                    Navigator.of(context).pop();
                    onGoBack(null);
                  },
                  child: Text("yes"))
            ],
          );
        });
  }

  Row makeDayExpTileChild(Spec spec) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text("${spec.category}"),
        ),
        Expanded(
          child: Text("${spec.contents}"),
        ),
        SizedBox(
            width: 100,
            child: Text("\₩ ${_formatNumber(
                (spec.money < 0 ? -spec.money : spec.money)
                    .toString()
                    .replaceAll(',', ''))}",
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: spec.type == 1 ? Colors.blue : Colors.orange),)
        ),
      ],
    );
  }

  List<Widget> makeDayExpTileChildren() {
    List<Widget> list = [];
    for (int i = 0; i < _daySpecs.length; i++) {
      list.add(InkWell(
        onTap: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InputSpecsPage(_daySpecs[i])
              )
          );
          if( result != null ){
            setState(() {
              _daySpecs[_daySpecs.indexWhere((item) => item.id == result.id )] = result;
            });
          }
        },
        onLongPress: () {
          showDeleteDialog(_daySpecs[i]);
        },
        child: makeDayExpTileChild(_daySpecs[i]),
      ));
      list.add(SizedBox(height: 10,));
    }
    list.add(IconButton(
      iconSize: 25,
      icon: Icon(Icons.add_circle, color: Colors.blue[200],),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InputSpecsPage(Spec(type: -2, money: 0, dateTime: widget.date))
            )
        ).then(onGoBack);
      },
    )
    );
    return list;
  }

  ExpansionTile makeDayExpTile() {
    return ExpansionTile(
      title: Chip(
        backgroundColor: Colors.blue[200],
        label: Text(
          "${widget.date} (${DateFormat.E('ko_KR').format(DateFormat("yy/MM/dd").parse(widget.date))})",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
      ),
      initiallyExpanded: false,
      children: makeDayExpTileChildren(),
    );
  }

  List<Widget> makeDaySummary(int p, int m, int sum) {
    List<Widget> list = [];
    list.add(Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Expanded(child: Text("수입", textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
        Expanded(child: Text("지출", textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
        Expanded(child: Text("합계", textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
      ],
    ));
    list.add(Divider());
    list.add(Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Text("${_formatNumber(p.toString().replaceAll(',', ''))} 원",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.blue),)),
        Expanded(child: Text(
          "${_formatNumber((-m).toString().replaceAll(',', ''))} 원",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.orange),)),
        Expanded(child: Text(
          "${_formatNumber(sum.toString().replaceAll(',', ''))} 원",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16, color: sum >= 0 ? Colors.blue : Colors.orange),)),
      ],
    ));
    return list;
  }

  Container makeDayCon() {
    int p = 0,
        m = 0,
        sum = 0;
    for (int i = 0; i < _daySpecs.length; i++) {
      _daySpecs[i].type == 1 ? p += _daySpecs[i].money : m += _daySpecs[i].money;
    }
    sum = p + m;
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        decoration: BoxDecoration(
          border: Border.all(color: (Colors.blue[100])!, width: 4),
          borderRadius: BorderRadius.all(
              Radius.circular(20.0)
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            makeDayExpTile(),
            Column(
                children: makeDaySummary(p, m, sum)
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Spec>>(
          future: _getDayQuery(),
          initialData: <Spec>[],
          builder: (context, snapshot) {
            return makeDayCon();
          },);

  }
}

