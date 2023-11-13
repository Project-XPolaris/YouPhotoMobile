part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class LoadDataEvent extends HomeEvent {
  final bool force;
  LoadDataEvent({this.force = false});
  @override
  List<Object?> get props => [force];
}

class LoadMoreEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class UpdateFilterEvent extends HomeEvent {
  final ImageQueryFilter filter;
  UpdateFilterEvent({required this.filter});
  @override
  List<Object?> get props => [filter];
}

class UpdateViewModeEvent extends HomeEvent {
  final String viewMode;
  UpdateViewModeEvent({required this.viewMode});
  @override
  List<Object?> get props => [viewMode];
}

class OnSelectPhotoEvent extends HomeEvent {
  final int photoId;
  final bool selected;
  OnSelectPhotoEvent({required this.photoId,required this.selected});
  @override
  List<Object?> get props => [photoId,selected];
}

class OnChangeSelectModeEvent extends HomeEvent {
  final bool selectMode;
  OnChangeSelectModeEvent({required this.selectMode});
  @override
  List<Object?> get props => [selectMode];
}

class OnUpdateSelectedPhotosEvent extends HomeEvent {
  final List<int> selectedPhotoIds;
  OnUpdateSelectedPhotosEvent({required this.selectedPhotoIds});
  @override
  List<Object?> get props => [selectedPhotoIds];
}
class OnAddSelectedPhotosEvent extends HomeEvent {
  final List<int> selectedPhotoIds;
 final albumId;
  OnAddSelectedPhotosEvent({required this.selectedPhotoIds,required this.albumId});
  @override
  List<Object?> get props => [selectedPhotoIds,albumId];
}