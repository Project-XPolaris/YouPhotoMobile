import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:youphotomobile/ui/components/AlbumSelectView.dart';
import 'package:youphotomobile/ui/components/LocalAlbumSelectView.dart';
import 'package:youphotomobile/ui/viewer/bloc/viewer_bloc.dart';
import 'package:youphotomobile/util/color.dart';

import '../../../util/screen.dart';

class ImageViewerVertical extends StatelessWidget {
  final Function(int) onIndexChange;

  const ImageViewerVertical({Key? key, required this.onIndexChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isFolderDevice = checkFoldableDevice(context);
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();
    return BlocBuilder<ViewerBloc, ViewerState>(
      builder: (context, state) {
        void onAddImageToAlbum(int albumId, int imageId) {
          context
              .read<ViewerBloc>()
              .add(AddToAlbumEvent(albumId: albumId, imageIds: [imageId]));
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Added to album')));
        }
        var currentPhotoItem = state.currentPhoto;
        var controller = PageController(
          initialPage: state.current,
        );
        Widget _buildListItem(BuildContext context, int index) {
          //horizontal
          var thumbnail = NetworkImage(state.photos[index].thumbnailUrl);
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity!.compareTo(0) == -1) {
                controller.nextPage(
                    duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
              } else if (details.primaryVelocity!.compareTo(0) == 1) {
                controller.previousPage(
                    duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
              }
            },
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: PhotoView(
                backgroundDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                ),
                minScale: PhotoViewComputedScale.contained,
                imageProvider: NetworkImage(
                  state.photos[index].rawUrl,
                ),
                loadingBuilder: (context, progress) {
                  return Image(
                    image: thumbnail,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          );
        }

        Widget imageInfoPanel = Container(
          color: Theme.of(context).colorScheme.background,
          padding: EdgeInsets.only(top: 48, left: 16, right: 16),
          width: getHalfScreenLength(context),
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    "Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Container(
                  child: Text(
                    currentPhotoItem.name ?? "",
                    style: TextStyle(fontSize: 16),
                  ),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(bottom: 16),
                ),
                Container(
                  child: Text(
                    "Tags",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Wrap(
                  spacing: 4,
                  children: currentPhotoItem.tag.map((item) {
                    return Chip(
                      padding: EdgeInsets.all(2),
                      label: Text(item.tag ?? ""),
                    );
                  }).toList(),
                ),
                Container(
                  child: Text(
                    "Color",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: currentPhotoItem.imageColors.map((item) {
                    return Container(
                      width: 96,
                      decoration: BoxDecoration(
                          color: Color(
                              int.parse(item.value!.replaceAll('#', '0xFF'))),
                          borderRadius: BorderRadius.circular(4)),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            item.value ?? "",
                            style: TextStyle(color: getTextColor(item.value!)),
                          ),
                          Text((item.percent! * 100).toStringAsFixed(2) + "%",
                              style:
                                  TextStyle(color: getTextColor(item.value!))),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        );

        return Row(
          children: [
            Expanded(
                child: Scaffold(
              key: _scaffoldKey,
              extendBodyBehindAppBar: true,
              appBar: state.showUI
                  ? AppBar(
                      title: Text(
                        '${currentPhotoItem.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      actions: [
                        IconButton(
                            onPressed: () {
                              _scaffoldKey.currentState!.openEndDrawer();
                            },
                            icon: const Icon(Icons.info_outline)),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            if (await Permission.storage.request().isGranted) {
                              var response = await Dio().get(
                                  currentPhotoItem.rawUrl,
                                  options: Options(
                                      responseType: ResponseType.bytes));
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      padding: EdgeInsets.all(16),
                                      child: LocalAlbumSelectView(
                                        onAlbumSelected:
                                            (String? albumName) async {
                                          Navigator.of(context).pop();
                                          var saveRelativePath = "Pictures";
                                          if (albumName != null) {
                                            saveRelativePath =
                                                "Pictures/" + albumName;
                                          }
                                          try {
                                            await SaverGallery.saveImage(
                                                Uint8List.fromList(
                                                    response.data),
                                                quality: 100,
                                                name: currentPhotoItem.name!,
                                                androidRelativePath:
                                                    saveRelativePath,
                                                androidExistNotSave: false);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text('Saved')));
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Error saving image'),
                                            ));
                                          }
                                        },
                                      ),
                                    );
                                  });
                            }
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == "addToAlbum") {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return AlbumSelectView(onSelect: (album) {
                                      onAddImageToAlbum(
                                          album.id!, currentPhotoItem.id!);
                                    });
                                  });
                            }
                            if (value == "viewModeAuto") {
                              context
                                  .read<ViewerBloc>()
                                  .add(SwitchViewModeEvent(viewMode: "auto"));
                            }
                            if (value == "viewModeFixed") {
                              context
                                  .read<ViewerBloc>()
                                  .add(SwitchViewModeEvent(viewMode: "fixed"));
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem(
                                value: "addToAlbum",
                                child: Text('Add to album'),
                              ),
                              PopupMenuDivider(),
                              const PopupMenuItem(
                                value: "viewModeAuto",
                                child: Text('Auto Layout'),
                              ),
                              const PopupMenuItem(
                                value: "viewModeFixed",
                                child: Text('Fixed Layout'),
                              ),
                            ];
                          },
                        )
                      ],
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  : null,
              endDrawer: (state.viewMode == "fixed" || !isFolderDevice)
                  ? Container(
                      width: MediaQuery.of(context).size.width - 64,
                      child: imageInfoPanel)
                  : null,
              body: Stack(
                children: [
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: PageView.builder(
                            allowImplicitScrolling: true,
                            onPageChanged: (index) {
                              context
                                  .read<ViewerBloc>()
                                  .add(IndexChangedEvent(index: index));
                              if (index == state.total - 1) {
                                context.read<ViewerBloc>().add(LoadMoreEvent());
                              }
                              onIndexChange(index);
                            },
                            controller: controller,
                            itemBuilder: _buildListItem,
                            itemCount: state.total,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
            isFolderDevice && state.viewMode == "auto"
                ? imageInfoPanel
                : Container()
          ],
        );
      },
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 500,
        stiffness: 1000,
        damping: 0.8,
      );
}
