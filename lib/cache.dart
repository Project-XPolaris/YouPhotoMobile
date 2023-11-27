import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

Future<Uint8List> cacheImageWithHash(String imageUrl, String hash,String fileName) async {
  final cacheManager = DefaultCacheManager();
  final fileInfo = await cacheManager.getFileFromCache(hash);

  if (fileInfo != null) {
    final cachedBytes = await fileInfo.file.readAsBytes();
    return cachedBytes;
  }

  // If the image is not in the cache or the hash doesn't match, fetch the image
  final response = await http.get(Uri.parse(imageUrl));
  final bytes = response.bodyBytes;

  // Cache the fetched image
  await cacheManager.putFile(hash, bytes, fileExtension: fileName.split(".").last);

  return bytes;
}
