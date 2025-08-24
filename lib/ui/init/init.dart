import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config.dart';
import '../start/start.dart';
import '../home/wrap.dart';
import '../bloc/app_bloc.dart';

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
    await ApplicationConfig().loadConfig();

    // 检查服务器状态
    context.read<AppBloc>().add(const CheckServerStateEvent());

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: check(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
                future: ApplicationConfig().hasLoginInfo(),
                builder: (context, loginSnapshot) {
                  if (loginSnapshot.hasData && loginSnapshot.data == true) {
                    // 如果有登录信息，直接进入主页
                    return const HomePageWrap();
                  } else {
                    // 没有登录信息，进入开始页面
                    return const StartPage();
                  }
                });
          } else {
            return Container();
          }
        });
  }
}
