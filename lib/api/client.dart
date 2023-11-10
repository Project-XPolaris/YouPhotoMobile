

import 'package:dio/dio.dart';
import 'package:youphotomobile/api/image.dart';
import 'package:youphotomobile/api/library.dart';

import '../config.dart';
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

  ApiClient._internal();
}
