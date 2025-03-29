import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

typedef OnAlbumSelected = Function(String? albumName);

class LocalAlbumSelectView extends StatefulWidget {
  final OnAlbumSelected onAlbumSelected;

  const LocalAlbumSelectView({super.key, required this.onAlbumSelected});

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
          margin: const EdgeInsets.only(bottom: 10),
          height: 50,
          child: const Center(
            child: Text(
              'Select album',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        ListTile(
          title: const Text("Directly save to gallery"),
          onTap: () => widget.onAlbumSelected(null),
          leading: const Icon(Icons.download),
        ),
        newAlbumName != null ? ListTile(
          title: Text(newAlbumName!),
          onTap: () => widget.onAlbumSelected(newAlbumName!),
          leading: const Icon(Icons.add_photo_alternate_outlined),
        ):Container(),
        ListTile(
          title: const Text('Create new album'),
          leading: const Icon(Icons.add),
          onTap: () => {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Create new album'),
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
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () async {
                            setState(() {
                              newAlbumName = inputNewAlbumName;
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'))
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
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.error != null) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].name),
                      onTap: () => widget.onAlbumSelected(snapshot.data![index].name),
                      leading: const Icon(Icons.photo_album),
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