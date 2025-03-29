part of 'library_list_bloc.dart';

abstract class LibraryListEvent extends Equatable {
  const LibraryListEvent();
}

class LoadDataEvent extends LibraryListEvent {
  final bool force;

  const LoadDataEvent({required this.force});

  @override
  List<Object?> get props => [force];
}

class LoadMoreEvent extends LibraryListEvent {
  const LoadMoreEvent();

  @override
  List<Object?> get props => [];
}

class CreateLibraryEvent extends LibraryListEvent {
  final String libraryName;

  const CreateLibraryEvent({required this.libraryName});

  @override
  List<Object?> get props => [libraryName];
}