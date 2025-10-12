// import 'dart:developer';

// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

// class DynamicLinksApi {
//   final dynamicLink = FirebaseDynamicLinks.instance;

//   handleDynamicLink() async {
//     PendingDynamicLinkData? pendingDynamicLinkData =
//         await dynamicLink.getInitialLink();
//     if (pendingDynamicLinkData != null) {
//       handleSuccessLinking(pendingDynamicLinkData);
//     }
//     dynamicLink.onLink.listen((dynamicLinkData) {
//       handleSuccessLinking(dynamicLinkData);
//     }).onError((error) {
//       log('onLink error');
//       log(error.message);
//     });
//   }

//   Future<String> createReferralLink(String referralCode) async {
//     final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
//       uriPrefix: 'https://otobucks.page.link',
//       link: Uri.parse('https://otobucks.com/refer?code=$referralCode'),
//       androidParameters: const AndroidParameters(
//           packageName: 'com.otobucks.app', minimumVersion: 0),
//       socialMetaTagParameters: SocialMetaTagParameters(
//         title: 'Refer A Friend',
//         description: 'Refer and earn',
//         imageUrl:
//             Uri.parse('https://d23jwszswncmo3.cloudfront.net/otobuckslogo.jpg'),
//       ),
//     );

//     final ShortDynamicLink shortLink =
//         await dynamicLink.buildShortLink(dynamicLinkParameters);

//     final Uri dynamicUrl = shortLink.shortUrl;
//     return dynamicUrl.toString();
//   }

//   Future<void> handleSuccessLinking(PendingDynamicLinkData data) async {
//     final Uri deepLink = data.link;
//     var isRefer = deepLink.pathSegments.contains('refer');
//     if (isRefer) {}
//   }
// }
