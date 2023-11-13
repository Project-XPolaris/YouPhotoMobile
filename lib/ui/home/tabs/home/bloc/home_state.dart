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

class TabHomeState extends Equatable {
  final ImageQueryFilter filter;
  final List<Photo> photos;
  final String viewMode;
  final List<int> selectedPhotoIds;
  final bool selectMode;
  const TabHomeState(
      {required this.filter, required this.photos, required this.viewMode, this.selectedPhotoIds = const [],this.selectMode = false});

  TabHomeState copyWith({
    ImageQueryFilter? filter,
    List<Photo>? photos,
    String? viewMode,
    List<int>? selectedPhotoIds,
    bool? selectMode,
  }) {
    return TabHomeState(
      filter: filter ?? this.filter,
      photos: photos ?? this.photos,
      viewMode: viewMode ?? this.viewMode,
      selectedPhotoIds: selectedPhotoIds ?? this.selectedPhotoIds,
      selectMode: selectMode ?? this.selectMode,
    );
  }
  bool isSelected(int photoId) {
    return selectedPhotoIds.contains(photoId);
  }

  @override
  List<Object?> get props => [filter, photos,viewMode,selectedPhotoIds,selectMode];
}

class HomeInitial extends TabHomeState {
  HomeInitial() : super(filter: const ImageQueryFilter(), photos: [],viewMode: "large");
}
