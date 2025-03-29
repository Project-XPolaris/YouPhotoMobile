import 'package:flutter/material.dart';

import '../../config.dart';
import '../start/start.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  Key? refreshKey;

  refresh() {
    setState(() {
      refreshKey = UniqueKey();
    });
  }
  Future<bool> check() async {
    await ApplicationConfig().loadAppConfig();
    // var ok = await ApplicationConfig().checkConfig();
    // if (!ok) {
    //   return false;
    // }
    // ok = await ApplicationConfig().loadConfig();
    // return ok;
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: check(),
        builder: (context, snapshot) {
      if (snapshot.hasData) {
        return const StartPage();
      } else {
        return Container();
      }
    });
    return const StartPage();
  }
}
