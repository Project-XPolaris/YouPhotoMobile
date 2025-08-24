import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:youphotomobile/ui/bloc/app_bloc.dart';
import 'package:youphotomobile/ui/components/LibrarySelectView.dart';
import 'package:youphotomobile/ui/localalbum/bloc/local_album_bloc.dart';
import 'package:youphotomobile/ui/localalbum/viewer.dart';
import 'package:uuid/uuid.dart';

import '../../api/library.dart';

class LocalAlbumPage extends StatefulWidget {
  final AssetPathEntity entity;

  const LocalAlbumPage({Key? key, required this.entity}) : super(key: key);

  @override
  _LocalAlbumPageState createState() => _LocalAlbumPageState();

  static Launch(BuildContext context, AssetPathEntity entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocalAlbumPage(entity: entity),
      ),
    );
  }
}

class _LocalAlbumPageState extends State<LocalAlbumPage> {
  @override
  Widget build(BuildContext context) {
    // app bloc builder
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return BlocProvider(
          create: (context) => LocalAlbumBloc(entity: widget.entity)
            ..add(const LoadAssetsEvent()),
          child: BlocBuilder<LocalAlbumBloc, LocalAlbumState>(
            builder: (context, state) {
              const double itemWidth =
                  110; // Change this to the desired width of each grid item
              final double screenWidth = MediaQuery.of(context).size.width;
              final int crossAxisCount = (screenWidth / itemWidth).floor();
              getImageFit() {
                switch (context.read<LocalAlbumBloc>().state.imageFit) {
                  case "cover":
                    return BoxFit.cover;
                  case "contain":
                    return BoxFit.contain;
                  default:
                    return BoxFit.cover;
                }
              }

              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.entity.name),
                  actions: [
                    PopupMenuButton<String>(
                        icon: const Icon(Icons.apps),
                        onSelected: (value) {
                          context
                              .read<LocalAlbumBloc>()
                              .add(UpdateImageFitEvent(imageFit: value));
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: "cover",
                              child: Text('Cover'),
                            ),
                            const PopupMenuItem(
                              value: "contain",
                              child: Text('Contain'),
                            ),
                          ];
                        }),
                    PopupMenuButton(itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          child: Text("Upload to library"),
                          value: "upload",
                        )
                      ];
                    }, onSelected: (value) {
                      switch (value) {
                        case "upload":
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext modalContext) {
                                return BlocProvider.value(
                                    value: context.read<LocalAlbumBloc>(),
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 16,
                                          left: 16,
                                          right: 16,
                                          bottom: 16),
                                      child: LibrarySelectView(
                                        onSelected: (
                                            {required Library library}) {
                                          context.read<AppBloc>().add(
                                              AddSyncTaskEvent(
                                                  task: SyncTask(
                                                      type: 'upload',
                                                      data: {
                                                        'entity': widget.entity,
                                                        'assets': state.assets,
                                                        'libraryId': library.id!
                                                      },
                                                      id: const Uuid().v4(),
                                                      createdAt:
                                                          DateTime.now())));
                                          // context.read<LocalAlbumBloc>().add(
                                          //     UploadToLibraryEvent(
                                          //         libraryId: library.id!));
                                        },
                                      ),
                                    ));
                              });
                          break;
                      }
                    })
                  ],
                ),
                body: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: state.assets.length,
                  itemBuilder: (context, index) {
                    var item = state.assets[index];
                    return FutureBuilder<Uint8List?>(
                      future: item.thumbnailData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return GestureDetector(
                            onTap: () {
                              LocalImageViewer.Launch(context, item);
                            },
                            child: Image.memory(
                              snapshot.data!,
                              fit: getImageFit(),
                            ),
                          );
                        } else {
                          return Container(); // Placeholder or loading indicator can be added here
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
