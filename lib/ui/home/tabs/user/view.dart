import 'package:flutter/material.dart';
import 'package:youphotomobile/ui/home/layout.dart';
import 'package:youphotomobile/config.dart';
import 'package:youphotomobile/ui/start/start.dart';
import 'package:youphotomobile/services/photo_cache_service.dart';

class UserTab extends StatelessWidget {
  const UserTab({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 72),
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    child: CircleAvatar(
                      child: Icon(
                        Icons.person_rounded,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        size: 48,
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: const Text(
                      "My",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w200),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete_sweep_rounded),
                      title: const Text("清理缓存"),
                      onTap: () async {
                        await PhotoCacheService().clearCache();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已清理缓存')),
                          );
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded),
                      title: const Text("Logout"),
                      onTap: () async {
                        // 清除用户配置
                        await ApplicationConfig().clearToken();
                        await ApplicationConfig().clearSessionId();
                        // 清除照片缓存
                        await PhotoCacheService().clearCache();
                        // 导航到登录页面
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const StartPage()),
                            (route) => false,
                          );
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
