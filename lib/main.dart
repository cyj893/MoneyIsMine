import 'dart:async';
import 'package:flutter/material.dart';
import './InputSpecsPage.dart';
import 'DBHelper.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'main',
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState  extends State<RandomWords> {
  List<Spec> specs = [];

  @override
  void initState(){
    super.initState();
    _getDB();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'main',
        home: Scaffold(
          appBar: AppBar(
            title: Text("main"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InputSpecsPage()
                  )
              ).then(onGoBack);
            },
            child: Icon(Icons.add),
          ),
          body: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: specs.length,
              itemBuilder: (context, i) {
                return _buildRow(specs[i]);
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
          ),
        )
    );
  }

  void _getDB() async {
    List<Spec> newList = await SpecProvider().getDB();
    setState(() {
      specs = newList;
    });
  }

  Widget _buildRow(Spec spec) {
    return ListTile(
      title: Text(
        spec.type.toString()
      ),
      subtitle: Text(
        spec.dateTime.toString(),
      ),
    );
  }

  FutureOr onGoBack(dynamic value) {
    _getDB();
  }
}

