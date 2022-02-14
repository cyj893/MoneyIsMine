import 'package:flutter/material.dart';

class MethodCon extends StatefulWidget {
  List<int> methodBool;
  Color color;

  MethodCon(
      this.methodBool,
      this.color,
      );

  @override
  MethodConState createState() => MethodConState();
}

class MethodConState extends State<MethodCon> {
  final List<String> methodNames = ["기타", "카드", "이체", "현금", "기타"];

  List<Widget> initMethods(int index){
    return <Widget>[
      Checkbox(
          activeColor: widget.color,
          value: widget.methodBool[0] == index,
          onChanged: (bool? value) {
            setState(() {
              if( value == true ) widget.methodBool[0] = index;
              else widget.methodBool[0] = -1;
            });
          }),
      Text(methodNames[index]),
    ];
  }
  Container makeMethodCon(){
    return Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        height: 50,
        child: Row(
          children: <Widget>[
            Expanded(child:Row(children: initMethods(1))),
            Expanded(child:Row(children: initMethods(2))),
            Expanded(child:Row(children: initMethods(3))),
            Expanded(child:Row(children: initMethods(4))),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return makeMethodCon();
  }

}

