part of 'viewer_bloc.dart';

class ViewerState extends Equatable {
  final int total;
  final int current;
  final bool showUI;
  final List<Photo> photos;

  const ViewerState(
      {required this.total,
      required this.current,
      required this.showUI,
      required this.photos});

  ViewerState copyWith(
      {int? total, int? current, bool? showUI, List<Photo>? photos}) {
    return ViewerState(
        total: total ?? this.total,
        current: current ?? this.current,
        showUI: showUI ?? this.showUI,
        photos: photos ?? this.photos);
  }

  @override
  List<Object?> get props => [total, current, showUI];
}

class ViewerInitial extends ViewerState {
  const ViewerInitial(
      {required int total, required int current, required List<Photo> photos})
      : super(total: total, current: current, showUI: true, photos: photos);
}
