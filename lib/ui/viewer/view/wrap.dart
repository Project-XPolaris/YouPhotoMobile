import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/api/image.dart';
import 'package:youphotomobile/ui/components/ScreenWidthSelector.dart';
import 'package:youphotomobile/ui/viewer/bloc/viewer_bloc.dart';
import 'package:youphotomobile/ui/viewer/view/vertical.dart';

class ImageViewer extends StatelessWidget {
  final List<Photo> photos;
  final Function(int) onIndexChange;
  final int initIndex;

  const ImageViewer(
      {Key? key,
      required this.photos,
      required this.onIndexChange,
      required this.initIndex})
      : super(key: key);

  static Launch(BuildContext context, List<Photo> photos, int initIndex,
      Function(int) onIndexChange) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageViewer(
                  photos: photos,
                  initIndex: initIndex,
                  onIndexChange: onIndexChange,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewerBloc(photos: photos, current: initIndex)
        ..add(IndexChangedEvent(index: initIndex)),
      child: Scaffold(
        body: ScreenWidthSelector(
          verticalChild: ImageViewerVertical(
            onIndexChange: onIndexChange,
          ),
        ),
      ),
    );
  }
}
