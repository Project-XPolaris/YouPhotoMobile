part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class LoadDataEvent extends HomeEvent {
  final bool force;

  const LoadDataEvent({this.force = false});

  @override
  List<Object?> get props => [force];
}

class LoadMoreEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class UpdateFilterEvent extends HomeEvent {
  final ImageQueryFilter filter;

  const UpdateFilterEvent({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class UpdateGridSizeEvent extends HomeEvent {
  final int gridSize;

  const UpdateGridSizeEvent({required this.gridSize});

  @override
  List<Object?> get props => [gridSize];
}

class OnSelectPhotoEvent extends HomeEvent {
  final int photoId;
  final bool selected;

  const OnSelectPhotoEvent({required this.photoId, required this.selected});

  @override
  List<Object?> get props => [photoId, selected];
}

class OnChangeSelectModeEvent extends HomeEvent {
  final bool selectMode;

  const OnChangeSelectModeEvent({required this.selectMode});

  @override
  List<Object?> get props => [selectMode];
}

class OnUpdateSelectedPhotosEvent extends HomeEvent {
  final List<int> selectedPhotoIds;

  const OnUpdateSelectedPhotosEvent({required this.selectedPhotoIds});

  @override
  List<Object?> get props => [selectedPhotoIds];
}

class OnAddSelectedPhotosEvent extends HomeEvent {
  final List<int> selectedPhotoIds;
  final albumId;

  const OnAddSelectedPhotosEvent(
      {required this.selectedPhotoIds, required this.albumId});

  @override
  List<Object?> get props => [selectedPhotoIds, albumId];
}

class OnUpdateImageFitEvent extends HomeEvent {
  final String fit;

  const OnUpdateImageFitEvent({required this.fit});

  @override
  List<Object?> get props => [fit];
}

class OnDeleteSelectedPhotosEvent extends HomeEvent {
  final bool deleteImages;

  const OnDeleteSelectedPhotosEvent({required this.deleteImages});

  @override
  List<Object?> get props => [deleteImages];
}
