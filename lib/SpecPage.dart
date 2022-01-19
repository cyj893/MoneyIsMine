import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrolling_page_indicator/scrolling_page_indicator.dart';
import 'DBHelper.dart';
import 'InputSpecsPage.dart';

class SpecPage extends StatefulWidget {
  final Spec nowInstance;

  const SpecPage(this.nowInstance);

  @override
  SpecPageState createState() => SpecPageState();
}

class SpecPageState extends State<SpecPage> {
  late Spec spec;
  Spec? modified;
  String pageName = "상세 페이지";

  final List<String> typeNames = ["지출", "수입"];

  final List<String> methodNames = ["기타", "카드", "이체", "현금", "기타"];

  final List<String> categoryAvatars = ["\u{2733}", "\u{1F354}", "\u{1F68C}", "\u{1F455}", "\u{2733}"];
  final List<String> categoryNames = ["기타", "식비", "교통비", "의류비", "기타"];

  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));

  List<Picture> _images = [];
  PageController _controller = PageController();
  // values end

  @override
  void initState() {
    super.initState();
    onGoBack(null);
  }

  void onGoBack(dynamic value) {
    spec = value == null ? widget.nowInstance : value!;
    _getPicDB(spec.id!);
    print(spec.category);
  }

  Future<List<Picture>> _getPicDB(int i) async {
    List<Picture> newlist = await PicProvider().getQuery(
        '''
      SELECT * FROM Pics
      WHERE specID = ${i}
      '''
    );
    setState(() {
      _images = newlist;
    });
    print("Pic Here ${_images.length}");
    return newlist;
  }

  Container makeSpecCon(){
    String method = methodNames[spec.method!];
    String money = _formatNumber(spec.money.toString().replaceAll(',', ''));
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 110,
      child: Row(
        children: <Widget>[
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("수단: ${method}"),
              Chip(
                avatar: CircleAvatar(
                  child: Text(categoryAvatars[0]),
                  backgroundColor: Colors.white,
                ),
                backgroundColor: Colors.blue[100],
                label: Text(categoryNames[0]),
              ),
              Text("내용: ${spec.contents!}"),
            ],
          )),
          VerticalDivider(),
          Expanded(child: Column(
            children: [
              Expanded(child: Text(typeNames[spec.type],
                                 style: TextStyle(
                                   fontSize: 20,
                                 ),)),
              Expanded(child: Text("${money} 원",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: spec.money < 0 ? Colors.orange : Colors.blue,
                                ),)),
            ],
          )),
        ],
      ),
    );
  }

  Widget makePics(){
    if( _images.isEmpty ) return SizedBox.shrink();
    return  SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width + 20,
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: PageView.builder(
                controller: _controller,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, i) {
                  return Image.memory(_images[i].picture, fit: BoxFit.fitWidth);
                }
            ),
          ),
          ScrollingPageIndicator(
              dotColor: Colors.grey,
              dotSelectedColor: Colors.blue[900],
              dotSize: 6,
              dotSelectedSize: 8,
              dotSpacing: 12,
              controller: _controller,
              itemCount: _images.length,
              orientation: Axis.horizontal
          ),
        ],
      ),
    );
  }

  Container makePicMemoCon(){
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          makePics(),
          spec.memo != "." ?SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(spec.memo!),
          ) : SizedBox.shrink(),
        ],
      ),
    );
  }
  // functions end
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text("  ${spec.dateTime!} (${DateFormat.E('ko_KR').format(DateFormat("yy/MM/dd").parse(spec.dateTime!))})",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),), Divider(),
              makeSpecCon(), Divider(),
              makePicMemoCon(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InputSpecsPage(spec)
              )
          );
          if( result != null ){
            setState(() {
              onGoBack(result);
              print("modified: ${result!.category}");
            });
          }
        },
        child: Icon(Icons.edit_rounded),
      ),
    );
  }
}