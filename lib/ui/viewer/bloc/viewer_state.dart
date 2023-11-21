part of 'viewer_bloc.dart';

class ViewerState extends Equatable {
  final int total;
  final int current;
  final bool showUI;
  final List<Photo> photos;
  final String viewMode;

  const ViewerState(
      {required this.total,
      required this.current,
      required this.showUI,
      required this.photos,
        required this.viewMode
      });

  ViewerState copyWith(
      {
        int? total,
        int? current,
        bool? showUI,
        List<Photo>? photos,
        String? viewMode
      }) {
    return ViewerState(
        total: total ?? this.total,
        current: current ?? this.current,
        showUI: showUI ?? this.showUI,
        photos: photos ?? this.photos,
      viewMode: viewMode ?? this.viewMode

    );
  }

  @override
  List<Object?> get props => [total, current, showUI,photos,viewMode];
}

class ViewerInitial extends ViewerState {
  const ViewerInitial(
      {required int total, required int current, required List<Photo> photos,required String viewMode})
      : super(total: total, current: current, showUI: true, photos: photos,viewMode: viewMode);
}
