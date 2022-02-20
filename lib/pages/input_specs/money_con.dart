import 'package:flutter/material.dart';

import 'package:money_is_mine/pages/widgets/custom_button.dart';
import 'package:money_is_mine/pages/widgets/money_textfield.dart';

class MoneyCon extends StatefulWidget {
  final TextEditingController money;
  final Color textColor;

  MoneyCon(
      this.money,
      this.textColor,
      );

  @override
  MoneyConState createState() => MoneyConState();
}

class MoneyConState extends State<MoneyCon> {

  bool isMoneyFocused = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState(){
    super.initState();

    focusNode.addListener(() {
      setState(() {
        isMoneyFocused = focusNode.hasFocus;
      });
    });
  }

  void addMoney(int addVal){
    if( widget.money.text == "" ) widget.money.text = moneyToString(addVal);
    else{
      int newVal = int.parse(widget.money.text.replaceAll(',', '')) + addVal;
      widget.money.text = moneyToString(newVal);
    }
  }

  Widget makeButtons(){
    return isMoneyFocused
        ? Column(
            children: [
              SizedBox(height: 10,),
              Row(
                children: [
                  CustomButton( onTap: () { addMoney(1000); }, text: "+1천", textColor: widget.textColor, ),
                  CustomButton( onTap: () { addMoney(5000); }, text: "+5천", textColor: widget.textColor, ),
                  CustomButton( onTap: () { addMoney(10000); }, text: "+1만", textColor: widget.textColor, ),
                  CustomButton( onTap: () { addMoney(50000); }, text: "+5만", textColor: widget.textColor, ),
                  CustomButton( onTap: () { addMoney(100000); }, text: "+10만", textColor: widget.textColor, ),
                  CustomButton( onTap: () { addMoney(1000000); }, text: "+100만", textColor: widget.textColor, ),
                ],
              )
            ],
          )
        : SizedBox.shrink();
  }

  AnimatedContainer makeMoneyCon(){
    return AnimatedContainer(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: isMoneyFocused ? 110 : 50,
      duration: Duration(milliseconds: 300),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: <Widget>[
                SizedBox(
                    width: 100,
                    child: Row(
                      children: const [
                        Text("금액 "),
                        Text("*", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                      ],
                    )
                ),
                Expanded(
                  child: MoneyTextField(
                    controller: widget.money,
                    focusNode: focusNode,
                  ),
                ),
              ],
            ),
            makeButtons(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return makeMoneyCon();
  }

}

