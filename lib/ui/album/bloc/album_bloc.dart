import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/config.dart';
import 'package:youphotomobile/notification.dart';

import '../../../api/image.dart';
import '../../../services/photo_cache_service.dart';

part 'album_event.dart';

part 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final albumId;
  final localAlbums = <AssetPathEntity>[];

  AlbumBloc({
    required this.albumId,
  }) : super(AlbumInitial()) {
    on<LoadDataEvent>((event, emit) async {
      // 加载本地
      var localAlbums = <AssetPathEntity>[];
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth) {
        localAlbums =
            await PhotoManager.getAssetPathList(type: RequestType.image);
      } else if (ps.hasAccess) {
        localAlbums =
            await PhotoManager.getAssetPathList(type: RequestType.image);
      } else {
        // Denied
        return;
      }
      // localAlbums.forEach((element) {

      // });

      final isOffline = ApplicationConfig().isOffline;

      if (isOffline) {
        // 离线模式：从缓存获取数据
        try {
          List<Photo> cachedPhotos = [];
          final db = await PhotoCacheService().database;
          final List<Map<String, dynamic>> maps = await db.query(
            'photo_cache',
            where: 'album_id = ?',
            whereArgs: [albumId],
          );

          for (var map in maps) {
            final photo = await PhotoCacheService().getCachedPhoto(
              map['photo_id'],
              albumId,
            );
            if (photo != null) {
              cachedPhotos.add(photo);
            }
          }

          emit(state.copyWith(
            photos: cachedPhotos,
            isOffline: true,
          ));
        } catch (cacheError) {
          print('Cache error: $cacheError');
          emit(state.copyWith(
            photos: [],
            isOffline: true,
          ));
        }
        return;
      }

      // 在线模式：从网络获取数据
      try {
        var countResp = await ApiClient().fetchImageList(
            {...(_getExtraParams(state.filter)), "pageSize": "1", "page": "1"});

        final total = countResp.count ?? 0;
        if (total == 0) {
          emit(state.copyWith(photos: [], isOffline: false));
          return;
        }

        final perPage = 500;
        final totalPages = (total / perPage).ceil();
        List<Photo> allPhotos = [];

        for (var page = 1; page <= totalPages; page++) {
          var resp = await ApiClient().fetchImageList({
            ...(_getExtraParams(state.filter)),
            "pageSize": perPage.toString(),
            "page": page.toString(),
          });

          if (resp.result.isEmpty) {
            continue;
          }

          // 缓存每张照片
          for (var photo in resp.result) {
            await PhotoCacheService().cachePhoto(photo, albumId);
          }

          allPhotos.addAll(resp.result);
        }

        if (allPhotos.isNotEmpty) {
          emit(state.copyWith(
            photos: allPhotos,
            isOffline: false,
          ));
        } else {
          emit(state.copyWith(
            photos: [],
            isOffline: false,
          ));
        }
      } catch (e) {
        // 网络请求失败，尝试从缓存获取数据
        print('Network error, loading from cache: $e');
        try {
          List<Photo> cachedPhotos = [];
          final db = await PhotoCacheService().database;
          final List<Map<String, dynamic>> maps = await db.query(
            'photo_cache',
            where: 'album_id = ?',
            whereArgs: [albumId],
          );

          for (var map in maps) {
            final photo = await PhotoCacheService().getCachedPhoto(
              map['photo_id'],
              albumId,
            );
            if (photo != null) {
              cachedPhotos.add(photo);
            }
          }

          emit(state.copyWith(
            photos: cachedPhotos,
            isOffline: true,
          ));
        } catch (cacheError) {
          print('Cache error: $cacheError');
          emit(state.copyWith(
            photos: [],
            isOffline: true,
          ));
        }
      }
    });

    on<LoadMoreEvent>((event, emit) async {
      // var resp =
      //     await ApiClient().fetchImageList(_getExtraParams(state.filter));
      // if (resp.result.isNotEmpty) {
      //   emit(state.copyWith(photos: [...state.photos, ...resp.result]));
      // }
    });

    on<UpdateFilterEvent>((event, emit) async {
      var resp =
          await ApiClient().fetchImageList(_getExtraParams(event.filter));
      emit(state.copyWith(photos: resp.result, filter: event.filter));
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
      var perPage = 500;
      for (var page = 1; page <= (total / perPage).ceil(); page++) {
        var resp = await ApiClient().fetchImageList(
            {"albumId": albumId, "pageSize": perPage, "page": page});
        if (resp.result.isEmpty) {
          continue;
        }
        for (var photo in resp.result) {
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
            await SaverGallery.saveImage(Uint8List.fromList(response.data),
                quality: 100,
                fileName: photo.name!,
                androidRelativePath: saveRelativePath,
                skipIfExists: true);
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
      "pageSize": "500",
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
