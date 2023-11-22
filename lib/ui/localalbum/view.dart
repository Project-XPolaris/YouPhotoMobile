import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalAlbumPage extends StatefulWidget {
  final AssetPathEntity entity;
  const LocalAlbumPage({Key? key, required this.entity}) : super(key: key);
  @override
  _LocalAlbumPageState createState() => _LocalAlbumPageState();

  static Launch(BuildContext context, AssetPathEntity entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocalAlbumPage(entity: entity),
      ),
    );
  }
}

class _LocalAlbumPageState extends State<LocalAlbumPage> {
  List<AssetEntity> _assets = [];

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
    if (albums.isNotEmpty) {
      List<AssetEntity> assets = await widget.entity.getAssetListRange(start: 0, end: 1000000);
      setState(() {
        _assets = assets;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entity.name),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _assets.length,
        itemBuilder: (context, index) {
          return FutureBuilder<Uint8List?>(
            future: _assets[index].thumbnailData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              } else {
                return Container(); // Placeholder or loading indicator can be added here
              }
            },
          );
        },
      ),
    );
  }
}