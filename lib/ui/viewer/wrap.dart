import 'package:flutter/material.dart';
import 'package:youphotomobile/api/image.dart';
import 'package:youphotomobile/ui/components/ScreenWidthSelector.dart';
import 'package:youphotomobile/ui/viewer/vertical.dart';

class ImageViewer extends StatelessWidget {
  final PhotoLoader photoLoader;
  final int initIndex;
  const ImageViewer({Key? key, required this.photoLoader,required this.initIndex}) : super(key: key);
  static Launch(BuildContext context,PhotoLoader photoLoader, int initIndex) {
    return Navigator.push(
      context,
        MaterialPageRoute(builder: (context) => ImageViewer(photoLoader: photoLoader, initIndex: initIndex))
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenWidthSelector(
        verticalChild: ImageViewerVertical(
          loader: photoLoader,
          initIndex: initIndex,
        ),
      ),
    );
  }
}
