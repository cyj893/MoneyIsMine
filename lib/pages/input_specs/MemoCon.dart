import 'package:flutter/material.dart';

class MemoCon extends StatefulWidget {
  TextEditingController memo;

  MemoCon(
      this.memo,
      );

  @override
  MemoConState createState() => MemoConState();
}

class MemoConState extends State<MemoCon> {

  Container makeMemoCon(){
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: 50,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 100,
            child: Text("메모"),
          ),
          Expanded(
              child: TextField(
                controller: widget.memo,
                decoration: const InputDecoration(
                  hintText: "메모를 입력하세요",
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
    return makeMemoCon();

  }

}

