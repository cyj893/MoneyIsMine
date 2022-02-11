import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoneyTextField extends StatelessWidget {
  String _formatNumber(String s) => NumberFormat.decimalPattern('ko_KR').format(int.parse(s));
  final controller;
  final FocusNode focusNode;

  const MoneyTextField({
    Key? key,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: "금액을 입력하세요",
        isDense: true,
        suffixText: "\₩",
      ),
      onChanged: (string) {
        if( string.isEmpty ) return ;
        string = _formatNumber(string.replaceAll(',', ''));
        controller.value = TextEditingValue(
          text: string,
          selection: TextSelection.collapsed(offset: string.length),
        );
      },
    );
  }
}