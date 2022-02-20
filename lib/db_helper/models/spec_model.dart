
class Spec {
  int? id;
  int type;
  String? category;
  int? method;
  String? contents;
  int money;
  String? dateTime;
  String? memo;

  Spec({this.id, required this.type, this.category, this.method, this.contents, required this.money, this.dateTime, this.memo});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'type': type,
      'category': category,
      'method': method,
      'contents': contents,
      'money': money,
      'dateTime': dateTime,
      'memo' : memo,
    };
  }

}
