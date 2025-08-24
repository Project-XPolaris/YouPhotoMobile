import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/bloc/app_bloc.dart';
import 'package:youphotomobile/ui/init/init.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'YouPhoto',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(elevation: 0),
          brightness: Brightness.light,
          useMaterial3: true,
          colorSchemeSeed: const Color(0xffb5d27b),
          /* light theme settings */
        ),
        darkTheme: ThemeData(
            appBarTheme: const AppBarTheme(elevation: 0),
            brightness: Brightness.dark,
            useMaterial3: true,
            colorSchemeSeed: const Color(0xffb5d27b)
            /* dark theme settings */
            ),
        themeMode: ThemeMode.system,
        home: const Index(),
      ),
    );
  }
}

class Index extends StatelessWidget {
  const Index({super.key});

  @override
  Widget build(BuildContext context) {
    return const InitPage();
  }
}
