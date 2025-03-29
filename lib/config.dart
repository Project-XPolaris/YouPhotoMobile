import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
class Config {
  String? viewerMode;
  int? imageGridSize;
  int? albumGridSize;
  String? homeImageFitMode;
  String? localImageFitMode;
  Config.fromJson(Map<String, dynamic> json) {
    viewerMode = json['viewerMode'];
    imageGridSize = json['imageGridSize'];
    albumGridSize = json['albumGridSize'];
    homeImageFitMode = json['homeImageFitMode'] ?? "cover";
    localImageFitMode = json['localImageFitMode'] ?? "cover";
  }
  toJson() {
    return {
      "viewerMode": viewerMode,
      "imageGridSize": imageGridSize,
      "albumGridSize": albumGridSize,
      "homeImageFitMode": homeImageFitMode,
      "localImageFitMode": localImageFitMode,
    };
  }
  Config();
  String get viewerModeValue{
    if (viewerMode == null) {
      return "auto";
    }
    return viewerMode!;
  }
  int get imageGridSizeValue{
    if (imageGridSize == null) {
      return 120;
    }
    return imageGridSize!;
  }
  int get albumGridSizeValue{
    if (albumGridSize == null) {
      return 120;
    }
    return albumGridSize!;
  }
}
class ApplicationConfig {
  static final ApplicationConfig _singleton = ApplicationConfig._internal();
  String? serviceUrl;
  String? token;
  factory ApplicationConfig() {
    return _singleton;
  }
  late Config config;


  ApplicationConfig._internal();

  Future<bool> loadConfig() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    serviceUrl = sharedPreferences.getString("apiUrl");

    return true;
  }
  Future loadAppConfig() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var rawConfigString  = sharedPreferences.getString("config");
    if (rawConfigString == null) {
      config = Config();
    }else{
      config = Config.fromJson(Map<String, dynamic>.from(jsonDecode(rawConfigString)));
    }
  }

  Future<bool> checkConfig() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isExist = sharedPreferences.containsKey("apiUrl");
    if (!isExist) {
      return false;
    }
    return true;
  }

  updateConfig() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String raw = jsonEncode(config.toJson());
    sharedPreferences.setString("config", raw);
  }
}
