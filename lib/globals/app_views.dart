import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/loader/three_bounce.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';

import 'global.dart';

class AppViews {
  // App bar inti

  // Show Center Loading
  static showLoading() {
    return Center(
      child: SpinKitThreeBounce(color: AppColors.primaryColor, size: 34),
    );
  } // Show Footer Loading Icon

  static Widget showLoadingCustom(bool show) {
    return Visibility(
      visible: show,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white38,
        child: Center(
          child: SpinKitThreeBounce(color: AppColors.orangeColor, size: 34),
        ),
      ),
    );
  } // Show Footer Loading Icon

  static showLoadingWithStatus(bool isShowLoader) {
    return isShowLoader
        ? Container(
            child: AppViews.showLoading(),
            color: Colors.white70,
          )
        : const SizedBox(
            height: 0,
            width: 0,
          );
  } // Show Footer Loading Icon

  static showFooterLoading(bool isProgressBarBottomShown) {
    if (isProgressBarBottomShown) {
      return SizedBox(
        height: 34,
        child: Center(
          child: SpinKitThreeBounce(
            color: AppColors.primaryColor,
            size: 34,
          ),
        ),
      );
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
  }

  static getRoundBorder(
      {required Color cBoxBgColor,
      required Color cBorderColor,
      required double dRadius,
      required double dBorderWidth}) {
    return BoxDecoration(
      color: cBoxBgColor,
      borderRadius: BorderRadius.circular(dRadius),
      border: Border.all(
        width: dBorderWidth,
        color: cBorderColor,
      ),
    );
  }

  static getErrorImage(double mHeight, double mWidth) {
    return Image.asset('', height: mHeight, width: mWidth, fit: BoxFit.contain);
  }

  static getProgressImage(double mHeight, double mWidth) {
    return SizedBox(
      width: 200.0,
      height: 100.0,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
            decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        )),
      ),
    );
  }

  static getSetDataWithReturn(BuildContext context, ShowData mShowData,
      Widget showWidget, String onReturn) {
    Widget widgetM = Container();

    switch (mShowData) {
      case ShowData.showLoading:
        widgetM = Container(
          child: AppViews.showLoading(),
          color: Theme.of(context).colorScheme.surface,
        );
        break;

      case ShowData.showData:
        widgetM = showWidget;

        break;
      case ShowData.showNoDataFound:
        widgetM = Center(
          child: Text(
            onReturn,
            textAlign: TextAlign.center,
          ),
        );

        break;
      case ShowData.showError:
        widgetM = const Text('Error');
        break;
    }

    return widgetM;
  }

  static getBorderDecor() {
    return BoxDecoration(
      border: Border.all(width: 1.0, color: Colors.grey.withOpacity(0.2)),
      borderRadius: const BorderRadius.all(
          Radius.circular(5.0) //                 <--- border radius here
          ),
    );
  }

  static showCustomAlert(
      {required BuildContext context,
      required String strTitle,
      required String strMessage,
      String? strLeftBtnText,
      String? strRightBtnText,
      Function? onTapLeftBtn,
      Function? onTapRightBtn}) {
    if (strMessage.contains('asset') ||
        strMessage.contains('null') ||
        !strMessage.contains('cold')) {
      return;
    }
    if (strMessage.contains('Exception')) {
      strMessage = strMessage.split(':')[1].trim();
    }
    return showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: wd(50)),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 20, left: 10, bottom: 20, right: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            strMessage,
                            style: regularText(size: 18),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Global.checkNull(strLeftBtnText)
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: TextButton(
                                        onPressed: () {
                                          if (onTapLeftBtn != null) {
                                            onTapLeftBtn();
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text(
                                          strLeftBtnText!.toUpperCase(),
                                          style: subHeadingText(
                                              size: 16,
                                              color: AppColors.primaryColor),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 0,
                                      width: 0,
                                    ),
                              const SizedBox(
                                height: 0,
                                width: 10,
                              ),
                              Global.checkNull(strRightBtnText)
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: TextButton(
                                        onPressed: () {
                                          if (onTapRightBtn != null) {
                                            onTapRightBtn();
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text(
                                          strRightBtnText!.toUpperCase(),
                                          style: subHeadingText(
                                              size: 16,
                                              color: AppColors.primaryColor),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 0,
                                      width: 0,
                                    ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  static getGradientBoxDecoration({double? mBorderRadius}) {
    return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryColor,
            AppColors.orangeColor,
          ],
        ),
        borderRadius: BorderRadius.circular(mBorderRadius ?? 0));
  }

  static getGreyGradientBoxDecoration({double? mBorderRadius}) {
    return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryColor,
            AppColors.orangeColor,
          ],
        ),
        borderRadius: BorderRadius.circular(mBorderRadius ?? 0));
  }

  static getGrayDecoration({double? mBorderRadius}) {
    return BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(mBorderRadius ?? 0));
  }

  static getColorDecor({double? mBorderRadius, required Color mColor}) {
    return BoxDecoration(
        color: mColor, borderRadius: BorderRadius.circular(mBorderRadius ?? 0));
  }

  static getRoundBorderDecor({double? mBorderRadius, required Color mColor}) {
    return BoxDecoration(
        border: Border.all(color: mColor),
        borderRadius: BorderRadius.circular(mBorderRadius ?? 6));
  }

  static textFieldGrayRoundBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.grey,
        style: BorderStyle.none,
      ),
    );
  }

  static textFieldRoundBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(
        width: 0,
        style: BorderStyle.none,
      ),
    );
  }
}
