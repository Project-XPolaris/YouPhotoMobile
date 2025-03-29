
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:youphotomobile/ui/localalbum/view.dart';

class TabLocalImage extends StatefulWidget {
  const TabLocalImage({super.key});

  @override
  _TabLocalImageState createState() => _TabLocalImageState();

  static Launch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TabLocalImage()),
    );
  }
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
    } else {
      print("没有权限");
    }
  }

  Future<Uint8List?> getAlbumThumb(AssetPathEntity entity) async {
    final AssetEntity? asset = await entity
        .getAssetListRange(start: 0, end: 1)
        .then((value) => value.first);
    if (asset != null) {
      return await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
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
    itemCount() {
      const double itemWidth = 120;
      final double screenWidth = MediaQuery.of(context).size.width;
      return (screenWidth / itemWidth).floor();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Album on device"),
      ),
        body: Builder(
          builder: (context) {
            return Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _albums.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: itemCount(),
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemBuilder: (context, index) {
                    var album = _albums[index];
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                LocalAlbumPage.Launch(context, album);
                              },
                              child: FutureBuilder<Uint8List?>(
                                future: getAlbumThumb(album),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Uint8List?> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done &&
                                      snapshot.hasData) {
                                    return Container(
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
                                      color:
                                      Theme.of(context).colorScheme.primaryContainer,
                                    );

                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 64,
                              child: Text(album.name,maxLines: 3)),
                        ],
                      ),
                    );
                  },
                  ),
            );
            return ListView(
              children: _albums.map((album) {

                return ListTile(
                  title: Text(album.name),
                  leading: FutureBuilder<Uint8List?>(
                    future: getAlbumThumb(album),
                    builder:
                        (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
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
            );
          }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            refresh();
          },
          child: const Icon(Icons.refresh),
          heroTag: "tablocal",
        ));
  }
}
