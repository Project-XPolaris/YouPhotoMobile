import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/config.dart';
import 'package:youphotomobile/notification.dart';
import 'package:youphotomobile/ui/home/wrap.dart';
import 'package:youui/layout/login/LoginLayout.dart';
import 'package:youphotomobile/ui/start/youauth_md.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/bloc/app_bloc.dart';

// 启动页面组件
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  // 请求应用所需权限
  void requestPermission() async {
    // 初始化通知插件
    await NotificationPlugin().init();

    // 根据平台类型请求不同的权限
    if (Platform.isAndroid) {
      // Android平台
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      // Android 10 (SDK 29)以下版本需要请求存储权限
      if (sdkInt < 29) {
        await Permission.storage.request();
      }
    } else {
      // iOS平台：请求照片添加权限
      await Permission.photosAddOnly.request();
    }
  }

  @override
  void initState() {
    // 组件初始化时请求权限
    requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 构建登录界面
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: LoginLayout(
                  // 登录成功回调
                  onLoginSuccess: (loginAccount) async {
                    if (loginAccount.token == null ||
                        loginAccount.apiUrl == null) {
                      return;
                    }
                    // 设置应用配置
                    ApplicationConfig().serviceUrl = loginAccount.apiUrl;
                    ApplicationConfig().token = loginAccount.token;

                    // 保存登录信息
                    await ApplicationConfig().saveToken(loginAccount.token!);
                    await ApplicationConfig()
                        .saveServiceUrl(loginAccount.apiUrl!);
                    // 获取用户信息
                    var user = await ApiClient().fetchUser();
                    await ApplicationConfig().saveUserId(user.data!.id!);
                    await ApplicationConfig().generateAndSaveSessionId();
                    // 登录后检测服务器在线状态
                    context.read<AppBloc>().add(const CheckServerStateEvent());

                    // 清除导航栈直到第一个页面
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // 跳转到主页
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePageWrap()));
                  },
                  title: "YouPhoto",
                  subtitle: "ProjectXPolaris",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.dashboard),
                  label: const Text("使用 MediaDashboard 登录并选择服务"),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const MdLoginPage()),
                    );
                    if (result == true) {
                      // 如果通过 MediaDashboard 完成登录，则与正常登录后的流程一致
                      var user = await ApiClient().fetchUser();
                      await ApplicationConfig().saveUserId(user.data!.id!);
                      await ApplicationConfig().generateAndSaveSessionId();
                      // 通过 MediaDashboard 登录后检测服务器在线状态
                      context
                          .read<AppBloc>()
                          .add(const CheckServerStateEvent());
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePageWrap()));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
