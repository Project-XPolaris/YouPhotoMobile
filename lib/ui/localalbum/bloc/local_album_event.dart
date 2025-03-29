part of 'local_album_bloc.dart';

abstract class LocalAlbumEvent extends Equatable {
  const LocalAlbumEvent();
}

class UploadToLibraryEvent extends LocalAlbumEvent {
  final int libraryId;

  const UploadToLibraryEvent({required this.libraryId});

  @override
  List<Object?> get props => [libraryId];
}

class LoadAssetsEvent extends LocalAlbumEvent {
  const LoadAssetsEvent();
  @override
  List<Object?> get props => [];
}

class UpdateImageFitEvent extends LocalAlbumEvent {
  final String imageFit;

  const UpdateImageFitEvent({required this.imageFit});

  @override
  List<Object> get props => [imageFit];
}
