
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
      print(event.filter);
      await loader.loadData(
          extraFilter: _getExtraParams(event.filter), force: true);
      emit(state.copyWith(photos: [...loader.list], filter: event.filter));
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
      bool selectMode = state.selectMode;
      if (selectedPhotoIds.isEmpty) {
        selectMode = false;
      }

      emit(state.copyWith(
          selectedPhotoIds: selectedPhotoIds, selectMode: selectMode));
    });
    on<OnChangeSelectModeEvent>((event, emit) async {
      emit(state.copyWith(selectMode: event.selectMode));
    });
    on<OnUpdateSelectedPhotosEvent>((event, emit) async {
      bool selectMode = state.selectMode;
      if (event.selectedPhotoIds.isEmpty) {
        selectMode = false;
      }
      emit(state.copyWith(
          selectedPhotoIds: event.selectedPhotoIds, selectMode: selectMode));
    });
    on<OnAddSelectedPhotosEvent>((event, emit) async {
      await ApiClient().addImageToAlbum(event.albumId, event.selectedPhotoIds);
      emit(state.copyWith(selectedPhotoIds: []));
    });
    on<OnUpdateImageFitEvent>((event, emit) async {
      emit(state.copyWith(gridMode: event.fit));
      ApplicationConfig().config.homeImageFitMode = event.fit;
      ApplicationConfig().updateConfig();
    });
    on<OnDeleteSelectedPhotosEvent>((event, emit) async {
      List<int> ids = [...state.selectedPhotoIds];
      await ApiClient().removeImagesByIds(ids, deleteImage: event.deleteImages);
      await loader.loadData(
          extraFilter: _getExtraParams(state.filter), force: true);
      emit(state.copyWith(
          selectedPhotoIds: [], selectMode: false, photos: [...loader.list]));
    });
  }

  Map<String, dynamic> _getExtraParams(ImageQueryFilter filter) {
    Map<String, dynamic> result = {
      "order": filter.order,
      "pageSize": 200,
      "random": filter.random ? "1" : "",
      "tag": filter.tag,
      "orient": filter.orient
    };
    if (filter.libraryIds.isNotEmpty) {
      for (var id in filter.libraryIds) {
        result["libraryId"] = id.toString();
      }
    }
    if (filter.resolution != 'all') {
      switch (filter.resolution) {
        case '1080':
          if (filter.orient == 'landscape' || filter.orient == 'all') {
            result["minWidth"] = 1920;
            result["minHeight"] = 1080;
          } else {
            result["minWidth"] = 1080;
            result["minHeight"] = 1920;
          }
          break;
        case '2k':
          if (filter.orient == 'landscape' || filter.orient == 'all') {
            result["minWidth"] = 2560;
            result["minHeight"] = 1440;
          } else {
            result["minWidth"] = 1440;
            result["minHeight"] = 2560;
          }
          break;
        case '4k':
          if (filter.orient == 'landscape' || filter.orient == 'all') {
            result["minWidth"] = 3840;
            result["minHeight"] = 2160;
          } else {
            result["minWidth"] = 2160;
            result["minHeight"] = 3840;
          }
          break;
        case '8k':
          if (filter.orient == 'landscape' || filter.orient == 'all') {
            result["minWidth"] = 7680;
            result["minHeight"] = 4320;
          } else {
            result["minWidth"] = 4320;
            result["minHeight"] = 7680;
          }
          break;
      }
    }
    return result;
  }
}
