import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:youphotomobile/api/image.dart';

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
      await loader.loadData(extraFilter: _getExtraParams(event.filter),force: true);
        emit(state.copyWith(photos: [...loader.list],filter: event.filter));
    });
    on<UpdateViewModeEvent>((event, emit) async {
      emit(state.copyWith(viewMode: event.viewMode));
    });
  }
  Map<String,String> _getExtraParams(ImageQueryFilter filter) {
    Map<String,String> result = {
      "order":filter.order,
      "pageSize":"200",
      "random":filter.random ? "1" : ""
    };
    if (filter.libraryIds.isNotEmpty) {
      for (var id in filter.libraryIds) {
        result["libraryId"] = id.toString();
      }
    }
    return result;
  }
}
