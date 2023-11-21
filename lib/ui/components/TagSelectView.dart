import 'package:flutter/material.dart';
import 'package:youphotomobile/api/image.dart';

class TagSelectView extends StatefulWidget {
  const TagSelectView({Key? key, this.onTagSelect}) : super(key: key);
  final Function(PhotoTag)? onTagSelect;

  @override
  State<TagSelectView> createState() => _TagSelectViewState();
}

class _TagSelectViewState extends State<TagSelectView> {
  final PhotoTagLoader loader = PhotoTagLoader();
  List<PhotoTag> tags = [];

  searchTag(String tag) async {
    await loader.loadData(extraFilter: {"nameSearch": tag}, force: true);
    setState(() {
      tags = [...loader.list];
    });
  }

  String searchTagText = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Theme.of(context).colorScheme.primaryContainer),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search tag",
                    ),
                    onChanged: (text) {
                      setState(() {
                        searchTagText = text;
                      });
                    },
                  ),
                ),
                IconButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  icon: Icon(
                    Icons.search,
                  ),
                  onPressed: () {
                    searchTag(searchTagText);
                  },
                )
              ],
            ),
          ),
          Expanded(
              child: ListView(
            children: [
              searchTagText.isNotEmpty?ListTile(
                  title: Text(searchTagText),
                  onTap: () {
                    Navigator.pop(context, null);
                    if (widget.onTagSelect != null) {
                      widget.onTagSelect!(PhotoTag(tag: searchTagText));
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  )):Container(),
              for (var tag in tags)
                ListTile(
                  title: Text(tag.tag!),
                  onTap: () {
                    Navigator.pop(context, tag);
                    if (widget.onTagSelect != null) {
                      widget.onTagSelect!(tag);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                )
            ],
          ))
        ],
      ),
    );
  }
}
