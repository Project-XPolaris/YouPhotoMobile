import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/components/LocalAlbumSelectView.dart';

import '../../../api/album.dart';
import '../../../util/listview.dart';
import '../../viewer/view/wrap.dart';
import '../bloc/album_bloc.dart';

class AlbumDetailView extends StatelessWidget {
  final Album album;

  const AlbumDetailView({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return BlocProvider(
        create: (_) =>
            AlbumBloc(albumId: album.id)..add(const LoadDataEvent(force: false)),
        child: BlocBuilder<AlbumBloc, AlbumState>(
          builder: (context, state) {
            var controller = createLoadMoreController(
                () => context.read<AlbumBloc>().add(LoadMoreEvent()));
            onRemoveSelectImages() {
              context.read<AlbumBloc>().add(const RemoveSelectImagesEvent());
            }
            void onDownloadAllAlbum(String? albumName) {
              context
                  .read<AlbumBloc>()
                  .add(DownloadAllAlbumEvent(localAlbumName: albumName));
            }
            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(album.displayName),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  PopupMenuButton<String>(
                      icon: const Icon(Icons.view_column),
                      onSelected: (value) {
                        context
                            .read<AlbumBloc>()
                            .add(UpdateViewModeEvent(viewMode: value));
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: "large",
                            child: Text('Large'),
                          ),
                          const PopupMenuItem(
                            value: "medium",
                            child: Text('Medium'),
                          ),
                          const PopupMenuItem(
                            value: "small",
                            child: Text('Small'),
                          ),
                        ];
                      }),
                  PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case "downloadAll":
                            showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                      padding: const EdgeInsets.all(16),
                                      child: LocalAlbumSelectView(
                                          onAlbumSelected: (albumName) {
                                        onDownloadAllAlbum(albumName);
                                        Navigator.of(context).pop();
                                      }),
                                    ));

                            break;
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: "downloadAll",
                            child: Text('Download all'),
                          ),
                        ];
                      }),
                ],
              ),
              body: RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                onRefresh: () async {
                  context
                      .read<AlbumBloc>()
                      .add(UpdateFilterEvent(filter: state.filter));
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  child: Stack(
                    children: [
                      LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        int crossAxisCount =
                            (constraints.maxWidth / 130).round();
                        switch (state.viewMode) {
                          case "large":
                            crossAxisCount =
                                (constraints.maxWidth / 170).round();
                            break;
                          case "medium":
                            crossAxisCount =
                                (constraints.maxWidth / 130).round();
                            break;
                          case "small":
                            crossAxisCount =
                                (constraints.maxWidth / 100).round();
                            break;
                        }
                        //      height: constraints.maxHeight,
                        //      width: constraints.maxWidth
                        return GridView.builder(
                          controller: controller,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.photos.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemBuilder: (context, index) {
                            var content = CachedNetworkImage(
                              imageUrl: state.photos[index].thumbnailUrl,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                            );
                            return GestureDetector(
                              onTap: () async {
                                if (state.selectMode) {
                                  context.read<AlbumBloc>().add(
                                      OnSelectPhotoEvent(
                                          photoId: state.photos[index].id!,
                                          selected: !state.isSelected(
                                              state.photos[index].id!)));
                                  return;
                                }
                                await ImageViewer.Launch(
                                    context,
                                    context.read<AlbumBloc>().loader,
                                    index, (changedIndex) {
                                  double mainAxisSize = constraints.maxWidth;
                                  double crossAxisSize = constraints.maxHeight;
                                  int itemHeight =
                                      (mainAxisSize / crossAxisCount).floor();
                                  int itemInRowIndex =
                                      ((changedIndex.toDouble() + 1) /
                                              crossAxisCount)
                                          .ceil();
                                  // calc offset in center of grid
                                  double offset =
                                      (itemHeight * itemInRowIndex) -
                                          (crossAxisSize / 2);
                                  controller.jumpTo(offset);
                                });
                              },
                              onLongPress: () {
                                if (state.selectMode) {
                                  return;
                                }
                                context.read<AlbumBloc>().add(
                                    const OnChangeSelectModeEvent(selectMode: true));
                                context.read<AlbumBloc>().add(
                                    OnSelectPhotoEvent(
                                        photoId: state.photos[index].id!,
                                        selected: true));
                              },
                              child: Container(
                                child: Stack(children: [
                                  Container(
                                      padding: state.isSelected(
                                              state.photos[index].id!)
                                          ? const EdgeInsets.all(4)
                                          : const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: content),
                                ]),
                              ),
                            );
                          },
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
                                  padding: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            context.read<AlbumBloc>().add(
                                                const OnChangeSelectModeEvent(
                                                    selectMode: false));
                                            context.read<AlbumBloc>().add(
                                                const OnUpdateSelectedPhotosEvent(
                                                    selectedPhotoIds: []));
                                          },
                                          icon: const Icon(Icons.close)),
                                      Text(
                                          "${state.selectedPhotoIds.length} selected"),
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text("Delete"),
                                                    content: Text(
                                                        "Are you sure to delete ${state.selectedPhotoIds.length} images?"),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text("Cancel")),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            onRemoveSelectImages();
                                                          },
                                                          child: const Text("Delete"))
                                                    ],
                                                  );
                                                });
                                          },
                                          icon: const Icon(Icons.delete)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  static Launch(BuildContext context, Album album) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AlbumDetailView(
                  album: album,
                )));
  }
}
