import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/api/image.dart';
import 'package:youphotomobile/config.dart';

part 'viewer_event.dart';

part 'viewer_state.dart';

class ViewerBloc extends Bloc<ViewerEvent, ViewerState> {
  final List<Photo> photos;

  ViewerBloc({required this.photos, required int current})
      : super(ViewerInitial(
            total: photos.length,
            current: current,
            photos: photos,
            viewMode: ApplicationConfig().config.viewerModeValue,
            currentPhoto: photos[current])) {
    on<IndexChangedEvent>((event, emit) async {
      if (event.index >= 0 && event.index < photos.length) {
        Photo currentPhoto = photos[event.index];
        emit(state.copyWith(currentPhoto: currentPhoto, current: event.index));
        Photo photo = await ApiClient().fetchImage(currentPhoto.id!);
        emit(state.copyWith(currentPhoto: photo));
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
