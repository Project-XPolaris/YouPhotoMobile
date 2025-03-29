part of 'album_bloc.dart';

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();
}
class LoadDataEvent extends AlbumEvent {
  final bool force;

  const LoadDataEvent({required this.force});

  @override
  List<Object?> get props => [force];
}

class LoadMoreEvent extends AlbumEvent {
  const LoadMoreEvent();

  @override
  List<Object?> get props => [];
}

class CreateAlbumEvent extends AlbumEvent {
  final String name;
  const CreateAlbumEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class RemoveAlbumEvent extends AlbumEvent {
  final int id;
  const RemoveAlbumEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

