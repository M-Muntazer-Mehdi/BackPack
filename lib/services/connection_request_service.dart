import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:back_packers/utils/login_details.dart';

class ConnectionRequestService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send a connection request to another user
  /// The Cloud Function will automatically send a push notification
  static Future<bool> sendConnectionRequest(String toUserId) async {
    try {
      final userDetail = Get.find<UserDetail>();
      final fromUserId = userDetail.userId;

      print('📤 Sending connection request from $fromUserId to $toUserId');

      if (fromUserId.isEmpty) {
        print('❌ Error: fromUserId is empty');
        return false;
      }

      if (toUserId.isEmpty) {
        print('❌ Error: toUserId is empty');
        return false;
      }

      // Check if a request already exists
      QuerySnapshot existingRequest = await _firestore
          .collection('connection_requests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        // Request already exists
        print('⚠️ Connection request already exists');
        return false;
      }

      // Create new connection request
      // The Cloud Function will automatically trigger and send push notification
      DocumentReference docRef = await _firestore.collection('connection_requests').add({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'status': 'pending',
        'message': 'wants to connect with you',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Connection request created with ID: ${docRef.id}');
      return true;
    } catch (e, stackTrace) {
      print('❌ Error sending connection request: $e');
      print('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  /// Accept a connection request
  /// The Cloud Function will automatically send a push notification to the requester
  static Future<bool> acceptConnectionRequest(String requestId) async {
    try {
      await _firestore.collection('connection_requests').doc(requestId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // The Cloud Function will automatically trigger and send push notification
      return true;
    } catch (e) {
      print('❌ Error accepting connection request: $e');
      return false;
    }
  }

  /// Decline a connection request
  static Future<bool> declineConnectionRequest(String requestId) async {
    try {
      await _firestore.collection('connection_requests').doc(requestId).update({
        'status': 'declined',
        'declinedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('❌ Error declining connection request: $e');
      return false;
    }
  }

  /// Get pending connection requests for current user
  static Stream<QuerySnapshot> getPendingRequests() {
    final userDetail = Get.find<UserDetail>();
    return _firestore
        .collection('connection_requests')
        .where('toUserId', isEqualTo: userDetail.userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get accepted connection requests for current user
  static Stream<QuerySnapshot> getAcceptedRequests() {
    final userDetail = Get.find<UserDetail>();
    return _firestore
        .collection('connection_requests')
        .where('status', isEqualTo: 'accepted')
        .where('fromUserId', isEqualTo: userDetail.userId)
        .orderBy('acceptedAt', descending: true)
        .snapshots();
  }
}

