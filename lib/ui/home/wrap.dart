import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:youui/components/navigation.dart';
import 'package:youui/layout/home/home.dart';

import 'appbar.dart';
import 'bloc/home_bloc.dart';
import 'content.dart';

class HomePageWrap extends StatelessWidget {
  const HomePageWrap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return HomePageContent();
        },
      ),
    );
  }
}
