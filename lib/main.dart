import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DBHelper.dart';
import 'HomePage.dart';
import 'MyTheme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ColorProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<CategoryProvider>().init();
    print(context.read<CategoryProvider>().categories);
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme(
            primary: context.watch<ColorProvider>().palette[3],
            primaryVariant: context.watch<ColorProvider>().palette[3],
            secondary: context.watch<ColorProvider>().palette[2],
            secondaryVariant: context.watch<ColorProvider>().palette[2],
            surface: context.watch<ColorProvider>().palette[3],
            background: Colors.white,
            error: context.watch<ColorProvider>().palette[3],
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: context.watch<ColorProvider>().palette[3],
            onBackground: context.watch<ColorProvider>().palette[3],
            onError: context.watch<ColorProvider>().palette[3],
            brightness: Brightness.light),
      ),
      title: 'main',
      home: MyHomePage(),
    );
  }
}
