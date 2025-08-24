import 'dart:convert';
import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class Config {
  // 查看器模式
  String? viewerMode;
  // 图片网格大小
  int? imageGridSize;
  // 相册网格大小
  int? albumGridSize;
  // 主页图片适应模式
  String? homeImageFitMode;
  // 本地图片适应模式
  String? localImageFitMode;

  // 从JSON构造配置对象
  Config.fromJson(Map<String, dynamic> json) {
    viewerMode = json['viewerMode'];
    imageGridSize = json['imageGridSize'];
    albumGridSize = json['albumGridSize'];
    homeImageFitMode = json['homeImageFitMode'] ?? "cover";
    localImageFitMode = json['localImageFitMode'] ?? "cover";
  }

  // 转换为JSON格式
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

  // 获取查看器模式值，默认为"auto"
  String get viewerModeValue {
    if (viewerMode == null) {
      return "auto";
    }
    return viewerMode!;
  }

  // 获取图片网格大小，默认为120
  int get imageGridSizeValue {
    if (imageGridSize == null) {
      return 120;
    }
    return imageGridSize!;
  }

  // 获取相册网格大小，默认为120
  int get albumGridSizeValue {
    if (albumGridSize == null) {
      return 120;
    }
    return albumGridSize!;
  }
}

// 应用程序配置类（单例模式）
class ApplicationConfig {
  // 创建单例实例
  static final ApplicationConfig _singleton = ApplicationConfig._internal();
  // 服务器URL
  String? serviceUrl;
  // 用户令牌
  String? token;
  // 用户ID
  String? userId;
  // 会话ID
  String? sessionId;

  bool isOffline = true;

  // 工厂构造函数，返回单例实例
  factory ApplicationConfig() {
    return _singleton;
  }
  // 配置对象
  late Config config;

  // 私有构造函数
  ApplicationConfig._internal();

  // 加载配置
  Future<bool> loadConfig() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    serviceUrl = sharedPreferences.getString("apiUrl");
    token = sharedPreferences.getString("token");
    userId = sharedPreferences.getString("userId");
    sessionId = sharedPreferences.getString("sessionId");
    return true;
  }

  // 加载应用配置
  Future loadAppConfig() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var rawConfigString = sharedPreferences.getString("config");
    // 如果没有存储的配置，创建新的配置对象
    if (rawConfigString == null) {
      config = Config();
    } else {
      // 从存储的JSON字符串解析配置
      config = Config.fromJson(
          Map<String, dynamic>.from(jsonDecode(rawConfigString)));
    }
  }

  // 检查配置是否存在
  Future<bool> checkConfig() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isExist = sharedPreferences.containsKey("apiUrl");
    if (!isExist) {
      return false;
    }
    return true;
  }

  // 更新配置到持久化存储
  updateConfig() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String raw = jsonEncode(config.toJson());
    sharedPreferences.setString("config", raw);
  }

  // 保存服务器URL配置
  Future<bool> saveServiceUrl(String url) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    serviceUrl = url;
    return sharedPreferences.setString("apiUrl", url);
  }

  // 保存token配置
  Future<bool> saveToken(String newToken) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = newToken;
    return sharedPreferences.setString("token", newToken);
  }

  // 清除token
  Future<bool> clearToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = null;
    return sharedPreferences.remove("token");
  }

  // 保存用户ID
  Future<bool> saveUserId(String newUserId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userId = newUserId;
    return sharedPreferences.setString("userId", newUserId);
  }

  // 检查是否有历史登录信息
  Future<bool> hasLoginInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? savedToken = sharedPreferences.getString("token");
    return savedToken != null && savedToken.isNotEmpty;
  }

  // 生成并保存 sessionId
  Future<bool> generateAndSaveSessionId() async {
    if (serviceUrl == null || userId == null) {
      return false;
    }

    // 使用 URL 和 userId 生成唯一的 sessionId
    String rawSessionId = '$serviceUrl:$userId';
    sessionId = base64Encode(utf8.encode(rawSessionId));

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString("sessionId", sessionId!);
  }

  // 清除 sessionId
  Future<bool> clearSessionId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sessionId = null;
    return sharedPreferences.remove("sessionId");
  }
}
