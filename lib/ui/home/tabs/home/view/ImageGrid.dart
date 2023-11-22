import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youphotomobile/api/image.dart';

class ImageGrid extends StatefulWidget {
  final Photo image;

  ImageGrid({required this.image});

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  var isTriggered = false;
  @override
  Widget build(BuildContext context) {
    if (isTriggered) {
      return CachedNetworkImage(
        imageUrl: widget.image.thumbnailUrl,
        errorWidget: (context, url, error) => Icon(Icons.error),
        fit: BoxFit.cover,
      );
    }
    return VisibilityDetector(
      key: Key(widget.image.id!.toString()),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction != 0) {
          setState(() {
            isTriggered = true;
          });
        } else {}
      },
      child: Builder(builder: (context) {
        return Container(
          color: Theme.of(context).colorScheme.primaryContainer// Placeholder for items not in view
        );
      }),
    );
  }
}
