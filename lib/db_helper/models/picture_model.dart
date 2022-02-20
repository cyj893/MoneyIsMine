import 'dart:typed_data';

class Picture {
  int? id;
  int specID;
  Uint8List picture;

  Picture({this.id, required this.specID, required this.picture});

  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "specID": specID,
      "picture" : picture,
    };
  }
}
