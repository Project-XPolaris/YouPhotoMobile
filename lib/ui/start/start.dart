import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
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
    bool androidExistNotSave = false;
    bool isGranted;
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      if (androidExistNotSave) {
        isGranted = await Permission.storage.request().isGranted;
      } else {
        isGranted = sdkInt < 29 ? await Permission.storage.request().isGranted : true;
      }
    } else {
      isGranted = await Permission.photosAddOnly.request().isGranted;
    }
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
