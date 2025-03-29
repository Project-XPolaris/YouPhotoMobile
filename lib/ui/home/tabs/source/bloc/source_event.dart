part of 'source_bloc.dart';

@immutable
class SourceEvent {}

@immutable
class RefreshDeviceAlbumEvent extends SourceEvent {}

class LoadAlbumEvent extends SourceEvent {
  final bool force;

  LoadAlbumEvent({required this.force});

  @override
  List<Object?> get props => [force];
}

class LoadMoreAlbumEvent extends SourceEvent {
  LoadMoreAlbumEvent();

  @override
  List<Object?> get props => [];
}

class LoadLibraryEvent extends SourceEvent {
  LoadLibraryEvent();

  @override
  List<Object?> get props => [];
}

class CreateLibraryEvent extends SourceEvent {
  final String libraryName;

  CreateLibraryEvent({required this.libraryName});

  @override
  List<Object?> get props => [libraryName];
}

class CreateAlbumEvent extends SourceEvent {
  final String name;

  CreateAlbumEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class RemoveAlbumEvent extends SourceEvent {
  final int id;
  final bool removeImage;

  RemoveAlbumEvent({required this.id, this.removeImage = false});

  @override
  List<Object?> get props => [id, removeImage];
}
