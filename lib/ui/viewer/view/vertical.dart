import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:youphotomobile/ui/viewer/bloc/viewer_bloc.dart';

class ImageViewerVertical extends StatelessWidget {
  final Function(int) onIndexChange;
  const ImageViewerVertical({Key? key,required this.onIndexChange}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewerBloc, ViewerState>(
      builder: (context, state) {
        var controller = PageController(
          initialPage: state.current,
        );
        Widget _buildListItem(BuildContext context, int index) {
          //horizontal
          var thumbnail  = NetworkImage(state.photos[index].thumbnailUrl);
          return Container(
            child: PhotoView(
              minScale: PhotoViewComputedScale.contained,
              imageProvider: NetworkImage(
                state.photos[index].rawUrl,
              ),
              loadingBuilder: (context, progress) {
                return Hero(
                  tag: "photo_${state.photos[index].id}",
                  child: Image(
                    image: thumbnail,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          );
        }
        return Scaffold(
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
                        options: Options(responseType: ResponseType.bytes));
                    try {
                      await ImageGallerySaver.saveImage(
                          Uint8List.fromList(response.data),
                          quality: 60,
                          name: state.photos[state.current].name);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved')));
                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Error saving image'),
                      ));
                    }


                  }
                },
              ),
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
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: PageView.builder(
                        allowImplicitScrolling: true,
                        onPageChanged: (index) {
                          onIndexChange(index);
                          context.read<ViewerBloc>().add(
                              IndexChangedEvent(index: index)
                          );
                          if (index == state.total - 1) {
                            context.read<ViewerBloc>().add(
                              LoadMoreEvent()
                            );

                          }
                        },
                        controller: controller,
                        itemBuilder: _buildListItem,
                        itemCount: state.total,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
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
  SpringDescription get spring =>
      const SpringDescription(
        mass: 500,
        stiffness: 1000,
        damping: 0.8,
      );
}
