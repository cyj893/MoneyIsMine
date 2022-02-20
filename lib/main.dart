import 'package:flutter/material.dart';
import 'db_helper/inputs_provider.dart';
import 'package:provider/provider.dart';
import 'db_helper/db_helper.dart';
import 'pages/home_page.dart';
import 'db_helper/color_provider.dart';

void main() {
  SpecDBHelper();
  DaySpecDBHelper();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => InputsProvider()),
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
    List<Color> paletteProvider = context.watch<ColorProvider>().palette;
    context.read<CategoryProvider>().init();
    context.read<InputsProvider>().init();
    print(context.read<CategoryProvider>().categories);
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        unselectedWidgetColor: paletteProvider[1],
        colorScheme: ColorScheme(
            primary: paletteProvider[3],
            primaryVariant: paletteProvider[3],
            secondary: paletteProvider[2],
            secondaryVariant: paletteProvider[2],
            surface: Colors.white,
            background: Colors.white,
            error: paletteProvider[3],
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.black87,
            onBackground: paletteProvider[3],
            onError: paletteProvider[3],
            brightness: Brightness.light),
      ),
      title: 'main',
      home: MyHomePage(),
    );
  }
}
