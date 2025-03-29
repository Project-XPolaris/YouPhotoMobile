import 'package:youphotomobile/api/base.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/api/loader.dart';
import 'package:youphotomobile/config.dart';

// {
// "tag": "1girl",
// "source": "auto",
// "rank": 1,
// "imageId": 72
// }
class PhotoTag {
  String? tag;
  String? source;
  double? rank;
  int? imageId;

  PhotoTag.fromJson(Map<String, dynamic> json) {
    tag = json['tag'];
  }

  PhotoTag({this.tag});
}

// {
// "value": "#30261f",
// "imageId": 72,
// "percent": 0.21460176991150443,
// "rank": 0,
// "cnt": 1940
// },
class PhotoColor {
  String? value;
  int? imageId;
  double? percent;
  int? rank;
  int? cnt;

  PhotoColor.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    imageId = json['imageId'];
    percent = double.parse(json['percent'].toString());
    rank = json['rank'];
    cnt = json['cnt'];
  }
}
// "country": "France",
// "administrativeArea1": "Île-de-France",
// "administrativeArea2": "Département de Paris",
// "locality": "Paris",
// "route": "Quai François Mitterrand",
// "streetNumber": "4",
// "address": "4 Quai François Mitterrand, 75001 Paris, France"
class Photo {
  int? id;
  String? name;
  String? thumbnail;
  String? createdAt;
  String? updatedAt;
  String? blurHash;
  int? width;
  int? height;
  double? lat;
  double? lng;
  String? md5;
  List<PhotoTag> tag = [];
  List<PhotoColor> imageColors = [];
  late int libraryId;
  String? address;
  String? country;
  String? administrativeArea1;
  String? administrativeArea2;
  String? locality;
  String? route;
  String? streetNumber;
  String? premise;
  Function(int)? onIndexChange;

  Photo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    thumbnail = json['thumbnail'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    width = json['width'];
    height = json['height'];
    md5 = json['md5'];
    blurHash = json['blurHash'];
    if (json['tag'] != null) {
      tag = [];
      json['tag'].forEach((v) {
        tag.add(PhotoTag.fromJson(v));
      });
    }
    if (json['imageColors'] != null) {
      imageColors = [];
      json['imageColors'].forEach((v) {
        imageColors.add(PhotoColor.fromJson(v));
      });
    }
    lat = json['lat'];
    lng = json['lng'];
    libraryId = json['libraryId'] ?? 0;
    address = json['address'];
    country = json['country'];
    administrativeArea1 = json['administrativeArea1'];
    administrativeArea2 = json['administrativeArea2'];
    locality = json['locality'];
    route = json['route'];
    streetNumber = json['streetNumber'];
    premise = json['premise'];
  }

  get thumbnailUrl {
    final token = ApplicationConfig().token;
    return "${ApplicationConfig().serviceUrl}/thumbnail/$thumbnail?a=${ApplicationConfig().token ?? ""}";
  }

  get rawUrl {
    return "${ApplicationConfig().serviceUrl}/image/$id/raw?a=${ApplicationConfig().token ?? ""}";
  }
}

class PhotoLoader extends ApiDataLoader<Photo> {
  @override
  Future<ListResponseWrap<Photo>> fetchData(Map<String, dynamic> params) {
    return ApiClient().fetchImageList(params);
  }
}

class PhotoTagLoader extends ApiDataLoader<PhotoTag> {
  @override
  Future<ListResponseWrap<PhotoTag>> fetchData(Map<String, dynamic> params) {
    return ApiClient().fetchTagList(params);
  }
}
