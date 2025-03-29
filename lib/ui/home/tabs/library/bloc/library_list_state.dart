part of 'library_list_bloc.dart';

class LibraryListState extends Equatable {
  final List<Library> libraryList;
  const LibraryListState({required this.libraryList});

  @override
  List<Object?> get props => [libraryList];
}

class LibraryListInitial extends LibraryListState {
  const LibraryListInitial({required List<Library> libraryList}) : super(libraryList: libraryList);
}
