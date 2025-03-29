import '../config.dart';
import 'base.dart';
import 'client.dart';
import 'loader.dart';

class Album {
  int? id;
  String? name;
  int? cover;

  Album.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    cover = json['cover'];
  }

  String get displayName => name ?? 'Unknown';

  String? get thumbnailUrl {
    if (cover == null) {
      return null;
    }
    return "${ApplicationConfig().serviceUrl}/image/$cover/thumbnail?a=${ApplicationConfig().token ?? ""}";
  }
}

class AlbumLoader extends ApiDataLoader<Album> {
  @override
  Future<ListResponseWrap<Album>> fetchData(Map<String, dynamic> params) {
    return ApiClient().fetchAlbumList(params);
  }
}
