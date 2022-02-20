import 'package:flutter/material.dart';

import 'category_edit_page.dart';

class CategoryCon extends StatefulWidget {
  final List<int> categoryBool;
  final List<String> categoryNames;
  final Map<String, String> categoryMap;
  final Color chipColor;
  final Color iconColor;
  final Color selectedColor;

  CategoryCon(
      this.categoryBool,
      this.categoryNames,
      this.categoryMap,
      this.chipColor,
      this.iconColor,
      this.selectedColor,
      );

  @override
  CategoryConState createState() => CategoryConState();
}

class CategoryConState extends State<CategoryCon> {

  List<Widget> initCategories(){
    List<Widget> list = [];
    for(int i = 0; i < widget.categoryNames.length; i++){
      list.add(
          InkWell(
              splashColor: Colors.transparent,
              child: Chip(
                avatar: CircleAvatar(
                  child: widget.categoryBool[0] == i ? const Text("\u{2714}") : Text(widget.categoryMap[widget.categoryNames[i]]!),
                  backgroundColor: Colors.white,
                ),
                backgroundColor: widget.categoryBool[0] == i ? widget.selectedColor : widget.chipColor,
                label: widget.categoryBool[0] == i ? Text(widget.categoryNames[i], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),) : Text(widget.categoryNames[i]),
              ),
              onTap: () {
                setState(() {
                  if( widget.categoryBool[0] == i ){
                    widget.categoryBool[0] = -1;
                    return ;
                  }
                  widget.categoryBool[0] = i;
                  print("Tapped " + widget.categoryMap[widget.categoryNames[i]]!);
                });
              }
          ));
      list.add(const SizedBox(width: 10));
    }
    return list;
  }
  Container makeCategoryCon(){
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: 50,
      child: Row(
        children: <Widget>[
          SizedBox(
              width: 100,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text("카테고리"),
                    IconButton(
                      iconSize: 20,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoryEditPage()
                            )
                        );
                      },
                      icon: const Icon(Icons.format_list_bulleted_rounded),
                      color: widget.iconColor,
                    ),
                  ]
              )
          ),
          Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: initCategories(),
              )
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return makeCategoryCon();
  }

}

