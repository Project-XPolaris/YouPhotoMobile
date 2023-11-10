import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youui/components/filter.dart';

import '../../api/library.dart';
import '../home/tabs/home/bloc/home_bloc.dart';

class PhotoFilterView extends StatefulWidget {
  final ImageQueryFilter filter;
  final Function onFilterChange;

  PhotoFilterView(
      {Key? key, required this.filter, required this.onFilterChange})
      : super(key: key);

  @override
  State<PhotoFilterView> createState() => _PhotoFilterViewState(filter: filter);
}

class _PhotoFilterViewState extends State<PhotoFilterView> {
  ImageQueryFilter filter;
  List<Library> libraries = [];
  List<String> filterTags = [];
  bool isEditTagMode = false;
  _PhotoFilterViewState({required this.filter});

  loadLibraryList() async {
    var response = await ApiClient().fetchLibraryList({"pageSize": "10000"});
    setState(() {
      libraries = response.result;
    });
  }

  loadSaveTagFilterList() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      filterTags = sharedPreferences.getStringList("saveTagFilterList") ?? [];
    });
  }

  onAddTag(String tag) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var list = sharedPreferences.getStringList("saveTagFilterList") ?? [];
    list.add(tag);
    sharedPreferences.setStringList("saveTagFilterList", list);
    setState(() {
      filterTags = list;
    });
  }

  onRemoveTag(String tag) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var list = sharedPreferences.getStringList("saveTagFilterList") ?? [];
    list.remove(tag);
    sharedPreferences.setStringList("saveTagFilterList", list);
    setState(() {
      filterTags = list;
    });
  }

  @override
  void initState() {
    loadLibraryList();
    loadSaveTagFilterList();
  }

  @override
  Widget build(BuildContext context) {
    String getOrder() {
      if (filter.random) {
        return "random";
      }
      return filter.order;
    }

    List<String> getSelectLibrary() {
      if (filter.libraryIds.isEmpty) {
        return ["all"];
      }
      return filter.libraryIds;
    }

    return FilterView(
      title: "Photo Filter",
      children: [
        SigleSelectFilterView(
          textBoxPadding: EdgeInsets.only(left: 16, right: 16),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          value: getOrder(),
          onSelectChange: (option) async {
            ImageQueryFilter newFilter = widget.filter;
            if (option.key == "random") {
              newFilter = newFilter.copyWith(random: true);
            } else {
              newFilter = newFilter.copyWith(order: option.key, random: false);
            }
            setState(() {
              filter = newFilter;
            });
            widget.onFilterChange(newFilter);
          },
          title: "Order",
          options: [
            SelectOption(label: "Add date asc", key: "id asc"),
            SelectOption(label: "Add date desc", key: "id desc"),
            SelectOption(label: "Random", key: "random"),
          ],
          chipContentPadding: EdgeInsets.all(4),
          chipContainerPadding: EdgeInsets.only(left: 8, right: 8),
          spacing: 4,
          runSpacing: 4,
        ),
        CheckChipFilterView(
            title: "Libraries",
            textBoxPadding: EdgeInsets.only(left: 16, right: 16),
            options: [
              SelectOption(label: "All", key: "all"),
              ...libraries.map((library) {
                return SelectOption(
                  label: library.name!,
                  key: "${library.id}",
                );
              }).toList()
            ],
            checked: getSelectLibrary(),
            onValueChange: (option, selected, newChecked) {
              ImageQueryFilter newFilter = widget.filter;
              if (option.key == "all") {
                newFilter = newFilter.copyWith(libraryIds: []);
              } else {
                newFilter = newFilter.copyWith(
                    libraryIds: newChecked
                        .where((element) => element != "all")
                        .toList());
              }
              setState(() {
                filter = newFilter;
              });
              widget.onFilterChange(newFilter);
            },
            selectedColor: Theme.of(context).colorScheme.primaryContainer),
        isEditTagMode
            ? Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Text(
                        "Tags",
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Wrap(
                        spacing: 2,
                        runSpacing: 2,
                        children: filterTags.map((tag) {
                          return Chip(
                            padding: EdgeInsets.all(2),
                            label: Text(tag),
                            onDeleted: () {
                              onRemoveTag(tag);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              )
            : CheckChipFilterView(
                runSpacing: 2,
                spacing: 2,
                textBoxPadding: EdgeInsets.only(left: 16, right: 16),
                chipContentPadding: EdgeInsets.all(4),
                chipContainerPadding: EdgeInsets.only(left: 8, right: 8),
                title: "Tags",
                options: [
                  ...filterTags.map((tag) {
                    return SelectOption(
                      label: tag,
                      key: tag,
                    );
                  }).toList()
                ],
                checked: filter.tag,
                onValueChange: (option, selected, newChecked) {
                  ImageQueryFilter newFilter = widget.filter;
                  newFilter = newFilter.copyWith(tag: newChecked);
                  setState(() {
                    filter = newFilter;
                  });
                  print(newFilter.tag);
                  widget.onFilterChange(newFilter);
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                extraChildren: [

                ],
              ),
        Row(
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    isEditTagMode = !isEditTagMode;
                  });
                },
                child: Text(isEditTagMode ? "Done" : "Edit Tag")),
            TextButton(
                onPressed: () {
                  // open text input dialog
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Add Tag"),
                          content: TextField(
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: "Tag",
                            ),
                            onSubmitted: (value) {
                              onAddTag(value);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      });
                },
                child: Text("Add Tag"))
          ],
        ),
      ],
    );
  }
}
