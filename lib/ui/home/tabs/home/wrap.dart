import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youphotomobile/ui/components/PhotoFilter.dart';
import 'package:youphotomobile/ui/components/ScreenWidthSelector.dart';
import 'package:youphotomobile/ui/home/tabs/home/provider.dart';
import 'package:youphotomobile/ui/home/tabs/home/vertical.dart';

class TabHomeWrap extends StatelessWidget {
  const TabHomeWrap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TabHomeProvider>(
        create: (_) => TabHomeProvider(),
        child: Consumer<TabHomeProvider>(builder: (context, provider, child) {
          provider.loadData();
          return Scaffold(
            body: ScreenWidthSelector(
              verticalChild: TabHomeVerticalPage(provider: provider),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext modalContext) {
                      return PhotoFilterView(
                        filter: provider.filter,
                        onFilterChange: (filter) {
                          provider.filter = filter;
                          provider.loadData(force: true);
                        },
                      );
                    });
              },
              child: Icon(Icons.filter_list),
            ),
          );
        }));
  }
}
