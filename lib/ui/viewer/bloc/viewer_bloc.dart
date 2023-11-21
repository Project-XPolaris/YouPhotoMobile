import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/api/image.dart';
import 'package:youphotomobile/config.dart';

part 'viewer_event.dart';
part 'viewer_state.dart';

class ViewerBloc extends Bloc<ViewerEvent, ViewerState> {
  final PhotoLoader loader;

  ViewerBloc({required this.loader, required int current})
      : super(ViewerInitial(
      total: loader.list.length,
      current: current,
      photos: [...loader.list],
      viewMode: ApplicationConfig().config.viewerModeValue
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
    on<AddToAlbumEvent>((event, emit) async {
      await ApiClient().addImageToAlbum(event.albumId, event.imageIds.toList());
    });
    on<SwitchViewModeEvent>((event, emit) async {
      ApplicationConfig().config.viewerMode = event.viewMode;
      await ApplicationConfig().updateConfig();
      emit(state.copyWith(viewMode: event.viewMode));
    });
  }
}
