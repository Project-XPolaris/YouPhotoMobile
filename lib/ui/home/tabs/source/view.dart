import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:youphotomobile/api/album.dart';
import 'package:youphotomobile/ui/components/CreateAlbumDialog.dart';
import '../../../../util/listview.dart';
import '../../../album/view/album_view.dart';
import '../../../components/CreateLibraryDialog.dart';
import '../../../components/RemoveAlbumDialog.dart';
import '../../../local/index.dart';
import '../../../localalbum/view.dart';
import '../../layout.dart';
import 'bloc/source_bloc.dart';

class SourceTab extends StatefulWidget {
  const SourceTab({super.key});

  @override
  State<SourceTab> createState() => _SourceTabState();
}

class _SourceTabState extends State<SourceTab> {
  Future<Uint8List?> getAlbumThumb(AssetPathEntity entity) async {
    final AssetEntity? asset = await entity
        .getAssetListRange(start: 0, end: 1)
        .then((value) => value.first);
    if (asset != null) {
      return await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
        child: BlocProvider(
      create: (context) => SourceBloc()
        ..add(RefreshDeviceAlbumEvent())
        ..add(LoadAlbumEvent(force: false))
        ..add(LoadLibraryEvent()),
      child: BlocBuilder<SourceBloc, SourceState>(
        builder: (context, state) {
          ScrollController controller = createLoadMoreController(
              () => context.read<SourceBloc>().add(LoadMoreAlbumEvent()));
          int getRowItemCount() {
            var itemWith = 140;
            var screenWidth = MediaQuery.of(context).size.width;

            return screenWidth ~/ itemWith;
          }

          onCreateLibrary(String libraryName) {
            context
                .read<SourceBloc>()
                .add(CreateLibraryEvent(libraryName: libraryName));
          }

          onCreateAlbum(String name) {
            context.read<SourceBloc>().add(CreateAlbumEvent(name: name));
          }

          onDeleteAlbum(int albumId, bool removeImage) {
            context
                .read<SourceBloc>()
                .add(RemoveAlbumEvent(id: albumId, removeImage: removeImage));
          }

          onOpenDeleteAlbumDialog(int albumId) {
            showDialog(
                context: context,
                builder: (context) {
                  return RemoveAlbumDialog(
                    onRemove: (removeImage) {
                      onDeleteAlbum(albumId, removeImage);
                      Navigator.of(context).pop();
                    },
                  );
                });
          }

          onActionAlbum(Album album) {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: 100,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text("Delete"),
                          onTap: () {
                            Navigator.of(context).pop();
                            onOpenDeleteAlbumDialog(album.id!);
                          },
                        )
                      ],
                    ),
                  );
                });
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<SourceBloc>().add(RefreshDeviceAlbumEvent());
                context.read<SourceBloc>().add(LoadAlbumEvent(force: true));
                context.read<SourceBloc>().add(LoadLibraryEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: 8,
                                ),
                                child: Text(
                                  "Album on device",
                                  style: Theme.of(context).textTheme.titleSmall,
                                )),
                          ),
                          TextButton(
                              onPressed: () {
                                TabLocalImage.Launch(context);
                              },
                              child: const Text("More"))
                        ],
                      ),
                      // for (var album in state.albums) Text(album.name),
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: state.albums.length,
                          itemBuilder: (context, index) {
                            var album = state.albums[index];
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        LocalAlbumPage.Launch(context, album);
                                      },
                                      child: FutureBuilder<Uint8List?>(
                                        future: getAlbumThumb(album),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<Uint8List?>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              snapshot.hasData) {
                                            return Container(
                                              width: 120,
                                              margin: const EdgeInsets.only(
                                                  right: 16),
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: MemoryImage(
                                                      snapshot.data!),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            );
                                          } else {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  right: 16),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: 64,
                                      width: 120,
                                      child: Text(album.name, maxLines: 1)),
                                ],
                              ),
                            );
                          },
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                      Text(
                        "Libraries",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: state.libraryList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => CreateLibraryDialog(
                                            onConfirm: (libraryName) {
                                              onCreateLibrary(libraryName);
                                            },
                                          ));
                                },
                                child: Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 120,
                                        height: 64,
                                        child: Text("Create new"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            var library = state.libraryList[index - 1];
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.photo_album,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width: 120,
                                      height: 64,
                                      child: Text(library.displayName,
                                          maxLines: 1)),
                                ],
                              ),
                            );
                          },
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                      Text(
                        "Albums",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      GridView.builder(
                        controller: controller,
                        shrinkWrap: true,
                        // Add this line
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.albumList.length + 1,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: getRowItemCount(),
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // If index is 0, return the new button
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CreateAlbumDialog(
                                          onCreateAlbum: (name) {
                                        onCreateAlbum(name);
                                        Navigator.of(context).pop();
                                      });
                                    });
                              },
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      child: const Text(
                                        "Create new",
                                        maxLines: 1,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                          index -= 1;
                          Album album = state.albumList[index];
                          return GestureDetector(
                            child: Container(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: album.thumbnailUrl != null
                                          ? Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      album.thumbnailUrl!),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            )
                                          : Icon(
                                              Icons.photo_album,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              size: 48,
                                            ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      album.displayName,
                                      maxLines: 1,
                                    ),
                                  )
                                ])),
                            onTap: () {
                              AlbumDetailView.Launch(
                                  context, state.albumList[index]);
                            },
                            onLongPress: () {
                              onActionAlbum(state.albumList[index]);
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ));
  }
}
