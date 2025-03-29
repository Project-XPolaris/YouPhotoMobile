import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_view/photo_view.dart';

class LocalImageViewer extends StatefulWidget {
  final AssetEntity entity;

  const LocalImageViewer({super.key, required this.entity});

  static Launch(BuildContext context, AssetEntity entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocalImageViewer(entity: entity),
      ),
    );
  }

  @override
  State<LocalImageViewer> createState() => _LocalImageViewerState();
}

class _LocalImageViewerState extends State<LocalImageViewer> {
  String title  = "Image";

  @override
  void initState() {
    super.initState();
    setTitle();
  }

  void setTitle() async {
    var assetTitle = widget.entity.title;
    if (assetTitle != null && assetTitle.isNotEmpty) {
      setState(() {
        title = assetTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        child: FutureBuilder<Uint8List?>(
          future: widget.entity.originBytes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error'),
                );
              }
              if (snapshot.hasData) {
                return PhotoView(minScale: PhotoViewComputedScale.contained,imageProvider: MemoryImage(snapshot.data!),);
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
