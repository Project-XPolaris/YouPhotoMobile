import 'base.dart';
import 'client.dart';
import 'loader.dart';

class Album {
  int? id;
  String? name;

  Album.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
  String get displayName => name ?? 'Unknown';
}

class AlbumLoader extends ApiDataLoader<Album> {
  @override
  Future<ListResponseWrap<Album>> fetchData(Map<String, dynamic> params) {
    return ApiClient().fetchAlbumList(params);
  }
}