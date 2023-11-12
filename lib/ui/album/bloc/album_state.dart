part of 'album_bloc.dart';

class ImageQueryFilter {
  final String order;
  final bool random;
  final List<String> libraryIds;
  final List<String> tag;

  const ImageQueryFilter(
      {this.order = "id desc", this.random = false, this.libraryIds = const [], this.tag = const []});

  ImageQueryFilter copyWith({
    String? order,
    bool? random,
    List<String>? libraryIds,
    String? viewMode,
    List<String>? tag,
  }) {
    return ImageQueryFilter(
      order: order ?? this.order,
      random: random ?? this.random,
      libraryIds: libraryIds ?? this.libraryIds,
      tag: tag ?? this.tag,
    );
  }
}

class AlbumState extends Equatable {
  final ImageQueryFilter filter;
  final List<Photo> photos;
  final String viewMode;

  const AlbumState(
      {required this.filter, required this.photos, required this.viewMode});

  AlbumState copyWith({ImageQueryFilter? filter, List<Photo>? photos, String? viewMode}) {
    return AlbumState(
      filter: filter ?? this.filter,
      photos: photos ?? this.photos,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [filter, photos,viewMode];
}

class AlbumInitial extends AlbumState {
  AlbumInitial() : super(filter: const ImageQueryFilter(), photos: [],viewMode: "large");
}
