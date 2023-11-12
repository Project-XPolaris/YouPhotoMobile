import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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
      if (await loader.loadData(force: event.force,extraFilter: _getExtraParams(state.filter))){
        emit(state.copyWith(photos: [...loader.list]));
      }
    });
    on<LoadMoreEvent>((event, emit) async {
      if (await loader.loadMore(extraFilter: _getExtraParams(state.filter))){
        emit(state.copyWith(photos: [...loader.list]));
      }
    });
    on<UpdateFilterEvent>((event, emit) async {
      print(event.filter);
      await loader.loadData(extraFilter: _getExtraParams(event.filter),force: true);
      emit(state.copyWith(photos: [...loader.list],filter: event.filter));
    });
    on<UpdateViewModeEvent>((event, emit) async {
      emit(state.copyWith(viewMode: event.viewMode));
    });
  }
  Map<String,dynamic> _getExtraParams(ImageQueryFilter filter) {
    Map<String,dynamic> result = {
      "order":filter.order,
      "pageSize":"200",
      "random":filter.random ? "1" : "",
      "tag":filter.tag,
      "albumId":albumId,
    };
    if (filter.libraryIds.isNotEmpty) {
      for (var id in filter.libraryIds) {
        result["libraryId"] = id.toString();
      }
    }
    return result;
  }
}