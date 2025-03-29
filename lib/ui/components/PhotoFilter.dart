import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/ui/components/TagSelectView.dart';
import 'package:youui/components/filter.dart';

import '../../api/library.dart';
import '../home/tabs/home/bloc/home_bloc.dart';

class PhotoFilterView extends StatefulWidget {
  final ImageQueryFilter filter;
  final Function onFilterChange;

  const PhotoFilterView(
      {Key? key, required this.filter, required this.onFilterChange})
      : super(key: key);

  @override
  State<PhotoFilterView> createState() => _PhotoFilterViewState(filter: filter);
}

class _PhotoFilterViewState extends State<PhotoFilterView> {
  ImageQueryFilter filter;
  List<Library> libraries = [];
  List<String> filterTags = [];
  List<String> checkedTags = [];
  bool isEditTagMode = false;
  String selectedTab = "base";

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

    List<Widget> renderBaseFilters() {
      return [
        SigleSelectFilterView(
          textBoxPadding: const EdgeInsets.only(left: 16, right: 16),
          chipContainerPadding: const EdgeInsets.only(left: 16, right: 16),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          value: getOrder(),
          onSelectChange: (option) async {
            ImageQueryFilter newFilter = filter;
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
        ),
      ];
    }

    List<Widget> renderTagsFilters() {
      return [
        isEditTagMode
            ? Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 16, right: 16),
                              child: const Text(
                                "Tags",
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  isEditTagMode = !isEditTagMode;
                                });
                              },
                              icon: const Icon(Icons.done)),
                          IconButton(
                              onPressed: () {
                                // open text input dialog
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Add Tag"),
                                        content: SizedBox(
                                          width: 320,
                                          child: TagSelectView(
                                            onTagSelect: (tag) {
                                              String nameToAdd = tag.tag!;
                                              if (filterTags
                                                  .contains(nameToAdd)) {
                                                return;
                                              }
                                              onAddTag(tag.tag!);
                                            },
                                          ),
                                        ),
                                      );
                                    });
                              },
                              icon: const Icon(Icons.add)),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Wrap(
                        spacing: 2,
                        runSpacing: 2,
                        children: filterTags.map((tag) {
                          return Chip(
                            padding: const EdgeInsets.all(2),
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
                title: "Tags",
                actions: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              isEditTagMode = !isEditTagMode;
                            });
                          },
                          icon: const Icon(Icons.edit))
                    ],
                  ),
                ),
                textBoxPadding: const EdgeInsets.only(left: 16, right: 16),
                chipContainerPadding: const EdgeInsets.only(left: 16, right: 16),
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
                  ImageQueryFilter newFilter = filter;
                  newFilter = newFilter.copyWith(tag: newChecked);
                  setState(() {
                    filter = newFilter;
                  });
                  widget.onFilterChange(newFilter);
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
              ),
      ];
    }

    List<Widget> renderAdvanceFilters() {
      return [
        SigleSelectFilterView(
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          textBoxPadding: const EdgeInsets.only(left: 16, right: 16),
          chipContainerPadding: const EdgeInsets.only(left: 16, right: 16),
          value: filter.orient,
          onSelectChange: (option) async {
            ImageQueryFilter newFilter = filter;
            newFilter = newFilter.copyWith(orient: option.key);
            setState(() {
              filter = newFilter;
            });
            widget.onFilterChange(newFilter);
          },
          title: "Orientation",
          options: [
            SelectOption(label: "all", key: "all"),
            SelectOption(label: "landscape", key: "landscape"),
            SelectOption(label: "portrait", key: "portrait"),
            SelectOption(label: "square", key: "square"),
          ],
        ),
        SigleSelectFilterView(
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          textBoxPadding: const EdgeInsets.only(left: 16, right: 16),
          chipContainerPadding: const EdgeInsets.only(left: 16, right: 16),
          value: filter.resolution,
          onSelectChange: (option) async {
            ImageQueryFilter newFilter = filter;
            newFilter = newFilter.copyWith(resolution: option.key);
            setState(() {
              filter = newFilter;
            });
            widget.onFilterChange(newFilter);
          },
          title: "Resolution",
          options: [
            SelectOption(label: "all", key: "all"),
            SelectOption(label: "1080P", key: "1080"),
            SelectOption(label: "2K", key: "2k"),
            SelectOption(label: "4K", key: "4k"),
            SelectOption(label: "8K", key: "8k"),
          ],
        ),
      ];
    }

    List<Widget> renderLibraryFilters() {
      return [
        CheckChipFilterView(
            title: "Libraries",
            textBoxPadding: const EdgeInsets.only(left: 16, right: 16),
            chipContainerPadding: const EdgeInsets.only(left: 16, right: 16),
            options: [
              SelectOption(label: "All", key: "all"),
              ...libraries.map((library) {
                return SelectOption(
                  label: library.name!,
                  key: "${library.id}",
                );
              }).toList()
            ],
            actions: Row(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        filter = filter.copyWith(libraryIds: []);
                      });
                      widget.onFilterChange(filter);
                    },
                    icon: const Icon(Icons.clear)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        filter = filter.copyWith(
                            libraryIds:
                                libraries.map((e) => e.id.toString()).toList());
                      });
                      widget.onFilterChange(filter);
                    },
                    icon: const Icon(Icons.check)),
              ],
            ),
            checked: getSelectLibrary(),
            onValueChange: (option, selected, newChecked) {
              ImageQueryFilter newFilter = filter;
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
            selectedColor: Theme.of(context).colorScheme.primaryContainer)
      ];
    }

    return FilterView(
      title: "Photo Filter",
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              FilterChip(
                label: const Text("Base"),
                selected: selectedTab == "base",
                onSelected: (selected) {
                  setState(() {
                    selectedTab = "base";
                  });
                },
                showCheckmark: false,
              ),
              const SizedBox(width: 8), // Set the width to your desired spacing
              FilterChip(
                  label: const Text("Tags"),
                  showCheckmark: false,
                  selected: selectedTab == "tags",
                  onSelected: (selected) {
                    setState(() {
                      selectedTab = "tags";
                    });
                  }),
              const SizedBox(width: 8), // Set the width to your desired spacing

              FilterChip(
                  label: const Text("Library"),
                  showCheckmark: false,
                  selected: selectedTab == "library",
                  onSelected: (selected) {
                    setState(() {
                      selectedTab = "library";
                    });
                  }),
              const SizedBox(width: 8), // Set the width to your desired spacing
              FilterChip(
                  label: const Text("Advance"),
                  showCheckmark: false,
                  selected: selectedTab == "advance",
                  onSelected: (selected) {
                    setState(() {
                      selectedTab = "advance";
                    });
                  }),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ),
        if (selectedTab == "base") ...renderBaseFilters(),
        if (selectedTab == "tags") ...renderTagsFilters(),
        if (selectedTab == "advance") ...renderAdvanceFilters(),
        if (selectedTab == "library") ...renderLibraryFilters(),
      ],
    );
  }
}
