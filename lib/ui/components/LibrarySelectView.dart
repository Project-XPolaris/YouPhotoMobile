import 'package:flutter/material.dart';
import 'package:youphotomobile/api/client.dart';

import '../../api/library.dart';

class LibrarySelectView extends StatefulWidget {
  final Function({required Library library})? onSelected;
  const LibrarySelectView({Key? key,required this.onSelected}) : super(key: key);
  @override
  State<LibrarySelectView> createState() => _LibrarySelectViewState();
}

class _LibrarySelectViewState extends State<LibrarySelectView> {
  List<Library> items = [];
   loadLibrary() async{
    var response = await ApiClient().fetchLibraryList({
      "pageSize":1000
    });
    setState(() {
      items = response.result;
    });
  }
  @override
  void initState() {
    loadLibrary();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text("Select library")
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                return ListTile(
                  title: Text(item.displayName),
                  leading: Icon(Icons.photo_library),
                  onTap: () {
                    widget.onSelected!(library: item);
                    Navigator.pop(context);
                  },
                  contentPadding: EdgeInsets.all(0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
