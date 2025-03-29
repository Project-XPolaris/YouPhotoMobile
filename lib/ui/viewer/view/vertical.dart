
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:youphotomobile/ui/components/AlbumSelectView.dart';
import 'package:youphotomobile/ui/components/LocalAlbumSelectView.dart';
import 'package:youphotomobile/ui/components/Minmap.dart';
import 'package:youphotomobile/ui/upscale/upscale.dart';
import 'package:youphotomobile/ui/viewer/bloc/viewer_bloc.dart';
import 'package:youphotomobile/util/color.dart';
import 'dart:io' show Platform;
import '../../../util/screen.dart';

class ImageViewerVertical extends StatelessWidget {
  final Function(int) onIndexChange;

  const ImageViewerVertical({Key? key, required this.onIndexChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isFolderDevice = checkFoldableDevice(context);
    final GlobalKey<ScaffoldState> _scaffoldKey =
        GlobalKey<ScaffoldState>();
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
            child: Container(
              color: state.showUI
                  ? Theme.of(context).colorScheme.surface
                  : Colors.black,
              child: PhotoView(
                backgroundDecoration: BoxDecoration(
                  color: state.showUI
                      ? Theme.of(context).colorScheme.surface
                      : Colors.black,
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
                onTapUp: (context, details, controllerValue) {
                  if (state.showUI) {
                    context
                        .read<ViewerBloc>()
                        .add(const SwitchUIEvent(showUI: false));
                  } else {
                    context.read<ViewerBloc>().add(const SwitchUIEvent(showUI: true));
                  }
                },
                scaleStateChangedCallback: (value) {
                  if (value != PhotoViewScaleState.initial) {
                    context
                        .read<ViewerBloc>()
                        .add(const SwitchUIEvent(showUI: false));
                  }
                },
              ),
            ),
          );
        }

        Widget imageInfoPanel = Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 16),
          width: getHalfScreenLength(context),
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: const Text(
                    "Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Container(
                  child: Text(
                    currentPhotoItem.name ?? "",
                    style: const TextStyle(fontSize: 16),
                  ),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                Container(
                  child: const Text(
                    "Resolution",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    currentPhotoItem.width.toString() +
                        " x " +
                        currentPhotoItem.height.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Builder(builder: (context) {
                  var lat = currentPhotoItem.lat;
                  var lng = currentPhotoItem.lng;
                  if (lat != null && lng != null) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Location",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8)),
                            width: double.infinity,
                            height: 200,
                            child: MiniMap(photoLocation: LatLng(lat, lng))),
                        Text(currentPhotoItem.address ?? "",
                            style: const TextStyle(fontSize: 16)),
                      ],
                    );
                  }
                  return Container();
                }),
                Builder(builder: (context) {
                  if (currentPhotoItem.tag.isNotEmpty) {
                    return Column(
                      children: [
                        Container(
                          child: const Text(
                            "Tags",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        Wrap(
                          spacing: 4,
                          children: currentPhotoItem.tag.map((item) {
                            return Chip(
                              padding: const EdgeInsets.all(2),
                              label: Text(item.tag ?? ""),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }
                  return Container();
                }),
                Builder(builder: (context) {
                  if (currentPhotoItem.imageColors.isNotEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: const Text(
                            "Color",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
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
                                  color: Color(int.parse(
                                      item.value!.replaceAll('#', '0xFF'))),
                                  borderRadius: BorderRadius.circular(4)),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(
                                    item.value ?? "",
                                    style: TextStyle(
                                        color: getTextColor(item.value!)),
                                  ),
                                  Text(
                                      (item.percent! * 100).toStringAsFixed(2) +
                                          "%",
                                      style: TextStyle(
                                          color: getTextColor(item.value!))),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    );
                  }
                  return Container();
                }),
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
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == "upscale") {
                              UpscaleView.launch(context,currentPhotoItem);
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem(
                                value: "upscale",
                                child: Text('Upscale'),
                              ),
                            ];
                          },
                        )
                      ],
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.5),
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
                  ? SizedBox(
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
                                context.read<ViewerBloc>().add(const LoadMoreEvent());
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
                  ),
                  state.showUI
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withOpacity(0.0),
                                  Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withOpacity(1),
                                ],
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: GestureDetector(
                                    onTap: () {
                                      var screenWidth =
                                          MediaQuery.of(context).size.width;

                                      if (screenWidth > 600) {
                                        var switchToViewMode =
                                            state.viewMode == "auto"
                                                ? "fixed"
                                                : "auto";
                                        context.read<ViewerBloc>().add(
                                            SwitchViewModeEvent(
                                                viewMode: switchToViewMode));
                                        return;
                                      }
                                      print(screenWidth);
                                      _scaffoldKey.currentState!
                                          .openEndDrawer();
                                    },
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.info_rounded,
                                          size: 32,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                        // Text(
                                        //   "Info",
                                        //   style: TextStyle(
                                        //       color: Theme.of(context)
                                        //           .colorScheme
                                        //           .onSurface),
                                        // )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 32,
                                ),
                                Container(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (await Permission.storage
                                          .request()
                                          .isGranted) {
                                        var response = await Dio().get(
                                            currentPhotoItem.rawUrl,
                                            options: Options(
                                                responseType:
                                                    ResponseType.bytes));
                                        if (Platform.isIOS) {
                                          try {
                                            await SaverGallery.saveImage(
                                                Uint8List.fromList(
                                                    response.data),
                                                quality: 100,
                                                fileName: currentPhotoItem.name!,
                                                skipIfExists: false
                                            );
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
                                          return;
                                        }

                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                padding: const EdgeInsets.all(16),
                                                child: LocalAlbumSelectView(
                                                  onAlbumSelected: (String?
                                                      albumName) async {
                                                    Navigator.of(context).pop();
                                                    var saveRelativePath =
                                                        "Pictures";
                                                    if (albumName != null) {
                                                      saveRelativePath =
                                                          "Pictures/" +
                                                              albumName;
                                                    }
                                                    try {
                                                      await SaverGallery.saveImage(
                                                          Uint8List.fromList(
                                                              response.data),
                                                          quality: 100,
                                                          fileName: currentPhotoItem
                                                              .name!,
                                                          androidRelativePath:
                                                              saveRelativePath,
                                                          skipIfExists:
                                                              false);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Saved')));
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        content: Text(
                                                            'Error saving image'),
                                                      ));
                                                    }
                                                  },
                                                ),
                                              );
                                            });
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Icon(Icons.download_rounded,
                                            size: 32,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        // Text("Download",
                                        //     style: TextStyle(
                                        //         color: Theme.of(context)
                                        //             .colorScheme
                                        //             .onSurface))
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 32,
                                ),
                                Container(
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return AlbumSelectView(
                                                onSelect: (album) {
                                              onAddImageToAlbum(album.id!,
                                                  currentPhotoItem.id!);
                                            });
                                          });
                                    },
                                    child: Column(
                                      children: [
                                        Icon(Icons.photo_album_rounded,
                                            size: 32,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        // Text("Add to album",
                                        //     style: TextStyle(
                                        //         color: Theme.of(context)
                                        //             .colorScheme
                                        //             .onSurface))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container()
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
