import 'package:flutter/material.dart';
import 'package:youphotomobile/ui/home/tabs/home/provider.dart';
import 'package:youphotomobile/ui/viewer/wrap.dart';
import 'package:youphotomobile/util/listview.dart';

class TabHomeVerticalPage extends StatelessWidget {
  final TabHomeProvider provider;

  const TabHomeVerticalPage({Key? key, required this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = createLoadMoreController(() => provider.loadMore());
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () async {
        await provider.loadData(force: true);
      },
      child: GridView.builder(
        cacheExtent: 100,
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.loader.list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              await ImageViewer.Launch(context, provider.loader, index);
              provider.notifyListeners();
            },
            child: Hero(
                tag: "imageHero_${provider.loader.list[index].id}",
                child: Container(
                  child: Image.network(
                    provider.loader.list[index].thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                )),
          );
        },
      ),
    );
  }
}
