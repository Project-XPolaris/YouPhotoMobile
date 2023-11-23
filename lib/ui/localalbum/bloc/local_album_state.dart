part of 'local_album_bloc.dart';

class LocalAlbumState extends Equatable {
  List<AssetEntity> assets = [];

  LocalAlbumState({List<AssetEntity>? assets}) {
    if (assets != null) {
      this.assets = assets;
    }
  }
  LocalAlbumState copyWith({
    List<AssetEntity>? assets,

  }) {
    return LocalAlbumState(
      assets: assets ?? this.assets,
    );
  }


  @override
  List<Object?> get props => [assets];
}

class LocalAlbumInitial extends LocalAlbumState {
  @override
  List<Object> get props => [assets];
}

