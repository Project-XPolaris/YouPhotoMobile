part of 'viewer_bloc.dart';

abstract class ViewerEvent extends Equatable {
  const ViewerEvent();
}

class IndexChangedEvent extends ViewerEvent {
  final int index;
  const IndexChangedEvent({required this.index});
  @override
  List<Object?> get props => [index];
}
class LoadMoreEvent extends ViewerEvent {
  const LoadMoreEvent();
  @override
  List<Object?> get props => [];
}
class SwitchUIEvent extends ViewerEvent {
  final bool showUI;
  const SwitchUIEvent({required this.showUI});
  @override
  List<Object?> get props => [];
}

class AddToAlbumEvent extends ViewerEvent {
  final int albumId;
  final List<int> imageIds;
  const AddToAlbumEvent({required this.albumId, required this.imageIds});
  @override
  List<Object?> get props => [albumId, imageIds];
}