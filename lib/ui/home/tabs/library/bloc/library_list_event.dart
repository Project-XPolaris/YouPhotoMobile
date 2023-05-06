part of 'library_list_bloc.dart';

abstract class LibraryListEvent extends Equatable {
  const LibraryListEvent();
}

class LoadDataEvent extends LibraryListEvent {
  final bool force;

  LoadDataEvent({required this.force});

  @override
  List<Object?> get props => [force];
}

class LoadMoreEvent extends LibraryListEvent {
  LoadMoreEvent();

  @override
  List<Object?> get props => [];
}
