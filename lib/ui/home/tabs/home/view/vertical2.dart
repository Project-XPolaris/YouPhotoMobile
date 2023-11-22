import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/components/AlbumSelectView.dart';
import 'package:youphotomobile/ui/home/tabs/home/view/ImageGrid.dart';
import 'package:youphotomobile/util/listview.dart';

import '../../../../viewer/view/wrap.dart';
import '../bloc/home_bloc.dart';

class TabHomeVerticalPage2 extends StatelessWidget {
  const TabHomeVerticalPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabHomeBloc, TabHomeState>(
      builder: (context, state) {
        print(state.photos.length);
        var controller = createLoadMoreController(
            () => context.read<TabHomeBloc>().add(LoadMoreEvent()));
        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async {
            context
                .read<TabHomeBloc>()
                .add(UpdateFilterEvent(filter: state.filter));
          },
          child: Stack(
            children: [
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                int crossAxisCount = (constraints.maxWidth / state.gridSize).round();
                // switch (state.viewMode) {
                //   case "large":
                //     crossAxisCount = (constraints.maxWidth / 170).round();
                //     break;
                //   case "medium":
                //     crossAxisCount = (constraints.maxWidth / 130).round();
                //     break;
                //   case "small":
                //     crossAxisCount = (constraints.maxWidth / 100).round();
                //     break;
                // }
                return GestureDetector(
                  child: GridView.builder(
                    cacheExtent: 10000,
                    controller: controller,
                    itemCount: state.photos.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemBuilder: (context, index) {
                      var content = ImageGrid(image: state.photos[index]);
                      return GestureDetector(
                        onTap: () async {
                          if (state.selectMode) {
                            context.read<TabHomeBloc>().add(OnSelectPhotoEvent(
                                photoId: state.photos[index].id!,
                                selected:
                                    !state.isSelected(state.photos[index].id!)));
                            return;
                          }
                          await ImageViewer.Launch(
                              context, context.read<TabHomeBloc>().loader, index,
                              (changedIndex) {
                            double mainAxisSize = constraints.maxWidth;
                            double crossAxisSize = constraints.maxHeight;
                            int itemHeight =
                                (mainAxisSize / crossAxisCount).floor();
                            int itemInRowIndex =
                                ((changedIndex.toDouble() + 1) / crossAxisCount)
                                    .ceil();
                            // calc offset in center of grid
                            double offset = (itemHeight * itemInRowIndex) -
                                (crossAxisSize / 2);
                            controller.jumpTo(offset);
                          });
                        },
                        onLongPress: () {
                          if (state.selectMode) {
                            return;
                          }
                          context
                              .read<TabHomeBloc>()
                              .add(OnChangeSelectModeEvent(selectMode: true));
                          context.read<TabHomeBloc>().add(OnSelectPhotoEvent(
                              photoId: state.photos[index].id!, selected: true));
                        },
                        child: Container(
                          child: Stack(children: [
                            Container(
                                padding: state.isSelected(state.photos[index].id!)
                                    ? const EdgeInsets.all(4)
                                    : const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                width: double.infinity,
                                height: double.infinity,
                                child: content),
                          ]),
                        ),
                      );
                    },
                  ),
                );
              }),
              state.selectMode
                  ? Positioned(
                      bottom: 16,
                      right: 16,
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    context.read<TabHomeBloc>().add(
                                        OnChangeSelectModeEvent(
                                            selectMode: false));
                                    context.read<TabHomeBloc>().add(
                                        OnUpdateSelectedPhotosEvent(
                                            selectedPhotoIds: []));
                                  },
                                  icon: Icon(Icons.close)),
                              Text("${state.selectedPhotoIds.length} selected"),
                              IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext modalContext) {
                                          return AlbumSelectView(
                                            onSelect: (albumId) async {
                                              context.read<TabHomeBloc>().add(
                                                  OnAddSelectedPhotosEvent(
                                                      albumId: albumId.id,
                                                      selectedPhotoIds: state
                                                          .selectedPhotoIds));
                                            },
                                          );
                                        });
                                  },
                                  icon: Icon(Icons.photo_album_outlined)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        );
      },
    );
  }
}
