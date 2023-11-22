import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/api/image.dart';
import 'package:youphotomobile/config.dart';

part 'home_event.dart';
part 'home_state.dart';

class TabHomeBloc extends Bloc<HomeEvent, TabHomeState> {
  PhotoLoader loader = PhotoLoader();
  TabHomeBloc() : super(HomeInitial()) {
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
    on<UpdateGridSizeEvent>((event, emit) async {
      emit(state.copyWith(gridSize: event.gridSize));
      ApplicationConfig().config.imageGridSize = event.gridSize;
      ApplicationConfig().updateConfig();
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
    on<OnChangeSelectModeEvent>((event, emit) async {
      emit(state.copyWith(selectMode: event.selectMode));
    });
    on<OnUpdateSelectedPhotosEvent>((event, emit) async {
      emit(state.copyWith(selectedPhotoIds: event.selectedPhotoIds));
    });
    on<OnAddSelectedPhotosEvent>((event, emit) async {
      await ApiClient().addImageToAlbum(event.albumId, event.selectedPhotoIds);
      emit(state.copyWith(selectedPhotoIds: []));
    });
  }
  Map<String,dynamic> _getExtraParams(ImageQueryFilter filter) {
    Map<String,dynamic> result = {
      "order":filter.order,
      "pageSize":100000,
      "random":filter.random ? "1" : "",
      "tag":filter.tag,
    };
    if (filter.libraryIds.isNotEmpty) {
      for (var id in filter.libraryIds) {
        result["libraryId"] = id.toString();
      }
    }
    return result;
  }
}
