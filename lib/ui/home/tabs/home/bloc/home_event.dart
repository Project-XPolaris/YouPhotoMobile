part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class LoadDataEvent extends HomeEvent {
  final bool force;
  LoadDataEvent({this.force = false});
  @override
  List<Object?> get props => [force];
}

class LoadMoreEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class UpdateFilterEvent extends HomeEvent {
  final ImageQueryFilter filter;
  UpdateFilterEvent({required this.filter});
  @override
  List<Object?> get props => [filter];
}

class UpdateViewModeEvent extends HomeEvent {
  final String viewMode;
  UpdateViewModeEvent({required this.viewMode});
  @override
  List<Object?> get props => [viewMode];
}