part of 'album_bloc.dart';

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();
}

class LoadDataEvent extends AlbumEvent {
  final bool force;
  LoadDataEvent({this.force = false});
  @override
  List<Object?> get props => [force];
}

class LoadMoreEvent extends AlbumEvent {
  @override
  List<Object?> get props => [];
}

class UpdateFilterEvent extends AlbumEvent {
  final ImageQueryFilter filter;
  UpdateFilterEvent({required this.filter});
  @override
  List<Object?> get props => [filter];
}

class UpdateViewModeEvent extends AlbumEvent {
  final String viewMode;
  UpdateViewModeEvent({required this.viewMode});
  @override
  List<Object?> get props => [viewMode];
}