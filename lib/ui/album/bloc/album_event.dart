part of 'album_bloc.dart';

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();
}

class LoadDataEvent extends AlbumEvent {
  final bool force;
  const LoadDataEvent({this.force = false});
  @override
  List<Object?> get props => [force];
}

class LoadMoreEvent extends AlbumEvent {
  @override
  List<Object?> get props => [];
}

class UpdateFilterEvent extends AlbumEvent {
  final ImageQueryFilter filter;
  const UpdateFilterEvent({required this.filter});
  @override
  List<Object?> get props => [filter];
}

class UpdateViewModeEvent extends AlbumEvent {
  final String viewMode;
  const UpdateViewModeEvent({required this.viewMode});
  @override
  List<Object?> get props => [viewMode];
}
class OnChangeSelectModeEvent extends AlbumEvent {
  final bool selectMode;
  const OnChangeSelectModeEvent({required this.selectMode});
  @override
  List<Object?> get props => [selectMode];
}

class OnUpdateSelectedPhotosEvent extends AlbumEvent {
  final List<int> selectedPhotoIds;
  const OnUpdateSelectedPhotosEvent({required this.selectedPhotoIds});
  @override
  List<Object?> get props => [selectedPhotoIds];
}

class OnSelectPhotoEvent extends AlbumEvent {
  final int photoId;
  final bool selected;
  const OnSelectPhotoEvent({required this.photoId,required this.selected});
  @override
  List<Object?> get props => [photoId,selected];
}

class OnDownloadAllDoneEvent extends AlbumEvent {
  const OnDownloadAllDoneEvent();
  @override
  List<Object?> get props => [];
}
class DownloadAllAlbumEvent extends AlbumEvent {
  final String? localAlbumName;
  const DownloadAllAlbumEvent({this.localAlbumName});
  @override
  List<Object?> get props => [localAlbumName];
}
class RemoveSelectImagesEvent extends AlbumEvent {
  const RemoveSelectImagesEvent();
  @override
  List<Object?> get props => [];
}