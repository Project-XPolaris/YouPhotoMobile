import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OfflineAwareImage extends StatelessWidget {
  final String imageUrl;
  final int photoId;
  final bool isOffline;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String cachePostfix;
  final bool showAnimated;

  const OfflineAwareImage({
    Key? key,
    required this.imageUrl,
    required this.photoId,
    required this.isOffline,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cachePostfix = 'thumb',
    this.showAnimated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: 300,
      memCacheHeight: 300,
      maxWidthDiskCache: 300,
      maxHeightDiskCache: 300,
      cacheKey: '${photoId}_$cachePostfix',
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error),
      ),
      fadeInDuration:
          showAnimated ? const Duration(milliseconds: 300) : Duration.zero,
      fadeOutDuration:
          showAnimated ? const Duration(milliseconds: 300) : Duration.zero,
      useOldImageOnUrlChange: true,
    );
  }
}
