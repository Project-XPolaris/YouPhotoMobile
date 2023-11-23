import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:youphotomobile/config.dart';
import 'package:youphotomobile/notification.dart';
import 'package:youphotomobile/ui/home/wrap.dart';
import 'package:youui/layout/login/LoginLayout.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  void requestPermission() async {
    await NotificationPlugin().init();
  }

  @override
  void initState() {
    requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoginLayout(
        onLoginSuccess: (loginAccount) {
          ApplicationConfig().serviceUrl = loginAccount.apiUrl;
          ApplicationConfig().token = loginAccount.token;
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePageWrap()));
        },
        title: "YouPhoto",
        subtitle: "ProjectXPolaris",
      ),
    );
  }
}
