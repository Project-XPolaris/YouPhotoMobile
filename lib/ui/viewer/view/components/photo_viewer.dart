import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:youphotomobile/config.dart';
import 'package:youphotomobile/ui/components/OfflinePhotoView.dart';
import 'package:youphotomobile/ui/viewer/bloc/viewer_bloc.dart';

class PhotoViewer extends StatefulWidget {
  final String rawUrl;
  final String thumbnailUrl;
  final bool showUI;
  final int id;
  final Function(bool) onUISwitch;

  const PhotoViewer(
      {Key? key,
      required this.rawUrl,
      required this.thumbnailUrl,
      required this.showUI,
      required this.onUISwitch,
      required this.id})
      : super(key: key);

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: widget.showUI
            ? Theme.of(context).colorScheme.surface
            : Colors.black,
        child: PhotoView(
          backgroundDecoration: BoxDecoration(
            color: widget.showUI
                ? Theme.of(context).colorScheme.surface
                : Colors.black,
          ),
          minScale: PhotoViewComputedScale.contained,
          imageProvider: NetworkImage(widget.rawUrl),
          loadingBuilder: (context, progress) {
            return OfflineAwareImage(
              imageUrl: widget.thumbnailUrl,
              photoId: widget.id,
              isOffline: ApplicationConfig().isOffline,
              fit: BoxFit.contain,
              showAnimated: false,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return OfflineAwareImage(
              imageUrl: widget.thumbnailUrl,
              photoId: widget.id,
              isOffline: ApplicationConfig().isOffline,
              fit: BoxFit.contain,
              showAnimated: false,
            );
          },
          onTapUp: (context, details, controllerValue) {
            widget.onUISwitch(!widget.showUI);
          },
          scaleStateChangedCallback: (value) {
            if (value != PhotoViewScaleState.initial) {
              widget.onUISwitch(false);
            }
          },
        ),
      ),
    );
  }
}
