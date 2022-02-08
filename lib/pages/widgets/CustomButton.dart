import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget{
  final String text;
  final Color textColor;
  final Function onTap;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.textColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Chip(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[200]!, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        label: Text(text, style: TextStyle(color: textColor,),),
      ),);
  }

}