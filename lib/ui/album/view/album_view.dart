import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/album.dart';
import '../../../util/listview.dart';
import '../../viewer/view/wrap.dart';
import '../bloc/album_bloc.dart';

class AlbumDetailView extends StatelessWidget {
  final Album album;
  const AlbumDetailView({Key? key,required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => AlbumBloc(albumId: album.id)..add(LoadDataEvent(force: false)),
        child: BlocBuilder<AlbumBloc, AlbumState>(
          builder: (context, state) {
            var controller = createLoadMoreController(
                    () => context.read<AlbumBloc>().add(LoadMoreEvent()));
            return Scaffold(
              appBar: AppBar(
                title: Text(album.displayName),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                onRefresh: () async {
                  context
                      .read<AlbumBloc>()
                      .add(UpdateFilterEvent(filter: state.filter));
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 16,left: 16,right: 16),
                  child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        int crossAxisCount = (constraints.maxWidth / 130).round();
                        switch (state.viewMode) {
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
                        return GridView.builder(
                          controller: controller,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.photos.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemBuilder: (context, index) {
                            var content = CachedNetworkImage(
                              imageUrl: state.photos[index].thumbnailUrl,
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              fit: BoxFit.cover,
                            );
                            return GestureDetector(
                              onTap: () async {
                                await ImageViewer.Launch(
                                    context, context.read<AlbumBloc>().loader, index,
                                        (changedIndex) {
                                      double mainAxisSize = constraints.maxWidth;
                                      double crossAxisSize = constraints.maxHeight;
                                      int itemHeight = (mainAxisSize / crossAxisCount).floor();
                                      int itemInRowIndex =
                                      ((changedIndex.toDouble() + 1) / crossAxisCount)
                                          .ceil();
                                      // calc offset in center of grid
                                      double offset =
                                          (itemHeight * itemInRowIndex) - (crossAxisSize / 2);
                                      controller.jumpTo(offset);
                                    });
                              },
                              child: Container(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                child: content,
                              ),
                            );
                          },
                        );
                      }),
                ),
              ),
            );
          },
        ));
  }

  static Launch(BuildContext context, Album album) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AlbumDetailView(
              album: album,
            )));
  }
}