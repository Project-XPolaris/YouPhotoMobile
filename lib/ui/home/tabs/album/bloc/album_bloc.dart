import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:youphotomobile/api/client.dart';

import '../../../../../api/album.dart';

part 'album_event.dart';
part 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final AlbumLoader _AlbumLoader = AlbumLoader();
  AlbumBloc() : super(AlbumInitial(albumList: [])) {
    on<LoadDataEvent>((event, emit) async {
      await _AlbumLoader.loadData(force: event.force);
      emit(AlbumState(albumList: [..._AlbumLoader.list]));
    });
    on<LoadMoreEvent>((event, emit) async {
      if (await _AlbumLoader.loadMore()){
        emit(AlbumState(albumList: [..._AlbumLoader.list]));
      }
    });
    on<CreateAlbumEvent>((event, emit) async {
      print("CreateAlbumEvent");
      await ApiClient().createAlbum({
        "name":event.name
      });
      await _AlbumLoader.loadData(force: true);
      emit(AlbumState(albumList: [..._AlbumLoader.list]));
    });
    on<RemoveAlbumEvent>((event, emit) async {
      await ApiClient().removeAlbum(event.id);
      await _AlbumLoader.loadData(force: true);
      emit(AlbumState(albumList: [..._AlbumLoader.list]));
    });
  }
}
