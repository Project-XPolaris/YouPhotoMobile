import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/bloc/app_bloc.dart';
import 'package:youphotomobile/ui/widgets/sync_task_bottom_sheet.dart';

import 'bloc/home_bloc.dart';

class HomeLayout extends StatelessWidget {
  final List<Widget> actions;
  final Widget child;

  const HomeLayout({Key? key, required this.child, this.actions = const []})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 600;
    return BlocBuilder<AppBloc, AppState>(
      builder: (appContext, appState) {
        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("YouPhoto"),
                elevation: 0,
                actions: [
                  // 添加任务列表按钮
                  IconButton(
                    icon: Badge(
                      label: Text(appState.syncQueue.length.toString()),
                      isLabelVisible: appState.syncQueue.isNotEmpty,
                      child: const Icon(Icons.sync),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const SyncTaskBottomSheet(),
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                      );
                    },
                  ),
                  ...actions,
                ],
              ),
              body: Container(
                  child: Row(
                children: [
                  isWideScreen
                      ? NavigationRail(
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.home_rounded),
                              label: Text("Home"),
                            ),
                            NavigationRailDestination(
                                icon: Icon(Icons.apps), label: Text("Library")),
                            NavigationRailDestination(
                              icon: Icon(Icons.person_rounded),
                              label: Text("User"),
                            ),
                          ],
                          selectedIndex: state.tabIndex,
                          onDestinationSelected: (index) {
                            context
                                .read<HomeBloc>()
                                .add(IndexChangedEvent(index: index));
                          },
                        )
                      : Container(),
                  Expanded(child: child)
                ],
              )),
              bottomNavigationBar: isWideScreen
                  ? null
                  : Wrap(
                      children: [
                        BottomNavigationBar(
                          items: const [
                            BottomNavigationBarItem(
                                icon: Icon(Icons.home_rounded), label: "Home"),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.apps), label: "Library"),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.person_rounded),
                                label: "User"),
                          ],
                          currentIndex: state.tabIndex,
                          onTap: (index) {
                            context
                                .read<HomeBloc>()
                                .add(IndexChangedEvent(index: index));
                          },
                          selectedItemColor:
                              Theme.of(context).colorScheme.primary,
                          unselectedItemColor:
                              Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}
