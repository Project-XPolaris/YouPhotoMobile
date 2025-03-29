part of 'source_bloc.dart';

@immutable
class SourceState extends Equatable {
  final List<AssetPathEntity> albums;
  final List<Album> albumList;
  final List<Library> libraryList;

  const SourceState({required this.albums, required this.albumList,required this.libraryList});
  SourceState copyWith({
    List<AssetPathEntity>? albums,
    List<Album>? albumList,
    List<Library>? libraryList,
  }) {
    return SourceState(
      albums: albums ?? this.albums,
      albumList: albumList ?? this.albumList,
      libraryList: libraryList ?? this.libraryList,
    );
  }
  @override
  List<Object?> get props => [albums, albumList,libraryList];
}

class SourceInitial extends SourceState {
  SourceInitial() : super(albums: [],albumList: [],libraryList: []);
}
