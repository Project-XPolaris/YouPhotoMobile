part of 'local_album_bloc.dart';

abstract class LocalAlbumEvent extends Equatable {
  const LocalAlbumEvent();
}

class UploadToLibraryEvent extends LocalAlbumEvent {
  final int libraryId;
  UploadToLibraryEvent({required this.libraryId});

  @override
  List<Object?> get props => [libraryId];
}

class LoadAssetsEvent extends LocalAlbumEvent {
  LoadAssetsEvent();
  @override
  List<Object?> get props => [];
}