import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:money_is_mine/db_helper/DBHelper.dart';

class PicCon extends StatefulWidget {
  List<int> picbools = [];
  List<XFile> images = [];
  List<Picture> existingImages = [];
  Color iconColor;

  PicCon(
    this.picbools,
    this.images,
    this.existingImages,
    this.iconColor,
  );

  @override
  PicConState createState() => PicConState();
}

class PicConState extends State<PicCon> {

  final ImagePicker picker = ImagePicker();

  Container makePicCon(){
    return Container(
        padding: const EdgeInsets.all(8.0),
        height: MediaQuery.of(context).size.width / 3,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.images.length + widget.existingImages.length + 1,
          itemBuilder: (context, index) {
            if( index == 0 ) {
              return IconButton(
                iconSize: 25,
                icon: Icon(Icons.add_circle, color: widget.iconColor,),
                onPressed: () async {
                  List<XFile>? images = await picker.pickMultiImage();
                  if( images != null ){
                    setState(() {
                      widget.images.addAll(images);
                    });
                  }
                },
              );
            }
            if( widget.picbools.contains(index) ) return SizedBox.shrink();
            if( index <= widget.existingImages.length ){
              return InkWell(
                onLongPress: () {
                  setState(() {
                    widget.picbools.add(index);
                  });
                },
                child: Image.memory(widget.existingImages[index-1].picture),
              );
            }
            return InkWell(
              onLongPress: () {
                setState(() {
                  widget.picbools.add(index);
                });
              },
              child: Image.file(File(widget.images[index-widget.existingImages.length-1].path)),
            );
          },
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return makePicCon();
  }

}

