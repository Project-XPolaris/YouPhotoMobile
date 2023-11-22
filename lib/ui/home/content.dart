import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/home/layout.dart';
import 'package:youphotomobile/ui/home/tabs/album/album/album_list_vew.dart';
import 'package:youphotomobile/ui/home/tabs/home/view/wrap.dart';
import 'package:youphotomobile/ui/home/tabs/library/view/library_list_vew.dart';
import 'package:youphotomobile/ui/home/tabs/local/index.dart';

import 'bloc/home_bloc.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return IndexedStack(
          index: state.tabIndex,
          children: <Widget>[
            TabHomeWrap(),
            AlbumView(),
            HomeLayout(child:TabLocalImage()),
            HomeLayout(child:Container()),
            // HomeLayout(child:Container()),
            // HomeLayout(child:Container())
            // Container(),
            // Container(),
            // Container()
          ],
        );
      },
    );
  }
}
// http://localhost:8609