import 'base.dart';
import 'client.dart';
import 'loader.dart';

class Library {
  int? id;
  String? name;

  Library.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
  String get displayName => name ?? 'Unknown';
}

class LibraryLoader extends ApiDataLoader<Library> {
  @override
  Future<ListResponseWrap<Library>> fetchData(Map<String, String> params) {
    return ApiClient().fetchLibraryList(params);
  }
}