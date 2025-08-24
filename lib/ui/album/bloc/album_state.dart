part of 'album_bloc.dart';

class ImageQueryFilter {
  final String order;
  final bool random;
  final List<String> libraryIds;
  final List<String> tag;
  const ImageQueryFilter(
      {this.order = "id desc",
      this.random = false,
      this.libraryIds = const [],
      this.tag = const []});

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

class DownloadAllImageProgress {
  final int total;
  final int current;
  final String? name;
  DownloadAllImageProgress(
      {required this.total, required this.current, this.name});
}

class AlbumState extends Equatable {
  final ImageQueryFilter filter;
  final List<Photo> photos;
  final String viewMode;
  final List<int> selectedPhotoIds;
  final bool selectMode;
  final DownloadAllImageProgress? downloadProgress;
  final bool isOffline;

  const AlbumState(
      {required this.filter,
      required this.photos,
      required this.viewMode,
      this.selectedPhotoIds = const [],
      this.selectMode = false,
      this.downloadProgress,
      this.isOffline = false});

  AlbumState copyWith(
      {ImageQueryFilter? filter,
      List<Photo>? photos,
      String? viewMode,
      List<int>? selectedPhotoIds,
      bool? selectMode,
      DownloadAllImageProgress? downloadProgress,
      bool? isDownloadingAll,
      bool? isOffline}) {
    return AlbumState(
      filter: filter ?? this.filter,
      photos: photos ?? this.photos,
      viewMode: viewMode ?? this.viewMode,
      selectedPhotoIds: selectedPhotoIds ?? this.selectedPhotoIds,
      selectMode: selectMode ?? this.selectMode,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  bool isSelected(int photoId) {
    return selectedPhotoIds.contains(photoId);
  }

  @override
  List<Object?> get props => [
        filter,
        photos,
        viewMode,
        selectedPhotoIds,
        selectMode,
        downloadProgress,
        isOffline
      ];
}

class AlbumInitial extends AlbumState {
  AlbumInitial()
      : super(filter: const ImageQueryFilter(), photos: [], viewMode: "large");
}
