// Cloud Functions for Push Notifications
// This file should be placed in your Firebase Functions project

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Send push notification when connection request is created
exports.sendConnectionRequestNotification = functions.firestore
  .document('connection_requests/{requestId}')
  .onCreate(async (snap, context) => {
    const requestData = snap.data();
    const { fromUserId, toUserId, message } = requestData;

    try {
      // Get sender's information
      const senderDoc = await admin.firestore()
        .collection('users')
        .doc(fromUserId)
        .get();
      
      if (!senderDoc.exists) {
        console.log('Sender not found');
        return null;
      }

      const senderData = senderDoc.data();
      const senderName = `${senderData.fname} ${senderData.lname}`;

      // Get recipient's FCM token
      const recipientDoc = await admin.firestore()
        .collection('users')
        .doc(toUserId)
        .get();
      
      if (!recipientDoc.exists) {
        console.log('Recipient not found');
        return null;
      }

      const recipientData = recipientDoc.data();
      const fcmToken = recipientData.fcmToken;

      if (!fcmToken) {
        console.log('No FCM token for recipient');
        return null;
      }

      // Check if recipient is online
      const isOnline = recipientData.isOnline || false;
      
      // Only send notification if user is offline
      if (!isOnline) {
        const payload = {
          notification: {
            title: 'New Connection Request',
            body: `${senderName} wants to connect with you`,
            icon: 'ic_notification',
            sound: 'default',
          },
          data: {
            type: 'connection_request',
            fromUserId: fromUserId,
            fromUserName: senderName,
            requestId: context.params.requestId,
            action: 'view_request',
          },
          token: fcmToken,
        };

        const response = await admin.messaging().send(payload);
        console.log('Successfully sent message:', response);
        
        // Store notification in database
        await admin.firestore().collection('notifications').add({
          userId: toUserId,
          title: 'New Connection Request',
          body: `${senderName} wants to connect with you`,
          data: payload.data,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
          type: 'connection_request',
        });
      }

      return null;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  });

// Send push notification when connection request is accepted
exports.sendConnectionAcceptedNotification = functions.firestore
  .document('connection_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if status changed from pending to accepted
    if (beforeData.status === 'pending' && afterData.status === 'accepted') {
      const { fromUserId, toUserId } = afterData;

      try {
        // Get acceptor's information
        const acceptorDoc = await admin.firestore()
          .collection('users')
          .doc(toUserId)
          .get();
        
        if (!acceptorDoc.exists) {
          console.log('Acceptor not found');
          return null;
        }

        const acceptorData = acceptorDoc.data();
        const acceptorName = `${acceptorData.fname} ${acceptorData.lname}`;

        // Get requester's FCM token
        const requesterDoc = await admin.firestore()
          .collection('users')
          .doc(fromUserId)
          .get();
        
        if (!requesterDoc.exists) {
          console.log('Requester not found');
          return null;
        }

        const requesterData = requesterDoc.data();
        const fcmToken = requesterData.fcmToken;

        if (!fcmToken) {
          console.log('No FCM token for requester');
          return null;
        }

        const payload = {
          notification: {
            title: 'Connection Accepted',
            body: `${acceptorName} accepted your connection request`,
            icon: 'ic_notification',
            sound: 'default',
          },
          data: {
            type: 'connection_accepted',
            toUserId: toUserId,
            toUserName: acceptorName,
            requestId: context.params.requestId,
            action: 'open_chat',
          },
          token: fcmToken,
        };

        const response = await admin.messaging().send(payload);
        console.log('Successfully sent acceptance notification:', response);
        
        // Store notification in database
        await admin.firestore().collection('notifications').add({
          userId: fromUserId,
          title: 'Connection Accepted',
          body: `${acceptorName} accepted your connection request`,
          data: payload.data,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
          type: 'connection_accepted',
        });

        return null;
      } catch (error) {
        console.error('Error sending acceptance notification:', error);
        return null;
      }
    }

    return null;
  });

// Send push notification for new messages
exports.sendMessageNotification = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const { senderId, message, messageType } = messageData;

    try {
      // Get chat information
      const chatDoc = await admin.firestore()
        .collection('chats')
        .doc(context.params.chatId)
        .get();
      
      if (!chatDoc.exists) {
        console.log('Chat not found');
        return null;
      }

      const chatData = chatDoc.data();
      const users = chatData.users;
      
      // Find the recipient (not the sender)
      const recipientId = users.find((userId) => userId !== senderId);
      
      if (!recipientId) {
        console.log('No recipient found');
        return null;
      }

      // Get sender's information
      const senderDoc = await admin.firestore()
        .collection('users')
        .doc(senderId)
        .get();
      
      if (!senderDoc.exists) {
        console.log('Sender not found');
        return null;
      }

      const senderData = senderDoc.data();
      const senderName = `${senderData.fname} ${senderData.lname}`;

      // Get recipient's FCM token
      const recipientDoc = await admin.firestore()
        .collection('users')
        .doc(recipientId)
        .get();
      
      if (!recipientDoc.exists) {
        console.log('Recipient not found');
        return null;
      }

      const recipientData = recipientDoc.data();
      const fcmToken = recipientData.fcmToken;

      if (!fcmToken) {
        console.log('No FCM token for recipient');
        return null;
      }

      // Check if recipient is online
      const isOnline = recipientData.isOnline || false;
      
      // Only send notification if user is offline
      if (!isOnline) {
        let notificationBody = message;
        if (messageType === 'image') {
          notificationBody = '📷 Photo';
        } else if (messageType === 'video') {
          notificationBody = '🎥 Video';
        } else if (messageType === 'voice') {
          notificationBody = '🎤 Voice message';
        } else if (messageType === 'location') {
          notificationBody = '📍 Location';
        }

        const payload = {
          notification: {
            title: senderName,
            body: notificationBody,
            icon: 'ic_notification',
            sound: 'default',
          },
          data: {
            type: 'message',
            chatId: context.params.chatId,
            senderId: senderId,
            senderName: senderName,
            action: 'open_chat',
          },
          token: fcmToken,
        };

        const response = await admin.messaging().send(payload);
        console.log('Successfully sent message notification:', response);
        
        // Store notification in database
        await admin.firestore().collection('notifications').add({
          userId: recipientId,
          title: senderName,
          body: notificationBody,
          data: payload.data,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
          type: 'message',
        });
      }

      return null;
    } catch (error) {
      console.error('Error sending message notification:', error);
      return null;
    }
  });

// Update user online status
exports.updateUserStatus = functions.https.onCall(async (data, context) => {
  const { userId, isOnline } = data;
  
  try {
    await admin.firestore().collection('users').doc(userId).update({
      isOnline: isOnline,
      lastSeen: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    return { success: true };
  } catch (error) {
    console.error('Error updating user status:', error);
    return { success: false, error: error.message };
  }
});

