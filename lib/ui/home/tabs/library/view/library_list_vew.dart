import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/components/CreateLibraryDialog.dart';
import 'package:youphotomobile/ui/home/layout.dart';
import 'package:youphotomobile/ui/home/tabs/library/bloc/library_list_bloc.dart';

import '../../../../../util/listview.dart';

class LibraryListView extends StatelessWidget {
  const LibraryListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeLayout(
        child: BlocProvider<LibraryListBloc>(
      create: (_) => LibraryListBloc()..add(const LoadDataEvent(force: false)),
      child: BlocBuilder<LibraryListBloc, LibraryListState>(
        builder: (context, state) {
          ScrollController controller = createLoadMoreController(
              () => context.read<LibraryListBloc>().add(const LoadMoreEvent()));
          onCreateLibrary(String libraryName) {
            context.read<LibraryListBloc>().add(CreateLibraryEvent(libraryName: libraryName));
          }
          return Scaffold(
            body: Container(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<LibraryListBloc>().add(const LoadDataEvent(force: true));
                  },
                  child: ListView(
                    controller: controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      for (var item in state.libraryList)
                        ListTile(
                          title: Text(item.displayName),
                          leading: CircleAvatar(
                            backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              item.displayName.substring(0, 1),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                            ),
                          ),
                        )
                    ],
                  )),
                ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(context: context, builder: (context) => CreateLibraryDialog(
                  onConfirm: (libraryName) {
                    onCreateLibrary(libraryName);
                  },
                ));
              },
              child: const Icon(Icons.add),
            )
          );
        },
      ),
    ));
  }
}
