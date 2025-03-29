
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/config.dart';
import 'package:youphotomobile/notification.dart';
import 'package:crypto/crypto.dart';
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
    on<UpdateImageFitEvent>((event, emit) async {
      emit(state.copyWith(imageFit: event.imageFit));
      ApplicationConfig().config.localImageFitMode = event.imageFit;
      ApplicationConfig().updateConfig();
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
        var fileMd5 = md5.convert(fileBytes);
        var resp = await ApiClient().fetchImageList({"md5": fileMd5.toString(),"libraryId":libraryId.toString()});
        if ((resp.count ?? 0) > 0) {
          continue;
        }
        await ApiClient().uploadImage(fileBytes, fileName, libraryId,albumName: entity.name);
      }catch(e){
        print(e);
      }
    }
    NotificationPlugin().flutterLocalNotificationsPlugin?.cancel(0);
  }
}
