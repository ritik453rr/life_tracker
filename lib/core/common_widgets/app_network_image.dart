import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/assets.dart';

/// Custom network image widget with caching and fallback.
class AppNetworkImage extends StatelessWidget {
  final String imgUrl;
  final double height;
  final double width;
  final double borderRadius;
  final BoxFit fit;

  const AppNetworkImage({
    super.key,
    this.imgUrl = "",
    this.height = 125,
    this.width = 125,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imgUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Container(
              height: height,
              width: width,
              color: Colors.white,
            ),
          );
        },
        errorWidget: (context, url, error) {
          return Image.asset(
            Assets.pngTriangleInsetHey,
            height: height,
            width: width,
            fit: fit,
          );
        },
      ),
    );
  }
}
