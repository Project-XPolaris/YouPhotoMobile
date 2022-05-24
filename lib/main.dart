import 'package:flutter/material.dart';
import 'package:youphotomobile/ui/init/init.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouPhoto',
      theme: ThemeData(
        appBarTheme: AppBarTheme(elevation: 0),
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xffb5d27b),
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(elevation: 0),
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xffb5d27b)
        /* dark theme settings */
      ),
      themeMode: ThemeMode.system,
      home: Index(),
    );
  }
}

class Index extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InitPage();
  }
}
