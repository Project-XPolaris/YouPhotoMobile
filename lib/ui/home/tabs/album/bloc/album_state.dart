part of 'album_bloc.dart';

class AlbumState extends Equatable {
  final List<Album> albumList;
  const AlbumState({required this.albumList});

  @override
  List<Object?> get props => [albumList];
}

class AlbumInitial extends AlbumState {
  AlbumInitial({required List<Album> albumList}) : super(albumList: albumList);

  @override
  List<Object> get props => [];
}
