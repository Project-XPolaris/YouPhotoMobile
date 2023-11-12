import 'package:flutter/material.dart';
import 'package:youphotomobile/api/album.dart';

class AlbumSelectView extends StatefulWidget {
  AlbumSelectView({Key? key, this.onSelect}) : super(key: key);
  Function(Album)? onSelect;
  @override
  State<AlbumSelectView> createState() => _AlbumSelectViewState();
  final AlbumLoader loader = AlbumLoader();
}

class _AlbumSelectViewState extends State<AlbumSelectView> {
  List<Album> list = [];
  @override
  void initState() {
    loadDate();
    super.initState();
  }
  void loadDate() async {
    await widget.loader.loadData(extraFilter: {"pageSize": "10000"});
    setState(() {
      list = widget.loader.list;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select album",style: TextStyle(fontSize: 16),),
          Expanded(child: Container(
            margin: EdgeInsets.only(top: 16),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemBuilder: (context, index) {
                Album item = list[index];
                return GestureDetector(
                  child: Container(
                      child:Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Center(
                                child: Icon(Icons.photo_album),
                              ),
                            ),
                          ),
                          Text(item.displayName)
                        ],
                      )
                  ),
                  onTap: () {
                    widget.onSelect?.call(item);
                    Navigator.pop(context);
                  },
                );
              }, itemCount: list.length,
            ),
          ))
        ],
      ),
    );
  }
}
