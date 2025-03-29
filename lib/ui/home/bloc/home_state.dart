part of 'home_bloc.dart';

class HomeState extends Equatable {
  final tabIndex;
  const HomeState({required this.tabIndex});

  @override
  List<Object?> get props => [tabIndex];
}

class HomeInitial extends HomeState {
  const HomeInitial() : super(tabIndex: 0);
}
