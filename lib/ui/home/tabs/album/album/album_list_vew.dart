import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/home/layout.dart';
import 'package:youui/components/gridview.dart';

import '../../../../../util/listview.dart';
import '../../../../album/view/album_view.dart';
import '../bloc/album_bloc.dart';

class AlbumView extends StatefulWidget {
  const AlbumView({Key? key}) : super(key: key);

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  String inputAlbumName = "";
  @override
  Widget build(BuildContext context) {
    return HomeLayout(
        child: BlocProvider<AlbumBloc>(
      create: (_) => AlbumBloc()..add(LoadDataEvent(force: false)),
      child: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          ScrollController controller = createLoadMoreController(() =>
              context.read<AlbumBloc>().add(LoadMoreEvent()));
          onCreateAlbum(String name) {
            print("CreateAlbumEvent");
            context.read<AlbumBloc>().add(CreateAlbumEvent(name: name));
          }
          return Scaffold(
            body: Container(
              margin: const EdgeInsets.only(top: 16),
              child:RefreshIndicator(
                onRefresh: (){
                  context.read<AlbumBloc>().add(LoadDataEvent(force: true));
                  return Future.delayed(Duration(seconds: 1));
                },
                child: GridView.builder(
                  controller: controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.albumList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Container(
                        child: Column(
                          children:[
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.photo_album,color:  Theme.of(context).colorScheme.onPrimaryContainer,size: 48
                                    ,),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: Text(state.albumList[index].displayName),
                            )
                          ]
                        )
                      ),
                      onTap: (){
                        AlbumDetailView.Launch(context, state.albumList[index]);
                      }
                    );
                  },
                ),
              )
                ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Create album"),
                        content:TextField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'album Name'),
                          onChanged: (value) {
                            setState(() {
                              inputAlbumName = value;
                            });
                          }
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel")),
                          TextButton(
                              onPressed: () {
                                print(inputAlbumName);
                                onCreateAlbum(inputAlbumName);
                                Navigator.of(context).pop();

                              },
                              child: Text("Create"))
                        ],
                      );
                    });
              },
              child: Icon(Icons.add),
            )
          );
        },
      ),
    ));
  }
}
