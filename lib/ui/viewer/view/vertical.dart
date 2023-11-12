import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:youphotomobile/ui/components/AlbumSelectView.dart';
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

    return BlocBuilder<ViewerBloc, ViewerState>(
      builder: (context, state) {
        void onAddImageToAlbum(int albumId,int imageId) {
          context.read<ViewerBloc>().add(AddToAlbumEvent(albumId: albumId,imageIds: [imageId]));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to album')));
        }
        var currentPhotoItem = state.photos[state.current];
        var controller = PageController(
          initialPage: state.current,
        );
        Widget _buildListItem(BuildContext context, int index) {
          //horizontal
          var thumbnail = NetworkImage(state.photos[index].thumbnailUrl);
          return Container(
            child: PhotoView(
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
          );
        }

        return Row(
          children: [
            Expanded(
                child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: state.showUI
                  ? AppBar(
                      title: Text(
                        '${state.photos[state.current].name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            if (await Permission.storage.request().isGranted) {
                              var response = await Dio().get(
                                  state.photos[state.current].rawUrl,
                                  options: Options(
                                      responseType: ResponseType.bytes));
                              try {
                                await ImageGallerySaver.saveImage(
                                    Uint8List.fromList(response.data),
                                    quality: 60,
                                    name: state.photos[state.current].name);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saved')));
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Error saving image'),
                                ));
                              }
                            }
                          },
                        ),
                        PopupMenuButton<String>(icon: Icon(Icons.more_vert), onSelected: (value) {
                          if (value == "addToAlbum") {
                            showModalBottomSheet(context: context, builder: (context) {
                              return AlbumSelectView(
                                onSelect: (album) {
                                  onAddImageToAlbum(album.id!,state.photos[state.current].id!);
                                }
                              );
                            });
                          }
                        }, itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              value: "addToAlbum",
                              child: Text('Add to album'),
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
              body: Stack(
                children: [
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: PageView.builder(
                            allowImplicitScrolling: true,
                            onPageChanged: (index) {
                              print(index);
                              print("update");
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
            isFolderDevice
                ? Container(
                    color: Theme.of(context).colorScheme.background,
                    padding: EdgeInsets.only(top: 48,left: 16,right: 16),
                    width: getHalfScreenLength(context),
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text("Name",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                            alignment: Alignment.centerLeft,
                          ),
                          Container(
                            child: Text(currentPhotoItem.name??"",style: TextStyle(fontSize: 16),),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(bottom: 16),
                          ),
                          Container(
                            child: Text("Tags",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
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
                            child: Text("Color",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                            alignment: Alignment.centerLeft,
                          ),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: currentPhotoItem.imageColors.map((item) {
                              return Container(
                                width: 96,
                                decoration: BoxDecoration(
                                    color: Color(int.parse(item.value!.replaceAll('#', '0xFF') )),
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                padding: EdgeInsets.all(8),

                                child: Column(
                                children: [
                                  Text(item.value ?? "",style: TextStyle(color: getTextColor(item.value!)),),
                                  Text((item.percent! * 100).toStringAsFixed(2) + "%",style: TextStyle(color: getTextColor(item.value!))),
                                ],
                              ),);
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  )
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
