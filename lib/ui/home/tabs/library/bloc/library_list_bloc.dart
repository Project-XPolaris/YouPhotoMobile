import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../api/library.dart';

part 'library_list_event.dart';
part 'library_list_state.dart';

class LibraryListBloc extends Bloc<LibraryListEvent, LibraryListState> {
  final LibraryLoader _libraryLoader = LibraryLoader();
  LibraryListBloc() : super(LibraryListInitial(libraryList: [])) {
    on<LoadDataEvent>((event, emit) async {
      await _libraryLoader.loadData(force: event.force);
      emit(LibraryListState(libraryList: [..._libraryLoader.list]));
    });
    on<LoadMoreEvent>((event, emit) async {
      if (await _libraryLoader.loadMore()){
        emit(LibraryListState(libraryList: [..._libraryLoader.list]));
      }
    });
  }
}
