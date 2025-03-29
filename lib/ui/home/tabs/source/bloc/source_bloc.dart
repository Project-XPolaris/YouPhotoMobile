import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../../api/album.dart';
import '../../../../../api/client.dart';
import '../../../../../api/library.dart';

part 'source_event.dart';

part 'source_state.dart';

class SourceBloc extends Bloc<SourceEvent, SourceState> {
  final AlbumLoader _AlbumLoader = AlbumLoader();
  final LibraryLoader _libraryLoader = LibraryLoader();

  SourceBloc() : super(SourceInitial()) {
    on<SourceEvent>((event, emit) {});
    on<RefreshDeviceAlbumEvent>((event, emit) async {
      var albums = <AssetPathEntity>[];
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth) {
        albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      } else if (ps.hasAccess) {
        albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      } else {
        // Denied
        return;
      }

      emit(state.copyWith(albums: albums));
    });

    on<LoadAlbumEvent>((event, emit) async {
      await _AlbumLoader.loadData(force: event.force);
      emit(state.copyWith(albumList: [..._AlbumLoader.list]));
    });
    on<LoadMoreAlbumEvent>((event, emit) async {
      if (await _AlbumLoader.loadMore()) {
        emit(state.copyWith(albumList: [..._AlbumLoader.list]));
      }
    });
    on<LoadLibraryEvent>((event, emit) async {
      await _libraryLoader
          .loadData(force: true, extraFilter: {"pageSize": 900});
      emit(state.copyWith(libraryList: [..._libraryLoader.list]));
    });
    on<CreateLibraryEvent>((event, emit) async {
      await ApiClient().createLibrary({"name": event.libraryName});
      await _libraryLoader.loadData(force: true);
      emit(state.copyWith(libraryList: [..._libraryLoader.list]));
    });
    on<CreateAlbumEvent>((event, emit) async {
      print("CreateAlbumEvent");
      await ApiClient().createAlbum({"name": event.name});
      await _AlbumLoader.loadData(force: true);
      emit(state.copyWith(albumList: [..._AlbumLoader.list]));
    });
    on<RemoveAlbumEvent>((event, emit) async {
      await ApiClient().removeAlbum(event.id, removeImage: event.removeImage);
      await _AlbumLoader.loadData(force: true);
      emit(state.copyWith(albumList: [..._AlbumLoader.list]));
    });
  }
}
