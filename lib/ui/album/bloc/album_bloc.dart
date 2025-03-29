import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/notification.dart';

import '../../../api/image.dart';

part 'album_event.dart';

part 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  PhotoLoader loader = PhotoLoader();
  final albumId;

  AlbumBloc({
    required this.albumId,
  }) : super(AlbumInitial()) {
    on<LoadDataEvent>((event, emit) async {
      if (await loader.loadData(
          force: event.force, extraFilter: _getExtraParams(state.filter))) {
        emit(state.copyWith(photos: [...loader.list]));
      }
    });
    on<LoadMoreEvent>((event, emit) async {
      if (await loader.loadMore(extraFilter: _getExtraParams(state.filter))) {
        emit(state.copyWith(photos: [...loader.list]));
      }
    });
    on<UpdateFilterEvent>((event, emit) async {
      await loader.loadData(
          extraFilter: _getExtraParams(event.filter), force: true);
      emit(state.copyWith(photos: [...loader.list], filter: event.filter));
    });
    on<UpdateViewModeEvent>((event, emit) async {
      emit(state.copyWith(viewMode: event.viewMode));
    });
    on<OnChangeSelectModeEvent>((event, emit) async {
      emit(state.copyWith(selectMode: event.selectMode));
    });
    on<OnUpdateSelectedPhotosEvent>((event, emit) async {
      emit(state.copyWith(selectedPhotoIds: event.selectedPhotoIds));
    });
    on<OnSelectPhotoEvent>((event, emit) async {
      List<int> selectedPhotoIds = [...state.selectedPhotoIds];
      if (event.selected) {
        selectedPhotoIds.add(event.photoId);
      } else {
        selectedPhotoIds.remove(event.photoId);
      }
      emit(state.copyWith(selectedPhotoIds: selectedPhotoIds));
    });
    on<OnDownloadAllDoneEvent>((event, emit) async {
      emit(state.copyWith(downloadProgress: null));
    });
    on<DownloadAllAlbumEvent>((event, emit) async {
      emit(state.copyWith(isDownloadingAll: true));

      var resp = await ApiClient()
          .fetchImageList({"albumId": albumId, "pageSize": 1, "page": 1});
      var total = resp.count ?? 0;
      if (total == 0) {
        return;
      }
      var count = 0;
      var perPage = 200;
      for (var page = 1; page <= (total / perPage).ceil(); page++) {
        var resp = await ApiClient().fetchImageList(
            {"albumId": albumId, "pageSize": perPage, "page": page});
        if (resp.result.isEmpty) {
          continue;
        }
        for (var photo in resp.result) {
          print("download image from :" + photo.rawUrl);
          // emit(state.copyWith(downloadProgress: DownloadAllImageProgress(total: total,current: resp.result.indexOf(photo),name: photo.name)));
          NotificationPlugin().showDownloadNotification(
              "Download image", photo.name!, count, total);
          var saveRelativePath = "Pictures";
          if (event.localAlbumName != null) {
            saveRelativePath = "Pictures/" + event.localAlbumName!;
          }
          try {
            var response = await Dio().get(photo.rawUrl,
                options: Options(responseType: ResponseType.bytes));
            await SaverGallery.saveImage(
              Uint8List.fromList(response.data),
              quality: 100,
              fileName: photo.name!,
              androidRelativePath: saveRelativePath,
              skipIfExists: true
            );
            count++;
          } catch (e) {
            print(e);
            continue;
          }
        }
        NotificationPlugin().flutterLocalNotificationsPlugin?.cancel(1);
      }
      // emit(state.copyWith(isDownloadingAll: false,downloadProgress: DownloadAllImageProgress(total:  resp.result.length, current:  resp.result.length)));
    });
    on<RemoveSelectImagesEvent>((event, emit) async {
      await ApiClient().removeImageFromAlbum(albumId, state.selectedPhotoIds);
      emit(state.copyWith(
          photos: [
            ...state.photos.where((element) {
              return !state.selectedPhotoIds.contains(element.id);
            })
          ],
          selectMode: false,
          selectedPhotoIds: []));
    });
  }

  Map<String, dynamic> _getExtraParams(ImageQueryFilter filter) {
    Map<String, dynamic> result = {
      "order": filter.order,
      "pageSize": "200",
      "random": filter.random ? "1" : "",
      "tag": filter.tag,
      "albumId": albumId,
    };
    if (filter.libraryIds.isNotEmpty) {
      for (var id in filter.libraryIds) {
        result["libraryId"] = id.toString();
      }
    }
    return result;
  }
}
