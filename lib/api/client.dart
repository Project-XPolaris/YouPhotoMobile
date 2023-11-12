

import 'package:dio/dio.dart';
import 'package:youphotomobile/api/image.dart';
import 'package:youphotomobile/api/library.dart';

import '../config.dart';
import 'album.dart';
import 'base.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static Dio _dio = new Dio();

  factory ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        options.baseUrl = ApplicationConfig().serviceUrl ?? "";
        String token = ApplicationConfig().token ?? "";
        if (token.isNotEmpty) {
          options.headers = {"Authorization": "Bearer $token"};
        }
        handler.next(options);
      },
    ));
    return _instance;
  }

  Future<ListResponseWrap<Photo>> fetchImageList(
      Map<String, dynamic> params) async {
    var response = await _dio.get("/images", queryParameters: params);
    ListResponseWrap<Photo> responseBody = ListResponseWrap.fromJson(
        response.data, (data) => Photo.fromJson(data));
    return responseBody;
  }
  Future<ListResponseWrap<Library>> fetchLibraryList(
      Map<String, dynamic> params) async {
    var response = await _dio.get("/libraries", queryParameters: params);
    ListResponseWrap<Library> responseBody = ListResponseWrap.fromJson(
        response.data, (data) => Library.fromJson(data));
    return responseBody;
  }
  Future<ListResponseWrap<Album>> fetchAlbumList(
      Map<String, dynamic> params) async {
    var response = await _dio.get("/albums", queryParameters: params);
    ListResponseWrap<Album> responseBody = ListResponseWrap.fromJson(
        response.data, (data) => Album.fromJson(data));
    return responseBody;
  }

  Future<Album> createAlbum(Map<String, dynamic> params) async {
    var response = await _dio.post("/album", data: params);
    Album responseBody = Album.fromJson(response.data);
    return responseBody;
  }

  Future addImageToAlbum(int albumId, List<int> imageIds) async {
    await _dio.post("/album/$albumId/image", data: {
      "imageIds": imageIds
    });
  }
  Future removeImageFromAlbum(int albumId, List<int> imageIds) async {
    await _dio.delete("/album/$albumId/image", data: {
      "imageIds": imageIds
    });
  }
  Future deleteAlbum(int albumId) async {
    await _dio.delete("/album/$albumId");
  }


  ApiClient._internal();
}
