part of 'home_bloc.dart';

class ImageQueryFilter {
  final String order;
  final bool random;
  final List<String> libraryIds;

  const ImageQueryFilter(
      {this.order = "id desc", this.random = false, this.libraryIds = const []});

  ImageQueryFilter copyWith({
    String? order,
    bool? random,
    List<String>? libraryIds,
    String? viewMode,
  }) {
    return ImageQueryFilter(
      order: order ?? this.order,
      random: random ?? this.random,
      libraryIds: libraryIds ?? this.libraryIds,
    );
  }
}

class TabHomeState extends Equatable {
  final ImageQueryFilter filter;
  final List<Photo> photos;
  final String viewMode;

  const TabHomeState(
      {required this.filter, required this.photos, required this.viewMode});

  TabHomeState copyWith({ImageQueryFilter? filter, List<Photo>? photos, String? viewMode}) {
    return TabHomeState(
      filter: filter ?? this.filter,
      photos: photos ?? this.photos,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [filter, photos,viewMode];
}

class HomeInitial extends TabHomeState {
  HomeInitial() : super(filter: const ImageQueryFilter(), photos: [],viewMode: "large");
}
