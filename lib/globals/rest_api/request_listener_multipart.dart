import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back_packers/globals/constants.dart';
import 'package:back_packers/globals/url_collection.dart';

import '../enum.dart';

class ReqListenerMultiPart {
  static fetchPost(
      {required String strUrl,
      required HashMap<String, String> requestParams,
      required HashMap<String, String> requestParamsImages,
      required ReqType mReqType}) async {
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult != ConnectivityResult.mobile &&
    //     connectivityResult != ConnectivityResult.wifi) {
    //   // I am connected to a mobile network.
    //   return 'internet';
    // }
    HashMap<String, String> lHeaders = HashMap();

    final prefs = await SharedPreferences.getInstance();
    String? accesToken = prefs.getString(SharedPrefKey.KEY_ACCESS_TOKEN);
    if (accesToken != null && accesToken.isNotEmpty) {
      String accesTokenType = Constants.strTokenType;
      accesToken = "$accesTokenType $accesToken";
      lHeaders[PARAMS.PARAM_AUTHORIZATION] = accesToken;
    }

    // method = POST or PUT...
    var url = Uri.parse(RequestBuilder.liveUrl + strUrl);
    String requestType = "PATCH";
    switch (mReqType) {
      case ReqType.post:
        requestType = "POST";
        break;
      case ReqType.patch:
        requestType = "PATCH";
        break;
      case ReqType.get:
        break;
      case ReqType.put:
        break;
      case ReqType.delete:
        break;
    }

    var request = http.MultipartRequest(requestType, url)
      ..fields.addAll(requestParams);

    if (requestParamsImages.isNotEmpty) {
      // ignore: avoid_function_literals_in_foreach_calls
      requestParamsImages.keys.forEach((key) async {
        String strKey = key;
        String strValue = requestParamsImages[key]!;

        final MultipartFile multipartFile =
            await MultipartFile.fromPath(strKey, strValue);
        request.files.add(multipartFile);
      });
    }

    request.headers.addAll(lHeaders);

    var streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint("REQ. lHeaders : $lHeaders");
    debugPrint("REQ. PARAMS : $requestParams");
    debugPrint("REQ. URL : ${RequestBuilder.liveUrl}$strUrl");
    debugPrint("REQ. BODY : ${response.body}");
    if (response.statusCode == 413) {
      return response.statusCode.toString();
    } else {
      return response.body;
    }
  }
}
