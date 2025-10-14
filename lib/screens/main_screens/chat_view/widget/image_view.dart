import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:http/http.dart' as http;
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/utils/app_colors.dart';

class ImageView extends StatelessWidget {
  final String url;
  ImageView(this.url);

  Future<void> _saveImage() async {
    try {
      EasyLoading.show(status: 'Saving image...');
      
      // Download image
      final response = await http.get(Uri.parse(url));
      
      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        response.bodyBytes,
        quality: 100,
        name: 'image_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      EasyLoading.dismiss();
      
      if (result['isSuccess'] == true) {
        EasyLoading.showSuccess('Image saved to gallery!');
      } else {
        throw Exception('Failed to save image');
      }
      
      log('Image saved: $result');
    } catch (e) {
      log('Error saving image: $e');
      EasyLoading.dismiss();
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to save image to gallery",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

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
          // Save button
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.only(right: 18, top: 10),
                child: InkWell(
                  onTap: _saveImage,
                  child: Container(
                    decoration: ContainerProperties.simpleDecoration(
                        radius: 10, color: AppColors.primaryColor),
                    alignment: Alignment.center,
                    height: ht(37),
                    width: wd(37),
                    child: Icon(
                      Icons.download,
                      color: AppColors.colorWhite,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
