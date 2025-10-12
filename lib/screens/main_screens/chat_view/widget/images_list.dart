import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:back_packers/screens/main_screens/chat_view/widget/image_view.dart';
import 'package:back_packers/utils/app_colors.dart';

class ImagesList extends StatelessWidget {
  final List<dynamic> images;
  ImagesList({required this.images});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: ListView.builder(
          itemCount: images.length,
          itemBuilder: (ctx, index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ImageView(images[index])));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                        color: Colors.grey,
                        backgroundColor: AppColors.primaryColor,
                        value: downloadProgress.progress),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            );
          }),
    );
  }
}
