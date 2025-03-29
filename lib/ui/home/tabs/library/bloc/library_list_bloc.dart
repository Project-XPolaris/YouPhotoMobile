import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:youphotomobile/api/client.dart';

import '../../../../../api/library.dart';

part 'library_list_event.dart';
part 'library_list_state.dart';

class LibraryListBloc extends Bloc<LibraryListEvent, LibraryListState> {
  final LibraryLoader _libraryLoader = LibraryLoader();
  LibraryListBloc() : super(const LibraryListInitial(libraryList: [])) {
    on<LoadDataEvent>((event, emit) async {
      await _libraryLoader.loadData(force: event.force);
      emit(LibraryListState(libraryList: [..._libraryLoader.list]));
    });
    on<LoadMoreEvent>((event, emit) async {
      if (await _libraryLoader.loadMore()) {
        emit(LibraryListState(libraryList: [..._libraryLoader.list]));
      }
    });
    on<CreateLibraryEvent>((event, emit) async {
      await ApiClient().createLibrary({"name": event.libraryName});
      await _libraryLoader.loadData(force: true);
      emit(LibraryListState(libraryList: [..._libraryLoader.list]));
    });
  }
}
