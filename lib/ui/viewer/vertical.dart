import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:photo_view/photo_view.dart';
import 'package:youphotomobile/api/image.dart';

class ImageViewerVertical extends StatefulWidget {
  final PhotoLoader loader;
  final int initIndex;

  const ImageViewerVertical(
      {Key? key, required this.loader, required this.initIndex})
      : super(key: key);

  @override
  State<ImageViewerVertical> createState() => _ImageViewerVerticalState();
}

class _ImageViewerVerticalState extends State<ImageViewerVertical> {
  int total = 0;
  int current = 0;
  bool showUI = true;

  @override
  void initState() {
    super.initState();
    total = widget.loader.list.length;
    current = widget.initIndex;
  }

  Widget _buildListItem(BuildContext context, int index) {
    //horizontal
    return Container(
      color: Colors.black,
      child: Container(
          child: PhotoView(
        heroAttributes: PhotoViewHeroAttributes(
          tag: "imageHero_${widget.loader.list[index].id}",
        ),
        minScale: PhotoViewComputedScale.contained,
        imageProvider: NetworkImage(
          widget.loader.list[index].rawUrl,
        ),
        onTapDown: (
          BuildContext context,
          TapDownDetails details,
          PhotoViewControllerValue controllerValue,
        ) {},
        loadingBuilder: (context, progress) {
          return Hero(tag: "imageHero_${widget.loader.list[index].id}", child: Image.network(
            widget.loader.list[index].thumbnailUrl,
            fit: BoxFit.contain,
          ));
        },
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    var controller = PageController(
      initialPage: widget.initIndex,
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: showUI
          ? AppBar(
              title: Text(
                '${widget.loader.list[current].name}',
                style: const TextStyle(fontSize: 18),
              ),
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
                    allowImplicitScrolling: false,
                    onPageChanged: (index) {
                      setState(() {
                        current = index;
                      });
                      if (index == total - 1) {
                        widget.loader.loadMore().then((value) {
                          setState(() {
                            total = widget.loader.list.length;
                          });
                        });
                      }
                    },
                    controller: controller,
                    itemBuilder: _buildListItem,
                    itemCount: total,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
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
