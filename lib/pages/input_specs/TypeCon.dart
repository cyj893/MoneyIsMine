import 'package:flutter/material.dart';

class TypeCon extends StatefulWidget {
  List<int> typeBool;
  Color color;

  TypeCon(
      this.typeBool,
      this.color,
      );

  @override
  TypeConState createState() => TypeConState();
}

class TypeConState extends State<TypeCon> {
  final List<String> typeNames = ["지출", "수입"];

  List<Widget> initTypes(int index){
    return <Widget>[
      Checkbox(
          activeColor: widget.color,
          value: widget.typeBool[0] == index,
          onChanged: (bool? value) {
            setState(() {
              if( value == true ) widget.typeBool[0] = index;
              else widget.typeBool[0] = -1;
            });
          }),
      Text(typeNames[index]),
    ];
  }

  Container makeTypeCon(){
    return Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        height: 50,
        child: Row(
          children: <Widget>[
            Text("*", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
            Expanded(child:Row(children: initTypes(0))),
            Expanded(child:Row(children: initTypes(1))),
          ],
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return makeTypeCon();
  }

}

