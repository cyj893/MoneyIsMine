import 'package:flutter/material.dart';

class ContentsCon extends StatefulWidget {
  final TextEditingController contents;

  ContentsCon(
      this.contents,
      );

  @override
  ContentsConState createState() => ContentsConState();
}

class ContentsConState extends State<ContentsCon> {

  Container makeContentsCon(){
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: 50,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 100,
            child: Text("내용"),
          ),
          Expanded(
              child: TextField(
                controller: widget.contents,
                decoration: const InputDecoration(
                  hintText: "내용을 입력하세요",
                  isDense: true,
                ),
              )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return makeContentsCon();

  }

}

