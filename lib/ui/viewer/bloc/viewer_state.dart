part of 'viewer_bloc.dart';

class ViewerState extends Equatable {
  final int total;
  final int current;
  final bool showUI;
  final List<Photo> photos;
  final String viewMode;
  final Photo currentPhoto;
  final Photo? extra;

  const ViewerState(
      {required this.total,
      required this.current,
      required this.showUI,
      required this.photos,
      required this.viewMode,
      required this.currentPhoto,
      this.extra});

  ViewerState copyWith(
      {int? total,
      int? current,
      bool? showUI,
      List<Photo>? photos,
      String? viewMode,
      Photo? currentPhoto,
      Photo? extra}) {
    return ViewerState(
        total: total ?? this.total,
        current: current ?? this.current,
        showUI: showUI ?? this.showUI,
        photos: photos ?? this.photos,
        viewMode: viewMode ?? this.viewMode,
        currentPhoto: currentPhoto ?? this.currentPhoto,
        extra: extra ?? this.extra);
  }

  @override
  List<Object?> get props =>
      [total, current, showUI, photos, viewMode, currentPhoto, extra];
}

class ViewerInitial extends ViewerState {
  const ViewerInitial(
      {required int total,
      required int current,
      required List<Photo> photos,
      required String viewMode,
      required Photo currentPhoto,
      Photo? extra})
      : super(
            total: total,
            current: current,
            showUI: true,
            photos: photos,
            viewMode: viewMode,
            currentPhoto: currentPhoto,
            extra: extra);
}
