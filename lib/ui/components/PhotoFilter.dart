import 'package:flutter/material.dart';
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
  _PhotoFilterViewState({required this.filter});
  loadLibraryList()async {
    var response = await ApiClient().fetchLibraryList({"pageSize":"10000"});
    setState(() {
      libraries = response.result;
    });

  }
  @override
  void initState() {
    loadLibraryList();
  }

  @override
  Widget build(BuildContext context) {
    String getOrder() {
      if (filter.random) {
        return "random";
      }
      return filter.order;
    }
    List<String> getSelectLibrary(){
      if (filter.libraryIds.isEmpty) {
        return ["all"];
      }
      return filter.libraryIds;
    }
    return FilterView(
      title: "Photo Filter",
      children: [
        SigleSelectFilterView(
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          value: getOrder(),
          onSelectChange: (option) async {
            ImageQueryFilter newFilter = widget.filter;
            if (option.key == "random") {
              newFilter = newFilter.copyWith(random: true);
            } else {
              newFilter = newFilter.copyWith(order: option.key,random: false);
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
        CheckChipFilterView(
            title: "Libraries",
            options: [SelectOption(label: "All", key: "all"),...libraries.map((library) {
              return SelectOption(
                label: library.name!,
                key: "${library.id}",
              );
            }).toList()],
            checked: getSelectLibrary(),
            onValueChange: (option,selected,newChecked){
              ImageQueryFilter newFilter = widget.filter;
              if (option.key == "all") {
                newFilter = newFilter.copyWith(libraryIds: []);
              } else {
                newFilter = newFilter.copyWith(libraryIds: newChecked.where((element) => element != "all").toList());
              }
              setState(() {
                filter = newFilter;
              });
              widget.onFilterChange(newFilter);
            },
            selectedColor: Theme.of(context).colorScheme.primaryContainer
        )
      ],
    );
  }
}
