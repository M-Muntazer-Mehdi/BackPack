import 'dart:developer';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/models/application_model.dart';
import 'package:back_packers/models/doc_model.dart';
import 'package:back_packers/models/group_chat_model.dart';
import 'package:back_packers/models/item_model.dart';
import 'package:back_packers/models/order_model.dart';
import 'package:back_packers/models/request_model.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/utils/login_details.dart';

class Database {
  static FirebaseFirestore instance = FirebaseFirestore.instance;
  static String userId = Get.find<UserDetail>().userId;

  static createUserInDatabase(UserModel user) async {
    // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    // var token = await firebaseMessaging.getToken() ?? '';
    return await instance
        .collection('users')
        .doc(user.id)
        .set({...user.toMapSignup(), 'token': 'token'}).then((value) {
      return true;
    }).catchError((e) {
      return false;
    });
  }

  static Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await instance.collection("users").doc(uid).get();
    return UserModel.fromDocumentSnapshot(doc);
  }

  static Future<bool> isUserExist(String email) async {
    var docs = await instance
        .collection("users")
        .where('email', isEqualTo: email)
        .get();
    return docs.docs.isNotEmpty;
  }

  static Future<bool> deleteFirebaseUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    debugPrint("user is : $user");
    if (user != null) {
      try {
        await user.delete();
        await instance.collection('users').doc(user.uid).delete();
        return true;
      } on FirebaseException catch (exception) {
        print("Error deleting user: ${exception.message}");
        if (exception.message != null) {
          EasyLoading.showToast(exception.message!);
        }
        return false;
      }
    } else {
      print("No user is currently signed in");
      return false;
    }
  }

  static Future<bool> listItem(ItemModel itemModel) async {
    try {
      if (itemModel.id != '') {
        await instance
            .collection("items")
            .doc(itemModel.id)
            .update(itemModel.toMap());
      } else {
        await instance.collection("items").add(itemModel.toMap());
      }
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  static Future<bool> submitOrder(OrderModel orderModel) async {
    try {
      await instance.collection("orders").add(orderModel.toMap());

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  static Future<bool> submitRequest(RequestModel requestModel) async {
    try {
      await instance.collection("requests").add(requestModel.toMap());

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  static Future<bool> addToWishlist(String itemId) async {
    try {
      EasyLoading.show();
      await instance
          .collection("wishlist")
          .add({'itemId': itemId, 'userId': Get.find<UserDetail>().userId});
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<bool> removeWishlist(String id) async {
    try {
      EasyLoading.show();
      await instance.collection("wishlist").doc(id).delete();
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<bool> updateRequesStatus(String id, String status) async {
    try {
      EasyLoading.show();
      await instance.collection("requests").doc(id).update({'status': status});
      EasyLoading.dismiss();

      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<bool> updateOrderStatus(
      String id, String status, List picture) async {
    try {
      EasyLoading.show();
      if (status == OrderStatus.ordered) {
        await instance
            .collection("orders")
            .doc(id)
            .update({'status': status, 'pictures': picture});
      } else {
        await instance
            .collection("orders")
            .doc(id)
            .update({'status': status, 'dropPicture': picture});
      }
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<bool> updateReviewStatus(String id) async {
    try {
      EasyLoading.show();

      await instance.collection("orders").doc(id).update({
        'ratingDone': true,
      });

      EasyLoading.dismiss();
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return false;
    }
  }

  static Future<OrderModel?> checkPreviousReviews() async {
    try {
      var query = await instance
          .collection('orders')
          .withConverter<OrderModel>(
              fromFirestore: (r, _) => OrderModel.fromDocumentSnapshot(r),
              toFirestore: (r, _) => r.toMap())
          .where(
            'ratingDone',
            isEqualTo: false,
          )
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString());
      return null;
    }
  }

  static Stream<QuerySnapshot<DocModel>> getMyDocs(String type) {
    return instance
        .collection('users')
        .doc(userId)
        .collection('data')
        .withConverter<DocModel>(
            fromFirestore: (r, _) => DocModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'type',
          isEqualTo: type,
        )
        .snapshots();
  }

  static Future<QuerySnapshot<DocModel>> getMyDocsFuture(String type) {
    return instance
        .collection('users')
        .doc(userId)
        .collection('data')
        .withConverter<DocModel>(
            fromFirestore: (r, _) => DocModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'type',
          isEqualTo: type,
        )
        .get();
  }

  static Stream<QuerySnapshot<ItemModel>> getMyListing() {
    return instance
        .collection('items')
        .withConverter<ItemModel>(
            fromFirestore: (r, _) => ItemModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'userId',
          isEqualTo: Get.find<UserDetail>().userId,
        )
        .where('status',
            whereIn: [ItemStatus.available, ItemStatus.inUse]).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> checkWishlist(String id) {
    return instance
        .collection('wishlist')
        .where(
          'userId',
          isEqualTo: Get.find<UserDetail>().userId,
        )
        .where('itemId', isEqualTo: id)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyWishlist() {
    return instance
        .collection('wishlist')
        .where(
          'userId',
          isEqualTo: Get.find<UserDetail>().userId,
        )
        .snapshots();
  }

  static Stream<QuerySnapshot<RequestModel>> getMyRequest() {
    return instance
        .collection('requests')
        .withConverter<RequestModel>(
            fromFirestore: (r, _) => RequestModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'requestBy',
          isEqualTo: Get.find<UserDetail>().userId,
        )
        .where('status', whereIn: [
      RequestStatus.requested,
      RequestStatus.accepted
    ]).snapshots();
  }

  static Stream<QuerySnapshot<OrderModel>> getMyOrder(int status,
      {bool getIncoming = false}) {
    String key = getIncoming ? 'requestTo' : 'requestBy';
    if (status == 0) {
      return instance
          .collection('orders')
          .withConverter<OrderModel>(
              fromFirestore: (r, _) => OrderModel.fromDocumentSnapshot(r),
              toFirestore: (r, _) => r.toMap())
          .where(
            key,
            isEqualTo: Get.find<UserDetail>().userId,
          )
          .snapshots();
    } else if (status == 1) {
      return instance
          .collection('orders')
          .withConverter<OrderModel>(
              fromFirestore: (r, _) => OrderModel.fromDocumentSnapshot(r),
              toFirestore: (r, _) => r.toMap())
          .where(
            key,
            isEqualTo: Get.find<UserDetail>().userId,
          )
          .where('status', isEqualTo: OrderStatus.picked)
          .snapshots();
    } else {
      return instance
          .collection('orders')
          .withConverter<OrderModel>(
              fromFirestore: (r, _) => OrderModel.fromDocumentSnapshot(r),
              toFirestore: (r, _) => r.toMap())
          .where(
            key,
            isEqualTo: Get.find<UserDetail>().userId,
          )
          .where('status', isEqualTo: OrderStatus.drop)
          .snapshots();
    }
  }

  static Stream<QuerySnapshot<RequestModel>> getIncomingRequest() {
    return instance
        .collection('requests')
        .withConverter<RequestModel>(
            fromFirestore: (r, _) => RequestModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'requestTo',
          isEqualTo: Get.find<UserDetail>().userId,
        )
        .where('status', whereIn: [
      RequestStatus.requested,
      RequestStatus.accepted
    ]).snapshots();
  }

  static deleteRequest(id) {
    return instance.collection('requests').doc(id).delete();
  }

  static Stream<DocumentSnapshot<ItemModel>> getSingleItemStream(String id) {
    return instance
        .collection('items')
        .withConverter<ItemModel>(
            fromFirestore: (r, _) => ItemModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .doc(id)
        .snapshots();
  }

  static Future<DocumentSnapshot<ItemModel>> getSingleItemSnap(String id) {
    return instance
        .collection('items')
        .withConverter<ItemModel>(
            fromFirestore: (r, _) => ItemModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .doc(id)
        .get();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getSingleRating(
      String id) {
    return instance
        .collection('rating')
        .where('userId', isEqualTo: Get.find<UserDetail>().userId)
        .where('orderId', isEqualTo: id)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getSingleRatingUser(
      String id) {
    return instance
        .collection('userRating')
        .where('fromUser', isEqualTo: Get.find<UserDetail>().userId)
        .where('orderId', isEqualTo: id)
        .snapshots();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getItemRatingsFuture(
      String id) {
    return instance.collection('rating').where('itemId', isEqualTo: id).get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getUserRatingsFuture(
      String id) {
    return instance
        .collection('userRating')
        .where('toUser', isEqualTo: id)
        .get();
  }

  static Stream<DocumentSnapshot<UserModel>> getSingleUser(String id) {
    return instance
        .collection('users')
        .withConverter<UserModel>(
            fromFirestore: (r, _) => UserModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .doc(id)
        .snapshots();
  }

  static Future<DocumentSnapshot<ChatGroupModel>> getSingleChat(String id) {
    return FirebaseFirestore.instance
        .collection('chats')
        .withConverter<ChatGroupModel>(
            fromFirestore: (r, _) => ChatGroupModel.fromMap(r),
            toFirestore: (r, _) => r.toMap())
        .doc(id)
        .get();
  }

  static Stream<QuerySnapshot<ChatGroupModel>> getChatRoomStatus(
      String userId) {
    return instance
        .collection('chats')
        .withConverter<ChatGroupModel>(
            fromFirestore: (r, _) => ChatGroupModel.fromMap(r),
            toFirestore: (r, _) => r.toMap())
        .where('check',
            arrayContains: '${userId}${Get.find<UserDetail>().userId}')
        // .where('jobId', isEqualTo: jobId)
        .snapshots();
    // .data();
  }

  static Stream<QuerySnapshot<ApplicantModel>> getAppliedJobs() {
    return instance
        .collection('applicants')
        .withConverter<ApplicantModel>(
            fromFirestore: (r, _) => ApplicantModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  static Stream<QuerySnapshot<ApplicantModel>> checkJobAppliedOrNot(jobId) {
    return instance
        .collection('applicants')
        .withConverter<ApplicantModel>(
            fromFirestore: (r, _) => ApplicantModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where('userId', isEqualTo: userId)
        .where('jobId', isEqualTo: jobId)
        .snapshots();
  }

  // static Stream<List<ApplicantModel>> getAppliedJobs() {
  //   return FirebaseFirestore.instance
  //       .collection('applicants')
  //       .where('userId', isEqualTo: userId)
  //       .snapshots()
  //       .asyncMap((querySnapshot) async {
  //     List<ApplicantModel> applicants = [];

  //     for (QueryDocumentSnapshot applicantSnapshot in querySnapshot.docs) {
  //       ApplicantModel applicant = ApplicantModel.fromDocumentSnapshot(applicantSnapshot);

  //       // Retrieve the job document using jobId
  //       DocumentSnapshot jobSnapshot = await FirebaseFirestore.instance
  //           .collection('jobs')
  //           .doc(applicant.jobId)
  //           .get();

  //       if (jobSnapshot.exists) {
  //         // Add the job data to the applicant
  //         ItemModel job = JobModel.fromDocumentSnapshot(jobSnapshot);
  //         applicant.job = job;
  //         applicants.add(applicant);
  //       }
  //     }

  //     return applicants;
  //   });
  // }

  static Stream<QuerySnapshot<ItemModel>> getAllJobs() {
    return instance
        .collection('items')
        .withConverter<ItemModel>(
            fromFirestore: (r, _) => ItemModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'userId',
          isNotEqualTo: userId,
        )
        .snapshots();
  }

  static Stream<List<DocumentSnapshot<ItemModel>>> getNearByItems(
      LatLng latLng, String search,
      {int radius = 50}) {
    GeoPoint tokyoStation = GeoPoint(latLng.latitude, latLng.longitude);
    final GeoFirePoint center = GeoFirePoint(tokyoStation);
    double radiusInKm = radius.toDouble();
    const String field = 'geo';

    Query<ItemModel> queryBuilderAll(Query<ItemModel> query) =>
        query.where('nameArray', arrayContainsAny: ['']);

    final CollectionReference<ItemModel> collectionReference =
        FirebaseFirestore.instance.collection('items').withConverter(
            fromFirestore: (u, _) => ItemModel.fromDocumentSnapshot(u),
            toFirestore: (u, _) => u.toMap());
    return GeoCollectionReference<ItemModel>(collectionReference)
        .subscribeWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: field,
      strictMode: true,
      geopointFrom: (ItemModel userModel) => userModel.geo,
      // queryBuilder: queryBuilderAll
    );
  }

  static Future<List<DocumentSnapshot<ItemModel>>> getNearByItemsOnTim(
      LatLng latLng, String search,
      {int radius = 50}) {
    GeoPoint tokyoStation = GeoPoint(latLng.latitude, latLng.longitude);
    final GeoFirePoint center = GeoFirePoint(tokyoStation);
    double radiusInKm = radius.toDouble();
    const String field = 'geo';

    Query<ItemModel> queryBuilderAll(Query<ItemModel> query) =>
        query.where('nameArray', arrayContainsAny: ['']);

    final CollectionReference<ItemModel> collectionReference =
        FirebaseFirestore.instance.collection('items').withConverter(
            fromFirestore: (u, _) => ItemModel.fromDocumentSnapshot(u),
            toFirestore: (u, _) => u.toMap());
    return GeoCollectionReference<ItemModel>(collectionReference).fetchWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: field,
      strictMode: true,
      geopointFrom: (ItemModel userModel) => userModel.geo,
      // queryBuilder: queryBuilderAll
    );
  }

  static Stream<List<DocumentSnapshot<ItemModel>>> getNearByJobs(LatLng latLng,
      {int radius = 50}) {
    GeoPoint tokyoStation = GeoPoint(latLng.latitude, latLng.longitude);

    final GeoFirePoint center = GeoFirePoint(tokyoStation);
    double radiusInKm = radius.toDouble();
    print('Center: ${latLng.latitude}, ${latLng.longitude}');
    print('Radius: $radiusInKm km');
    const String field = 'geo';
    // Query<ItemModel> queryBuilder(Query<ItemModel> query) => query
    //     .where('category', isEqualTo: 'job')
    //     .where('nameArray', arrayContainsAny: ['']);
    final CollectionReference<ItemModel> collectionReference =
        FirebaseFirestore.instance.collection('items').withConverter(
            fromFirestore: (u, _) => ItemModel.fromDocumentSnapshot(u),
            toFirestore: (u, _) => u.toMap());
    return GeoCollectionReference<ItemModel>(collectionReference)
        .subscribeWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: field,
      strictMode: true,
      geopointFrom: (ItemModel userModel) => userModel.geo,
      // queryBuilder: queryBuilder
    );
  }

  static Stream<List<DocumentSnapshot<UserModel>>> getNearByBuddies(
      LatLng latLng, String search,
      {int radius = 50}) {
    GeoPoint tokyoStation = GeoPoint(latLng.latitude, latLng.longitude);
    final GeoFirePoint center = GeoFirePoint(tokyoStation);
    double radiusInKm = radius.toDouble();
    const String field = 'geo';
    // Query<UserModel> queryBuilder(Query<UserModel> query) =>
    //     query.where('email', : [Get.find<UserDetail>().email]);
    final CollectionReference<UserModel> collectionReference =
        FirebaseFirestore.instance.collection('users').withConverter(
            fromFirestore: (u, _) => UserModel.fromDocumentSnapshot(u),
            toFirestore: (u, _) => u.toMap());
    return GeoCollectionReference<UserModel>(collectionReference)
        .subscribeWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: field,
      strictMode: true,
      geopointFrom: (UserModel userModel) => userModel.geo as GeoPoint,
      // queryBuilder: queryBuilder
    );
  }

  static Future<List<DocumentSnapshot<UserModel>>> getNearByBuddiesOneTime(
      LatLng latLng, String search,
      {int radius = 50}) {
    GeoPoint tokyoStation = GeoPoint(latLng.latitude, latLng.longitude);
    final GeoFirePoint center = GeoFirePoint(tokyoStation);
    double radiusInKm = radius.toDouble();
    const String field = 'geo';
    // Query<UserModel> queryBuilder(Query<UserModel> query) =>
    //     query.where('email', : [Get.find<UserDetail>().email]);
    final CollectionReference<UserModel> collectionReference =
        FirebaseFirestore.instance.collection('users').withConverter(
            fromFirestore: (u, _) => UserModel.fromDocumentSnapshot(u),
            toFirestore: (u, _) => u.toMap());
    return GeoCollectionReference<UserModel>(collectionReference).fetchWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: field,
      strictMode: true,
      geopointFrom: (UserModel userModel) => userModel.geo as GeoPoint,
      // queryBuilder: queryBuilder
    );
  }

  static Future<int> getListCount() async {
    var count = await instance
        .collection('items')
        .where('userId', isEqualTo: Get.find<UserDetail>().userId)
        .where('status', whereNotIn: [ItemStatus.removed])
        .count()
        .get();
    return count.count ?? 0;
  }

  static Future<int> myOrderCount() async {
    var count = await instance
        .collection('orders')
        .withConverter<OrderModel>(
            fromFirestore: (r, _) => OrderModel.fromDocumentSnapshot(r),
            toFirestore: (r, _) => r.toMap())
        .where(
          'requestBy',
          isEqualTo: Get.find<UserDetail>().userId,
        )
        .count()
        .get();

    return count.count ?? 0;
  }

  static deleteItem(String id) {
    return instance
        .collection('items')
        .doc(id)
        .update({'status': ItemStatus.removed});
  }

  static deleteDoc(String id) {
    return instance
        .collection('users')
        .doc(userId)
        .collection('data')
        .doc(id)
        .delete();
  }

  static Future addDoc(String name, String type, String url) {
    return instance
        .collection('users')
        .doc(userId)
        .collection('data')
        .add({'name': name, 'type': type, 'url': url});
  }

  static Future giveRating(
      {required String orderId,
      required String itemId,
      required String comment,
      required int rate}) async {
    await instance.collection('rating').add({
      'orderId': orderId,
      'itemId': itemId,
      'createdAt': Timestamp.now(),
      'userId': Get.find<UserDetail>().userId,
      'comment': comment,
      'rate': rate,
    });
  }

  static Future giveUserRating(
      {required String orderId,
      required String itemId,
      required String userId,
      required String comment,
      required int rate}) async {
    await instance.collection('userRating').add({
      'orderId': orderId,
      'itemId': itemId,
      'createdAt': Timestamp.now(),
      'fromUser': Get.find<UserDetail>().userId,
      'toUser': userId,
      'comment': comment,
      'rate': rate,
    });
  }

  static Future<bool> reportUser(
    String reportedUserId, {
    required String docId,
    required String myId,
  }) async {
    EasyLoading.show();
    try {
      await instance.collection('users').doc(myId).update({
        'reportedUsers': FieldValue.arrayUnion([reportedUserId])
      });
      await instance.collection('chats').doc(docId).update({
        'status': 'reported',
        'reportedBy': myId,
      });
     final userModel =  await getUser(myId);
     if(userModel!=null){
       SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
       List<String> reportedUsers = List<String>.from(userModel.reportedUsers);
       await sharedPreferences.setStringList('reportedUsers',reportedUsers);
     }
      EasyLoading.dismiss();
      return true;
    } catch (err) {
      debugPrint("error while reporting user is : $err");
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "ok",
          strMsg: 'Something bad happened. Please try again',
          toastType: TOAST_TYPE.toastError);
      EasyLoading.dismiss();
      return false;
    }
  }
}
