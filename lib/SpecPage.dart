import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';
import 'package:scrolling_page_indicator/scrolling_page_indicator.dart';
import 'db_helper/DBHelper.dart';
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

  final List<String> methodIcons = ["*", "\u{1F4B3}", "\u{1F4B8}", "\u{1F4B5}", "*"];
  final List<String> methodNames = ["기타", "카드", "이체", "현금", "기타"];

  Map<String, String> categoryMap = {"기타": "*"};

  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));

  List<Picture> _images = [];
  PageController _controller = PageController();
  // values end

  @override
  void initState() {
    super.initState();

    categoryMap = context.read<CategoryProvider>().map;
    onGoBack(null);
  }

  void onGoBack(dynamic value) {
    spec = value == null ? widget.nowInstance : value!;
    _getPicDB(spec.id!);
    print(spec.category);
  }

  Future<List<Picture>> _getPicDB(int i) async {
    List<Picture> newlist = await PicDBHelper().getQuery(
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
    String money = _formatNumber(spec.money.toString().replaceAll(',', ''));
    String categoryIcon, categoryName;
    if( categoryMap.containsKey(spec.category!) ){
      categoryIcon = categoryMap[spec.category!]!;
      categoryName = spec.category!;
    }
    else{
      categoryIcon = "*";
      categoryName = "기타";
    }
    return Container(
      padding: const EdgeInsets.only(left: 8.0),
      height: 120,
      child: Row(
        children: <Widget>[
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                avatar: CircleAvatar(
                  child: Text(methodIcons[spec.method!]),
                  backgroundColor: Colors.white,
                ),
                backgroundColor: Colors.blue[100],
                label: Text(methodNames[spec.method!]),
              ),
              Chip(
                avatar: CircleAvatar(
                  child: Text(categoryIcon),
                  backgroundColor: Colors.white,
                ),
                backgroundColor: Colors.blue[100],
                label: Text(categoryName),
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
          SizedBox(height: 5,),
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