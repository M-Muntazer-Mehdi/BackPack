// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/url_collection.dart';

import '../constants.dart';

class ReqListener {
  static Future<String> fetchPost(
      {required String strUrl,
      required HashMap<String, Object> requestParams,
      required ReqType mReqType,
      required ParamType mParamType}) async {
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

    if (mParamType == ParamType.json) {
      lHeaders["Content-Type"] = "application/json";
      lHeaders["Accept"] = "application/json";
    }
    lHeaders["ApiKey"] = "sH1ftm4T3IsH3ReT0\$t4Yal3x&1br4H!m";
    late http.Response? response;

    switch (mReqType) {
      case ReqType.get:
        var param = '';
        if (requestParams.isNotEmpty) {
          param = '?';
          requestParams.forEach((key, value) {
            param += '$key=$value&';
          });
        }
        response = await http
            .get(Uri.parse(RequestBuilder.liveUrl + strUrl + param),
                headers: lHeaders)
            .timeout(const Duration(minutes: 3));
        break;
      case ReqType.post:
        response = await http
            .post(Uri.parse(RequestBuilder.liveUrl + strUrl),
                body: mParamType == ParamType.json
                    ? jsonEncode(requestParams)
                    : requestParams,
                headers: lHeaders)
            .timeout(const Duration(minutes: 3));
        break;
      case ReqType.patch:
        response = await http
            .patch(Uri.parse(RequestBuilder.liveUrl + strUrl),
                body: mParamType == ParamType.json
                    ? jsonEncode(requestParams)
                    : requestParams,
                headers: lHeaders)
            .timeout(const Duration(minutes: 3));
        break;
      case ReqType.put:
        response = await http
            .put(Uri.parse(RequestBuilder.liveUrl + strUrl),
                body: mParamType == ParamType.json
                    ? jsonEncode(requestParams)
                    : requestParams,
                headers: lHeaders)
            .timeout(const Duration(minutes: 3));
        break;
      case ReqType.delete:
        response = await http
            .delete(Uri.parse(RequestBuilder.liveUrl + strUrl),
                body: mParamType == ParamType.json
                    ? jsonEncode(requestParams)
                    : requestParams,
                headers: lHeaders)
            .timeout(const Duration(minutes: 3));
        break;
    }

    debugPrint("REQ. lHeaders : $lHeaders");
    debugPrint("REQ. PARAMS : $requestParams");
    debugPrint("REQ. URL : ${RequestBuilder.liveUrl}$strUrl");
    log("REQ. BODY : ${response.body}");

    return response.body;
  }
}
