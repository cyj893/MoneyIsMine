import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class DateTimeCon extends StatefulWidget {
  final List<DateTime> dateTime;
  final List<int> nowPage;
  final List<int> mw;
  final List<List<bool>> mwBoolArr;
  final List<bool> isFixed;
  final List<int> repeatVal;
  final Color chipColor;
  final Color iconColor;
  final Color selectedColor;

  DateTimeCon(
      this.dateTime,
      this.nowPage,
      this.mw,
      this.mwBoolArr,
      this.isFixed,
      this.repeatVal,
      this.chipColor,
      this.iconColor,
      this.selectedColor,
      );

  @override
  DateTimeConState createState() => DateTimeConState();
}

class DateTimeConState extends State<DateTimeCon> {

  PageController _controller = PageController();
  List<List<String>> mwArr = [List.generate(31, (index) => (index+1).toString()),
                              ["월", "화", "수", "목", "금", "토", "일"]];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.dateTime[0],
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if( picked != null && picked != widget.dateTime[0] ){
      setState(() {
        widget.dateTime[0] = picked;
      });
    }
  }

  void showFixedDialog(){
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                    title: const Text("고정 지출/수입일"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            widget.isFixed[0] = false;
                            Navigator.of(context).pop();
                          },
                          child: const Text("취소")),
                      TextButton(
                          onPressed: () {
                            widget.isFixed[0] = true;
                            Navigator.of(context).pop();
                          },
                          child: const Text("저장")),
                    ],
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() { widget.mw[0] = 1 - widget.mw[0]; });
                              },
                              child: Chip(
                                label: Text(widget.mw[0] == 0 ? "매월" : "매주",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                backgroundColor: widget.iconColor,
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: Container(
                                height: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        children: List.generate(
                                            widget.mwBoolArr[widget.mw[0]].length,
                                                (index) => widget.mwBoolArr[widget.mw[0]][index]
                                                ? Text("${mwArr[widget.mw[0]][index]}, ")
                                                : SizedBox.shrink()),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showDialog(context: context, builder: (context){
                                            return AlertDialog(
                                              content: Wrap(
                                                children: List.generate(mwArr[widget.mw[0]].length, (index) =>
                                                    InkWell(
                                                        onTap: () {
                                                          widget.mwBoolArr[widget.mw[0]][index] = !widget.mwBoolArr[widget.mw[0]][index];
                                                          setState(() {});
                                                          Navigator.pop(context);
                                                        },
                                                        child: Chip(
                                                          label: Text(mwArr[widget.mw[0]][index],
                                                            style: TextStyle(
                                                                color: widget.mwBoolArr[widget.mw[0]][index] ? Colors
                                                                    .white : Colors.black,
                                                                fontWeight: widget.mwBoolArr[widget.mw[0]][index]
                                                                    ? FontWeight.bold : FontWeight.normal),),
                                                          backgroundColor: widget.mwBoolArr[widget.mw[0]][index]
                                                              ? widget.selectedColor
                                                              : widget.chipColor,
                                                        ))),
                                              ),
                                            );
                                          });
                                        },
                                        icon: Icon(Icons.add_circle_outline_rounded, color: widget.iconColor,)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Text(widget.mw[0] == 0 ? "일" : "요일"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NumberPicker(
                                selectedTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.selectedColor),
                                minValue: 1,
                                maxValue: 100,
                                value: widget.repeatVal[0],
                                textStyle: const TextStyle(color: Colors.grey),
                                onChanged: (val){
                                  setState(() { widget.repeatVal[0] = val; });
                                }),
                            const Text("회  반복"),
                          ],
                        )
                      ],
                    ),
                );
              });
        }).then((value) => setState(() {}));
  }

  PageView makePageView(){
    String mwStr = widget.mw[0] == 0 ? "매월" : "매주";
    String things = "";
    for(int i = 0; i < mwArr[widget.mw[0]].length; i++){
      if( widget.mwBoolArr[widget.mw[0]][i] ) things += mwArr[widget.mw[0]][i] + ", ";
    }
    things = things == "" ? "?" : things.substring(0, things.length-2);
    String mwStr2 = widget.mw[0] == 0 ? "일" : "요일";

    return PageView(
      controller: _controller,
      onPageChanged: (index) {
        setState(() {
          widget.nowPage[0] = index;
        });
      },
      children: [
        Center(
          child: InkWell(
            child: Text("${widget.dateTime[0].toLocal()}".split(' ')[0],
              style: const TextStyle(decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                  fontSize: 16),
              textAlign: TextAlign.center,),
            onTap: () {
              _selectDate(context);
            },
          ),
        ),
        Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () { showFixedDialog(); },
                  child: Text("$mwStr $things$mwStr2 ${widget.repeatVal[0]}회 반복"),
                ),
                IconButton(
                    onPressed: () { showFixedDialog(); },
                    icon: Icon(Icons.edit_rounded, color: widget.iconColor,))
              ],
            )
        ),
      ],
    );
  }

  Container makeDateTimeCon(){
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: 50,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.nowPage[0] == 0 ? "날짜" : "고정일자"),
                IconButton(
                  onPressed: () {
                    if( widget.nowPage[0] == 0 ) _controller.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeIn);
                    else _controller.previousPage(duration: Duration(milliseconds: 400), curve: Curves.easeIn);
                  },
                  icon: widget.nowPage[0] == 0 ? const Icon(Icons.arrow_forward_ios_rounded) : const Icon(Icons.arrow_back_ios_rounded),
                  color: widget.iconColor,),
              ],
            ),
          ),
          Expanded(
            child: makePageView(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller = PageController(initialPage: widget.nowPage[0]);
    return makeDateTimeCon();
  }

}

