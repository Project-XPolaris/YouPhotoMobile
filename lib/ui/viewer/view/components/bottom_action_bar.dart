import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:youphotomobile/ui/components/AlbumSelectView.dart';
import 'package:youphotomobile/ui/components/LocalAlbumSelectView.dart';
import 'package:youphotomobile/ui/upscale/upscale.dart';
import 'package:youphotomobile/ui/viewer/bloc/viewer_bloc.dart';
import 'dart:io' show Platform;

class BottomActionBar extends StatelessWidget {
  final bool showUI;
  final dynamic currentPhotoItem;
  final Function(bool) onUISwitch;
  final Function(int, int) onAddToAlbum;
  final Function() onOpenDrawer;

  const BottomActionBar({
    Key? key,
    required this.showUI,
    required this.currentPhotoItem,
    required this.onUISwitch,
    required this.onAddToAlbum,
    required this.onOpenDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showUI) return Container();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface.withOpacity(0.0),
              Theme.of(context).colorScheme.surface.withOpacity(1),
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              context,
              Icons.info_rounded,
              onOpenDrawer,
            ),
            const SizedBox(width: 32),
            _buildActionButton(
              context,
              Icons.download_rounded,
              () => _handleDownload(context),
            ),
            const SizedBox(width: 32),
            _buildActionButton(
              context,
              Icons.photo_album_rounded,
              () => _handleAddToAlbum(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      var response = await Dio().get(
        currentPhotoItem.rawUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (Platform.isIOS) {
        try {
          await SaverGallery.saveImage(
            Uint8List.fromList(response.data),
            quality: 100,
            fileName: currentPhotoItem.name!,
            skipIfExists: false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error saving image')),
          );
        }
        return;
      }

      

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: LocalAlbumSelectView(
              onAlbumSelected: (String? albumName) async {
                Navigator.of(context).pop();
                var saveRelativePath = "Pictures";
                if (albumName != null) {
                  saveRelativePath = "Pictures/$albumName";
                }
                try {
                  await SaverGallery.saveImage(
                    Uint8List.fromList(response.data),
                    quality: 100,
                    fileName: currentPhotoItem.name!,
                    androidRelativePath: saveRelativePath,
                    skipIfExists: false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error saving image')),
                  );
                }
              },
            ),
          );
        },
      );
    }
  }

  void _handleAddToAlbum(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AlbumSelectView(
          onSelect: (album) {
            onAddToAlbum(album.id!, currentPhotoItem.id!);
          },
        );
      },
    );
  }
}
