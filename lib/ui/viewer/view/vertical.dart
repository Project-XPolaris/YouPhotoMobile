import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/viewer/bloc/viewer_bloc.dart';
import 'package:youphotomobile/ui/viewer/view/components/bottom_action_bar.dart';
import 'package:youphotomobile/ui/viewer/view/components/info_panel.dart';
import 'package:youphotomobile/ui/viewer/view/components/photo_viewer.dart';
import 'package:youphotomobile/ui/viewer/view/components/viewer_app_bar.dart';

import '../../../util/screen.dart';

class ImageViewerVertical extends StatelessWidget {
  final Function(int) onIndexChange;

  const ImageViewerVertical({Key? key, required this.onIndexChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isFolderDevice = checkFoldableDevice(context);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return BlocBuilder<ViewerBloc, ViewerState>(
      builder: (context, state) {
        void onAddImageToAlbum(int albumId, int imageId) {
          context
              .read<ViewerBloc>()
              .add(AddToAlbumEvent(albumId: albumId, imageIds: [imageId]));
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Added to album')));
        }

        var currentPhotoItem = state.currentPhoto;
        var controller = PageController(
          initialPage: state.current,
        );

        return Row(
          children: [
            Expanded(
              child: Scaffold(
                key: _scaffoldKey,
                extendBodyBehindAppBar: true,
                appBar: ViewerAppBar(
                  showUI: state.showUI,
                  title: currentPhotoItem.name ?? '',
                ),
                endDrawer: (state.viewMode == "fixed" || !isFolderDevice)
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width - 64,
                        child: InfoPanel(photoItem: currentPhotoItem),
                      )
                    : null,
                body: Stack(
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: PageView.builder(
                            allowImplicitScrolling: true,
                            onPageChanged: (index) {
                              context
                                  .read<ViewerBloc>()
                                  .add(IndexChangedEvent(index: index));
                              if (index == state.total - 1) {
                                context
                                    .read<ViewerBloc>()
                                    .add(const LoadMoreEvent());
                              }
                              onIndexChange(index);
                            },
                            controller: controller,
                            itemBuilder: (context, index) {
                              return PhotoViewer(
                                id: state.photos[index].id!,
                                rawUrl: state.photos[index].rawUrl,
                                thumbnailUrl: state.photos[index].thumbnailUrl,
                                showUI: state.showUI,
                                onUISwitch: (showUI) {
                                  context
                                      .read<ViewerBloc>()
                                      .add(SwitchUIEvent(showUI: showUI));
                                },
                              );
                            },
                            itemCount: state.total,
                          ),
                        )
                      ],
                    ),
                    BottomActionBar(
                      showUI: state.showUI,
                      currentPhotoItem: currentPhotoItem,
                      onUISwitch: (showUI) {
                        context
                            .read<ViewerBloc>()
                            .add(SwitchUIEvent(showUI: showUI));
                      },
                      onAddToAlbum: onAddImageToAlbum,
                      onOpenDrawer: () {
                        if (MediaQuery.of(context).size.width > 600) {
                          var switchToViewMode =
                              state.viewMode == "auto" ? "fixed" : "auto";
                          context.read<ViewerBloc>().add(
                              SwitchViewModeEvent(viewMode: switchToViewMode));
                          return;
                        }
                        _scaffoldKey.currentState!.openEndDrawer();
                      },
                    ),
                  ],
                ),
              ),
            ),
            isFolderDevice && state.viewMode == "auto"
                ? InfoPanel(photoItem: currentPhotoItem)
                : Container()
          ],
        );
      },
    );
  }
}
