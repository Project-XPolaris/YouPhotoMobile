

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  Future<ListResponseWrap<PhotoTag>> fetchTagList(
      Map<String, dynamic> params) async {
    var response = await _dio.get("/tags", queryParameters: params);
    ListResponseWrap<PhotoTag> responseBody = ListResponseWrap.fromJson(
        response.data, (data) => PhotoTag.fromJson(data));
    return responseBody;
  }

  Future removeAlbum(int albumId) async {
    await _dio.delete("/album/$albumId");
  }
  Future<Photo> uploadImage (Uint8List file,String filename,int libraryId ) async {
    MultipartFile multipartFile = MultipartFile.fromBytes(file, filename: filename);
    FormData formData = FormData.fromMap({
      "file": multipartFile,
    });
    var response = await _dio.post("/image/upload", data: formData,queryParameters: {
      "filename": filename,
      "libraryId": libraryId
    });
    Photo responseBody = Photo.fromJson(response.data);
    return responseBody;
  }
  Future<Photo> fetchImage(int imageId) async {
    var response = await _dio.get("/image/$imageId");
    Photo responseBody = Photo.fromJson(response.data["data"]);
    return responseBody;
  }
  ApiClient._internal();
}
