import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/util/listview.dart';
import 'package:youphotomobile/util/screen.dart';

import '../../../../viewer/view/wrap.dart';
import '../bloc/home_bloc.dart';

class TabHomeVerticalPage extends StatelessWidget {
  const TabHomeVerticalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabHomeBloc, TabHomeState>(
      builder: (context, state) {
        var controller = createLoadMoreController(
            () => context.read<TabHomeBloc>().add(LoadMoreEvent()));
        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async {
            context
                .read<TabHomeBloc>()
                .add(UpdateFilterEvent(filter: state.filter));
          },
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            int crossAxisCount = (constraints.maxWidth / 130).round();
            switch (state.viewMode) {
              case "large":
                crossAxisCount = (constraints.maxWidth / 170).round();
                break;
              case "medium":
                crossAxisCount = (constraints.maxWidth / 130).round();
                break;
              case "small":
                crossAxisCount = (constraints.maxWidth / 100).round();
                break;
            }
//      height: constraints.maxHeight,
//      width: constraints.maxWidth
            return GridView.builder(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.photos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemBuilder: (context, index) {
                var content = CachedNetworkImage(
                  imageUrl: state.photos[index].thumbnailUrl,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                );
                return GestureDetector(
                  onTap: () async {
                    await ImageViewer.Launch(
                        context, context.read<TabHomeBloc>().loader, index,
                        (changedIndex) {
                      double mainAxisSize = constraints.maxWidth;
                      double crossAxisSize = constraints.maxHeight;
                      int itemHeight = (mainAxisSize / crossAxisCount).floor();
                      int itemInRowIndex =
                          ((changedIndex.toDouble() + 1) / crossAxisCount)
                              .ceil();
                      // calc offset in center of grid
                      double offset =
                          (itemHeight * itemInRowIndex) - (crossAxisSize / 2);
                      controller.jumpTo(offset);
                    });
                  },
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: content,
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}
