import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youphotomobile/ui/home/provider.dart';
import 'package:youui/components/navigation.dart';
import 'package:youui/layout/home/home.dart';

import 'appbar.dart';
import 'content.dart';

class HomePageWrap extends StatelessWidget {
  const HomePageWrap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
        create: (_) => HomeProvider(),
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
          return ResponsiveTabPageLayout(
            onTabIndexChange: provider.setActiveTab,
            tabIndex: provider.activeTab,
            navItems: [
              NavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              NavigationBarItem(icon: Icon(Icons.photo_album), label: "Album"),
              NavigationBarItem(icon: Icon(Icons.person), label: "User")
            ],
            appbar: renderHomeAppBar(context),
            navigationStyle: NavigationStyle(),
            body: HomePageContent(
              provider: provider,
            ),
            action: Container(
              padding: EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.search))
                ],
              ),
            ),
          );
        }));
  }
}
