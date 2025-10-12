import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/utils/app_colors.dart';

class ImageView extends StatelessWidget {
  final String url;
  ImageView(this.url);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            height: double.infinity,
            width: double.infinity,
            child: InteractiveViewer(
                child: CachedNetworkImage(
              imageUrl: url,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                    backgroundColor: AppColors.primaryColor,
                    color: Colors.grey,
                    value: downloadProgress.progress),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Container(
                  child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 18, top: 10),
                    decoration: ContainerProperties.simpleDecoration(
                        radius: 10, color: AppColors.primaryColor),
                    alignment: Alignment.center,
                    height: ht(37),
                    width: wd(32),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.colorWhite,
                      size: 15,
                    ),
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
