import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

typedef OnAlbumSelected = Function(String? albumName);

class LocalAlbumSelectView extends StatefulWidget {
  final OnAlbumSelected onAlbumSelected;

  LocalAlbumSelectView({required this.onAlbumSelected});

  @override
  _LocalAlbumSelectViewState createState() => _LocalAlbumSelectViewState();
}

class _LocalAlbumSelectViewState extends State<LocalAlbumSelectView> {
  late Future<List<AssetPathEntity>> _albumList;
  String? inputNewAlbumName;
  String? newAlbumName;
  @override
  void initState() {
    super.initState();
    _albumList = PhotoManager.getAssetPathList(onlyAll: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          height: 50,
          child: const Center(
            child: Text(
              'Select album',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        ListTile(
          title: Text("Directly save to gallery"),
          onTap: () => widget.onAlbumSelected(null),
          leading: Icon(Icons.download),
        ),
        newAlbumName != null ? ListTile(
          title: Text(newAlbumName!),
          onTap: () => widget.onAlbumSelected(newAlbumName!),
          leading: Icon(Icons.add_photo_alternate_outlined),
        ):Container(),
        ListTile(
          title: Text('Create new album'),
          leading: Icon(Icons.add),
          onTap: () => {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Create new album'),
                    content: TextField(
                      onChanged: (value) {
                        inputNewAlbumName = value;
                      },
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () async {
                            setState(() {
                              newAlbumName = inputNewAlbumName;
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'))
                    ],
                  );
                })
          }
        ),
        Expanded(
          child: FutureBuilder<List<AssetPathEntity>>(
            future: _albumList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.error != null) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].name),
                      onTap: () => widget.onAlbumSelected(snapshot.data![index].name),
                      leading: Icon(Icons.photo_album),
                    );
                  },
                );
              }
            },
          ),
        )
      ],
    );
  }
}