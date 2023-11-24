part of 'home_bloc.dart';

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

class TabHomeState extends Equatable {
  final ImageQueryFilter filter;
  final List<Photo> photos;
  final int gridSize;
  final List<int> selectedPhotoIds;
  final bool selectMode;
  const TabHomeState(
      {required this.filter, required this.photos, required this.gridSize, this.selectedPhotoIds = const [],this.selectMode = false});

  TabHomeState copyWith({
    ImageQueryFilter? filter,
    List<Photo>? photos,
    int? gridSize,
    List<int>? selectedPhotoIds,
    bool? selectMode,
  }) {
    return TabHomeState(
      filter: filter ?? this.filter,
      photos: photos ?? this.photos,
      gridSize: gridSize ?? this.gridSize,
      selectedPhotoIds: selectedPhotoIds ?? this.selectedPhotoIds,
      selectMode: selectMode ?? this.selectMode,
    );
  }
  bool isSelected(int photoId) {
    return selectedPhotoIds.contains(photoId);
  }

  @override
  List<Object?> get props => [filter, photos,gridSize,selectedPhotoIds,selectMode];
}

class HomeInitial extends TabHomeState {
  HomeInitial() : super(filter: const ImageQueryFilter(), photos: [],gridSize: ApplicationConfig().config.imageGridSizeValue);
}
