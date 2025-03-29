import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/home_bloc.dart';

class HomeLayout extends StatelessWidget {
  final List<Widget> actions;
  final Widget child;

  const HomeLayout({Key? key, required this.child, this.actions = const []})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 600;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("YouPhoto"),
            elevation: 0,
            actions: actions,
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
                            icon: Icon(Icons.person_rounded), label: "User"),
                      ],
                      currentIndex: state.tabIndex,
                      onTap: (index) {
                        context
                            .read<HomeBloc>()
                            .add(IndexChangedEvent(index: index));
                      },
                      selectedItemColor: Theme.of(context).colorScheme.primary,
                      unselectedItemColor:
                          Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
