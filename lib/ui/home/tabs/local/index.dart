import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:youphotomobile/ui/localalbum/view.dart';

class TabLocalImage extends StatefulWidget {
  @override
  _TabLocalImageState createState() => _TabLocalImageState();
}

class _TabLocalImageState extends State<TabLocalImage> {
  List<AssetPathEntity> _albums = [];

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      if (albums.isNotEmpty) {
        setState(() {
          _albums = albums;
        });
      }
    }else{
      print("没有权限");
    }

  }
  Future<Uint8List?> getAlbumThumb(AssetPathEntity entity) async {
    final AssetEntity? asset = await entity.getAssetListRange(start: 0, end: 1).then((value) => value.first);
    if (asset != null) {
      return await asset.thumbnailDataWithSize(ThumbnailSize(200, 200));
    }
    return null;
  }
  void refresh() {
    setState(() {
      _fetchPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(

        children: _albums.map((album) {
          return ListTile(
            title: Text(album.name),
            leading: FutureBuilder<Uint8List?>(
              future: getAlbumThumb(album),
              builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(snapshot.data!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                } else {
                  return Container(
                    width: 64,
                    height: 64,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  );
                }
              },
            ),
            subtitle: FutureBuilder(
              future: album.assetCountAsync,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  return Text("${snapshot.data} assets");
                } else {
                  return Container();
                }
              },
            ),
            onTap: () {
              LocalAlbumPage.Launch(context, album);
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          refresh();
        },
        child: Icon(Icons.refresh),
        heroTag: "tablocal",
      )
    );
  }
}