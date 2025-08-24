import 'package:youphotomobile/services/photo_cache_service.dart';

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
  final PhotoCacheService _cacheService = PhotoCacheService();

  @override
  Future<ListResponseWrap<Album>> fetchData(Map<String, dynamic> params) async {
    final isOffline = ApplicationConfig().isOffline;
    // 先从数据库获取数据
    final localAlbums = await _cacheService.getAllAlbums();

    // 如果是离线模式，直接返回本地数据
    if (isOffline) {
      return ListResponseWrap(
        count: localAlbums.length,
        result: localAlbums,
      );
    }

    try {
      // 从服务器获取数据
      final response = await ApiClient().fetchAlbumList(params);

      // 将获取到的数据保存到数据库
      if (response.result.isNotEmpty) {
        await _cacheService.insertAlbums(response.result);
      }

      return response;
    } catch (e) {
      // 如果获取失败，返回本地缓存数据
      return ListResponseWrap(
        count: localAlbums.length,
        result: localAlbums,
      );
    }
  }
}
