part of 'home_bloc.dart';

class ImageQueryFilter {
  final String order;
  final bool random;
  final List<String> libraryIds;
  final List<String> tag;
  final String orient;
  final String resolution;

  const ImageQueryFilter(
      {this.order = "id desc",
      this.random = false,
      this.libraryIds = const [],
      this.tag = const [],
      this.resolution = "all",
      this.orient = "all"});

  ImageQueryFilter copyWith({
    String? order,
    bool? random,
    List<String>? libraryIds,
    List<String>? tag,
    String? orient,
    String? resolution,
  }) {
    return ImageQueryFilter(
      order: order ?? this.order,
      random: random ?? this.random,
      libraryIds: libraryIds ?? this.libraryIds,
      tag: tag ?? this.tag,
      orient: orient ?? this.orient,
      resolution: resolution ?? this.resolution,
    );
  }
}

class TabHomeState extends Equatable {
  final ImageQueryFilter filter;
  final List<Photo> photos;
  final int gridSize;
  final List<int> selectedPhotoIds;
  final bool selectMode;
  final String gridMode;

  const TabHomeState(
      {required this.filter,
      required this.photos,
      required this.gridSize,
      this.selectedPhotoIds = const [],
      this.selectMode = false,
      this.gridMode = "cover"});

  TabHomeState copyWith(
      {ImageQueryFilter? filter,
      List<Photo>? photos,
      int? gridSize,
      List<int>? selectedPhotoIds,
      bool? selectMode,
      String? gridMode}) {
    return TabHomeState(
        filter: filter ?? this.filter,
        photos: photos ?? this.photos,
        gridSize: gridSize ?? this.gridSize,
        selectedPhotoIds: selectedPhotoIds ?? this.selectedPhotoIds,
        selectMode: selectMode ?? this.selectMode,
        gridMode: gridMode ?? this.gridMode);
  }

  bool isSelected(int photoId) {
    return selectedPhotoIds.contains(photoId);
  }

  @override
  List<Object?> get props =>
      [filter, photos, gridSize, selectedPhotoIds, selectMode, gridMode];
}

class HomeInitial extends TabHomeState {
  HomeInitial()
      : super(
            filter: const ImageQueryFilter(),
            photos: [],
            gridSize: ApplicationConfig().config.imageGridSizeValue,
            gridMode: ApplicationConfig().config.homeImageFitMode ?? 'cover');
}
