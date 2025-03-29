part of 'local_album_bloc.dart';

class LocalAlbumState extends Equatable {
  List<AssetEntity> assets = [];
  String imageFit = "cover";

  LocalAlbumState({
    List<AssetEntity>? assets,
    String? imageFit,
  }) {
    if (assets != null) {
      this.assets = assets;
    }
    if (imageFit != null) {
      this.imageFit = imageFit;
    }
  }

  LocalAlbumState copyWith({
    List<AssetEntity>? assets,
    String? imageFit,
  }) {
    return LocalAlbumState(
      assets: assets ?? this.assets,
      imageFit: imageFit ?? this.imageFit,
    );
  }

  @override
  List<Object?> get props => [assets, imageFit];
}

class LocalAlbumInitial extends LocalAlbumState {
  @override
  List<Object> get props => [assets, imageFit];

  LocalAlbumInitial() : super(assets: [], imageFit: ApplicationConfig().config.localImageFitMode);
}
