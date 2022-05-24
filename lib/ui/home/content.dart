import 'package:flutter/material.dart';
import 'package:youphotomobile/ui/home/provider.dart';
import 'package:youphotomobile/ui/home/tabs/home/wrap.dart';

class HomePageContent extends StatelessWidget {
  final HomeProvider provider;
  const HomePageContent({Key? key,required this.provider}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IndexedStack(
        index: provider.activeTab,
        children: <Widget>[
          TabHomeWrap(),
          Container(),
          Container()
        ],
      ),
    );
  }
}
// http://localhost:8609