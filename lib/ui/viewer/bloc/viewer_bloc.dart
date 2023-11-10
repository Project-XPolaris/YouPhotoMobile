import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:youphotomobile/api/image.dart';

part 'viewer_event.dart';
part 'viewer_state.dart';

class ViewerBloc extends Bloc<ViewerEvent, ViewerState> {
  final PhotoLoader loader;

  ViewerBloc({required this.loader, required int current})
      : super(ViewerInitial(
      total: loader.list.length,
      current: current,
      photos: [...loader.list]
  )) {
    on<IndexChangedEvent>((event, emit) async {
      emit(state.copyWith(current: event.index));
      print(state.current);
    });
    on<LoadMoreEvent>((event, emit) async {
      if (await loader.loadMore()) {
        emit(state.copyWith(
            total: loader.list.length, photos: [...loader.list]));
      }
    });
    on<SwitchUIEvent>((event, emit) async {
      emit(state.copyWith(showUI: event.showUI));
    });
  }
}
