import 'package:flutter/material.dart';

enum PageType { home, search, add, activity, profile }

// Req Type
enum ReqType { get, post, put, patch, delete }

enum FeedType { writing, audio, video, photo }

// chat Type
enum MsgType { left, right }

enum CameraType { front, rear }

enum MediaType { video, image, audio }

enum VideoStates {
  idle,
  recording,
}

// Id Type

enum ParamType { simple, json }

enum BannerType { homePage, service }

// Show DataOr Loading
enum ShowData { showData, showNoDataFound, showLoading, showError }

// Toad Alert Types
// ignore: camel_case_types
enum TOAST_TYPE { toastInfo, toastSuccess, toastWarning, toastError }

//

// ignore_for_file: camel_case_extensions, unnecessary_this

extension sizedBoxExtension on num {
  Widget get hp => SizedBox(
        height: this.toDouble(),
      );

  Widget get wp => SizedBox(
        width: this.toDouble(),
      );
}
