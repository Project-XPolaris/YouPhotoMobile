import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  final String viewMode;
  const ImageGrid({Key? key,this.viewMode = "medium"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          int crossAxisCount = (constraints.maxWidth / 130).round();
          switch (viewMode) {
            case "large":
              crossAxisCount = (constraints.maxWidth / 170).round();
              break;
            case "medium":
              crossAxisCount = (constraints.maxWidth / 130).round();
              break;
            case "small":
              crossAxisCount = (constraints.maxWidth / 100).round();
              break;
          }
//      height: constraints.maxHeight,
//      width: constraints.maxWidth
          return Container();
        });
  }
}
