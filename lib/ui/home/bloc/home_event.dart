part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class IndexChangedEvent extends HomeEvent {
final int index;
  IndexChangedEvent({required this.index});
  @override
  List<Object?> get props => [index];
}