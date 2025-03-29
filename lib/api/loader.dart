import 'base.dart';

abstract class ApiDataLoader<T> {
  List<T> list = [];
  bool firstLoad = true;
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  int pageSize = 30;

  Future<bool> loadData(
      {Map<String, dynamic> extraFilter = const {}, force = false}) async {
    if ((!firstLoad || isLoading || !hasMore) && !force) {
      return false;
    }
    firstLoad = false;
    isLoading = true;
    page = 1;
    pageSize = 30;
    Map<String, String> queryParams = {
      "page": page.toString(),
      "pageSize": pageSize.toString()
    };
    Map<String,dynamic> params = Map.from(queryParams);
    params.addAll(extraFilter);
    var response = await fetchData(params);
    list = response.result;
    hasMore = list.length < response.getTotal();
    page = page;
    pageSize = response.getPageSize();
    isLoading = false;
    return true;
  }

  Future<bool> loadMore({Map<String, dynamic> extraFilter = const {}}) async {
    if (!hasMore || isLoading) {
      return false;
    }
    isLoading = true;
    Map<String, String> queryParams = {
      "page": (page + 1).toString(),
      "pageSize": pageSize.toString()
    };
    Map<String, dynamic> params = Map.from(queryParams);
    params.addAll(extraFilter);
    var response = await fetchData(params);
    list.addAll(response.result);
    hasMore = response.getPage() * response.getPageSize() < response.getTotal();
    page = response.getPage();
    pageSize = response.getPageSize();
    isLoading = false;
    return true;
  }
  Future<ListResponseWrap<T>> fetchData(Map<String, dynamic> params);
}
