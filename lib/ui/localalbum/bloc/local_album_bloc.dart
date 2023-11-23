import 'dart:async';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/notification.dart';

part 'local_album_event.dart';

part 'local_album_state.dart';

class LocalAlbumBloc extends Bloc<LocalAlbumEvent, LocalAlbumState> {
  AssetPathEntity entity;

  LocalAlbumBloc({required this.entity}) : super(LocalAlbumInitial()) {
    on<LoadAssetsEvent>((event, emit) async {
      final List<AssetEntity> assets =
          await entity.getAssetListRange(start: 0, end: 1000000);
      emit(state.copyWith(assets: assets));
    });
    on<UploadToLibraryEvent>((event, emit) async {
      final List<AssetEntity> assets =
          await entity.getAssetListRange(start: 0, end: 1000000);
      doUpload(assets, event.libraryId);
    });
  }

  void doUpload(assets, libraryId) async {
    for (var index = 0; index < assets.length; index++) {
      var asset = assets[index];
      var file = await asset.file;
      if (file == null) {
        continue;
      }
      var fileBytes = await file.readAsBytes();
      var fileName = file.path.split("/").last;
      print("uploading $fileName");
      int progressPercent = index * 100 ~/ assets.length;
      NotificationPlugin().showUploadNotification(
          'Upload to library',
          'Upload in progress: ${(progressPercent).round()}%',
          index,
          assets.length);
      try {
        await ApiClient().uploadImage(fileBytes, fileName, libraryId);
      }catch(e){
        print(e);
      }
    }
    NotificationPlugin().flutterLocalNotificationsPlugin?.cancel(0);
  }
}
