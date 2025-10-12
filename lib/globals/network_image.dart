import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageCustom extends StatelessWidget {
  final String? image;
  final double height;
  final double width;
  final BoxFit? fit;

  const NetworkImageCustom(
      {Key? key,
      this.height = double.infinity,
      this.width = double.infinity,
      required this.image,
      this.fit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        // placeholder: ((context, url) => Image.asset(AppImages.ic_place_holder)),

        imageUrl: image == null || image == ''
            ? 'https://firebasestorage.googleapis.com/v0/b/backpackers-aa063.appspot.com/o/images%2F2024-02-26%2016%3A12%3A39.599854?alt=media&token=79c58057-a893-4b5d-85f8-33050f49e50d'
            : image!,
        height: height,
        width: width,
        errorWidget: ((context, url, error) => Container()),
        fit: fit != null ? fit! : BoxFit.contain);
  }
}
