import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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
      create: (context) => TabHomeBloc()..add(LoadDataEvent()),
      child: BlocBuilder<TabHomeBloc, TabHomeState>(
        builder: (context, state) {
          return HomeLayout(
            child: Scaffold(
              body: const ScreenWidthSelector(
                verticalChild: TabHomeVerticalPage(),
              ),
              floatingActionButton: FloatingActionButton(
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
                child: Icon(Icons.filter_list),
              ),
            ),
            actions: [
              PopupMenuButton<String>(icon: Icon(Icons.view_column), onSelected: (value) {
                context.read<TabHomeBloc>().add(UpdateViewModeEvent(viewMode: value));
              }, itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: "large",
                    child: Text('Large'),
                  ),
                  PopupMenuItem(
                    value: "medium",
                    child: Text('Medium'),
                  ),
                  PopupMenuItem(
                    value: "small",
                    child: Text('Small'),
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
