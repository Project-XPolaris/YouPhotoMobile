import 'package:youphotomobile/api/base.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/api/loader.dart';
import 'package:youphotomobile/config.dart';

class Photo {
  int? id;
  String? name;
  String? thumbnail;
  String? createdAt;
  String? updatedAt;

  Photo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    thumbnail = json['thumbnail'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  get thumbnailUrl {
    return "${ApplicationConfig().serviceUrl}/image/${id}/thumbnail?a=${ApplicationConfig().token}";
  }
  get rawUrl {
    return "${ApplicationConfig().serviceUrl}/image/${id}/raw?a=${ApplicationConfig().token}";
  }
}

class PhotoLoader extends ApiDataLoader<Photo> {
  @override
  Future<ListResponseWrap<Photo>> fetchData(Map<String, String> params) {
    return ApiClient().fetchImageList(params);
  }
}
