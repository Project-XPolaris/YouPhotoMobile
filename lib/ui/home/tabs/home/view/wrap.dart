import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/components/PhotoFilter.dart';
import 'package:youphotomobile/ui/components/ScreenWidthSelector.dart';
import 'package:youphotomobile/ui/home/layout.dart';

import '../bloc/home_bloc.dart';
import 'vertical.dart';

class TabHomeWrap extends StatelessWidget {
  const TabHomeWrap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TabHomeBloc()..add(const LoadDataEvent()),
      child: BlocBuilder<TabHomeBloc, TabHomeState>(
        builder: (context, state) {
          return HomeLayout(
            child: Scaffold(
              body: const ScreenWidthSelector(
                verticalChild: TabHomeVerticalPage(),
              ),
              floatingActionButton: !state.selectMode?FloatingActionButton(
                heroTag: "hometab",
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext modalContext) {
                        return PhotoFilterView(
                          filter: state.filter,
                          onFilterChange: (filter) {
                            context
                                .read<TabHomeBloc>()
                                .add(UpdateFilterEvent(filter: filter));
                          },
                        );
                      });
                },
                child: const Icon(Icons.filter_list),
              ):null,
            ),
            actions: [
              PopupMenuButton<String>(icon: const Icon(Icons.view_column), onSelected: (value) {
                var newGridSize = 130;
                switch (value) {
                  case "large":
                    newGridSize = 170;
                    break;
                  case "medium":
                    newGridSize = 130;
                    break;
                  case "small":
                    newGridSize = 100;
                    break;
                }
                context.read<TabHomeBloc>().add(UpdateGridSizeEvent(gridSize: newGridSize));
              }, itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: "large",
                    child: Text('Large'),
                  ),
                  const PopupMenuItem(
                    value: "medium",
                    child: Text('Medium'),
                  ),
                  const PopupMenuItem(
                    value: "small",
                    child: Text('Small'),
                  ),
                ];
              }),
              PopupMenuButton<String>(icon: const Icon(Icons.apps), onSelected: (value) {
                context.read<TabHomeBloc>().add(OnUpdateImageFitEvent(fit: value));
              }, itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: "cover",
                    child: Text('Cover'),
                  ),
                  const PopupMenuItem(
                    value: "contain",
                    child: Text('Contain'),
                  ),
                ];
              }),
            ],
          );
        },
      ),
    );
  }
}
