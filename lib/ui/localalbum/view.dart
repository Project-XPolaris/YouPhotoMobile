import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:youphotomobile/ui/components/LibrarySelectView.dart';
import 'package:youphotomobile/ui/localalbum/bloc/local_album_bloc.dart';

import '../../api/library.dart';

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
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
  create: (context) => LocalAlbumBloc(entity: widget.entity)..add(LoadAssetsEvent()),
  child: BlocBuilder<LocalAlbumBloc, LocalAlbumState>(
  builder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entity.name),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: Text("Upload to library"),
                value: "upload",
              )
            ];
          }, onSelected: (value) {
            switch (value) {
              case "upload":
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext modalContext) {
                      return BlocProvider.value(
                        value: context.read<LocalAlbumBloc>(),
                        child: Container(
                          margin: EdgeInsets.only(top: 16,left: 16,right: 16,bottom: 16),
                          child: LibrarySelectView(
                            onSelected: ({required Library library}) {
                              context.read<LocalAlbumBloc>().add(UploadToLibraryEvent(libraryId: library.id!));
                            },
                          ),
                        )
                      );
                    });
                break;
            }
          })
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: state.assets.length,
        itemBuilder: (context, index) {
          var item = state.assets[index];
          return FutureBuilder<Uint8List?>(
            future: item.thumbnailData,
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
  },
),
);
  }
}