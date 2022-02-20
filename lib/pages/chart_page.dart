import 'package:flutter/material.dart';

import 'charts/pie_chart_category_sum_con.dart';
import 'charts/bar_chart_week_con.dart';
import 'charts/bezier_chart_trend_con.dart';

class ChartPage extends StatefulWidget {

  const ChartPage();

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {
  String pageName = "차트";
  List<Widget> _weekPages = [Center(child: WeekCon(DateTime.now()),), Center(child: WeekCon(DateTime.now().subtract(Duration(days: 7))),),];
  var _controller = PageController(initialPage: 0);
  int _prevCount = 1;
  bool isFirstPage = true;
  Duration swipeDuration = const Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
  }

  void onGoBack(dynamic value) {
    ;
  }

  Widget makeWeekConPageView(){
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width*0.5 + 110 + 40,
          child: PageView.builder(
            reverse: true,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (pageId) {
              if( pageId == 0 ){
                isFirstPage = true;
                setState(() {});
                return ;
              }
              if( pageId == 1 && isFirstPage && _weekPages.length > 2 ){
                isFirstPage = false;
                setState(() {});
                return ;
              }
              if( pageId == _weekPages.length - 1 ){
                isFirstPage = false;
                print("Add last");
                _prevCount = _prevCount + 1;
                _weekPages.add(Center(child: WeekCon(DateTime.now().subtract(Duration(days: 7*_prevCount))),));
                setState(() {});
              }
            },
            controller: _controller,
            itemCount: _weekPages.length,
            itemBuilder: (context, i) { return _weekPages[i]; },
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _controller.nextPage(duration: swipeDuration, curve: Curves.easeIn);
                  },
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  color: const Color(0x7f7f7f7f),),
                Expanded(child: Container()),
                IconButton(
                  onPressed: () {
                    if( isFirstPage ) return;
                    _controller.previousPage(duration: swipeDuration,
                        curve: Curves.easeIn);
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  color: isFirstPage ? const Color(0x007f7f7f) : const Color(0x7f7f7f7f),),
              ],
            ),
          ),),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15,),
              CategorySumCon(),
              const SizedBox(height: 15,),
              makeWeekConPageView(),
              const SizedBox(height: 15,),
              TrendCon(),
              const SizedBox(height: 15,),
            ],
          ),
        ),
      ),
    );
  }
}
