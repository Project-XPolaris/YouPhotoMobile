import 'package:flutter/material.dart';
import 'package:youphotomobile/api/image.dart';
class ImageQueryFilter {
  String order;
  bool random = false;
  List<String> libraryIds = [];
  ImageQueryFilter({required this.order});
}
class TabHomeProvider extends ChangeNotifier {
  ImageQueryFilter filter = new ImageQueryFilter(order: "id desc");

  PhotoLoader loader = new PhotoLoader();
  Map<String,String> _getExtraParams() {
    Map<String,String> result = {
      "order":filter.order,
      "pageSize":"50",
      "random":filter.random ? "1" : ""
    };
    if (filter.libraryIds.isNotEmpty) {
      for (var id in filter.libraryIds) {
        result["libraryId"] = id.toString();
      }
    }
    return result;
  }

  loadData({force = false}) async {
    if (await loader.loadData(force: force,extraFilter:_getExtraParams())) {
      notifyListeners();
    }
  }

  loadMore() async {
    if (await loader.loadMore(extraFilter: _getExtraParams())) {
      notifyListeners();
    }
  }
  updateFilter(ImageQueryFilter filter) async{
    this.filter = filter;
    await loadData(force: true);
  }
}