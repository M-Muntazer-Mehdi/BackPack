// Cloud Functions for Push Notifications
// This file should be placed in your Firebase Functions project

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Simple test function
exports.helloWorld = functions.https.onRequest((request, response) => {
  response.send("Hello from Firebase!");
});

// Send push notification when connection request is created
exports.sendConnectionRequestNotification = functions.firestore
    .onDocumentCreated("connection_requests/{requestId}", async (event) => {
      const requestData = event.data.data();
      const {fromUserId, toUserId} = requestData;

      console.log("🔔 Connection request notification triggered");
      console.log(
          "From:", fromUserId, "To:", toUserId,
          "RequestId:", event.params.requestId);

      try {
        // Get sender's information
        const senderDoc = await admin.firestore()
            .collection("users")
            .doc(fromUserId)
            .get();

        if (!senderDoc.exists) {
          console.log("❌ Sender not found:", fromUserId);
          return null;
        }

        const senderData = senderDoc.data();
        const senderName = `${senderData.fname} ${senderData.lname}`;
        console.log("✅ Sender found:", senderName);

        // Get recipient's FCM token
        const recipientDoc = await admin.firestore()
            .collection("users")
            .doc(toUserId)
            .get();

        if (!recipientDoc.exists) {
          console.log("❌ Recipient not found:", toUserId);
          return null;
        }

        const recipientData = recipientDoc.data();
        const fcmToken = recipientData.fcmToken;
        const isOnline = recipientData.isOnline || false;

        console.log("📱 Recipient data:", {
          userId: toUserId,
          hasFcmToken: !!fcmToken,
          fcmTokenPreview: fcmToken ? fcmToken.substring(0, 30) + "..." : null,
          isOnline: isOnline,
          hasData: !!recipientData,
        });

        if (!fcmToken) {
          console.log("❌ No FCM token for recipient:", toUserId);
          console.log("Available fields:", Object.keys(recipientData));
          return null;
        }

        // Only send notification if user is offline
        if (!isOnline) {
          console.log("📤 User is offline, sending notification...");
          const payload = {
            notification: {
              title: "New Connection Request",
              body: `${senderName} wants to connect with you`,
            },
            data: {
              type: "connection_request",
              fromUserId: fromUserId,
              fromUserName: senderName,
              requestId: event.params.requestId,
              action: "view_request",
            },
            android: {
              notification: {
                sound: "default",
                icon: "ic_notification",
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: "default",
                },
              },
            },
            token: fcmToken,
          };

          const response = await admin.messaging().send(payload);
          console.log("✅ Successfully sent notification:", response);

          // Store notification in database
          await admin.firestore().collection("notifications").add({
            userId: toUserId,
            title: "New Connection Request",
            body: `${senderName} wants to connect with you`,
            data: payload.data,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
            type: "connection_request",
          });

          console.log("✅ Notification stored in database");
        } else {
          console.log("⏭️ User is online, skipping notification");
        }

        return null;
      } catch (error) {
        console.error("❌ Error sending notification:", error);
        console.error("Error stack:", error.stack);
        return null;
      }
    });

// Send push notification when connection request is accepted
exports.sendConnectionAcceptedNotification = functions.firestore
    .onDocumentUpdated("connection_requests/{requestId}", async (event) => {
      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      // Check if status changed from pending to accepted
      if (beforeData.status === "pending" && afterData.status === "accepted") {
        const {fromUserId, toUserId} = afterData;

        try {
          // Get acceptor's information
          const acceptorDoc = await admin.firestore()
              .collection("users")
              .doc(toUserId)
              .get();

          if (!acceptorDoc.exists) {
            console.log("Acceptor not found");
            return null;
          }

          const acceptorData = acceptorDoc.data();
          const acceptorName = `${acceptorData.fname} ${acceptorData.lname}`;

          // Get requester's FCM token
          const requesterDoc = await admin.firestore()
              .collection("users")
              .doc(fromUserId)
              .get();

          if (!requesterDoc.exists) {
            console.log("Requester not found");
            return null;
          }

          const requesterData = requesterDoc.data();
          const fcmToken = requesterData.fcmToken;

          if (!fcmToken) {
            console.log("No FCM token for requester");
            return null;
          }

          const payload = {
            notification: {
              title: "Connection Accepted",
              body: `${acceptorName} accepted your connection request`,
              icon: "ic_notification",
              sound: "default",
            },
            data: {
              type: "connection_accepted",
              toUserId: toUserId,
              toUserName: acceptorName,
              requestId: event.params.requestId,
              action: "open_chat",
            },
            token: fcmToken,
          };

          const response = await admin.messaging().send(payload);
          console.log("Successfully sent acceptance notification:", response);

          // Store notification in database
          await admin.firestore().collection("notifications").add({
            userId: fromUserId,
            title: "Connection Accepted",
            body: `${acceptorName} accepted your connection request`,
            data: payload.data,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
            type: "connection_accepted",
          });

          return null;
        } catch (error) {
          console.error("Error sending acceptance notification:", error);
          return null;
        }
      }

      return null;
    });

// Send push notification for new messages
exports.sendMessageNotification = functions.firestore
    .onDocumentCreated("chats/{chatId}/messages/{messageId}", async (event) => {
      const messageData = event.data.data();
      const {senderId, message, messageType} = messageData;

      console.log("💬 Message notification triggered");
      console.log(
          "ChatId:", event.params.chatId,
          "MessageId:", event.params.messageId,
          "SenderId:", senderId);

      try {
        // Get chat information
        const chatDoc = await admin.firestore()
            .collection("chats")
            .doc(event.params.chatId)
            .get();

        if (!chatDoc.exists) {
          console.log("❌ Chat not found:", event.params.chatId);
          return null;
        }

        const chatData = chatDoc.data();
        const users = chatData.users;

        // Find the recipient (not the sender)
        const recipientId = users.find((userId) => userId !== senderId);

        if (!recipientId) {
          console.log("❌ No recipient found");
          return null;
        }

        // Get sender's information
        const senderDoc = await admin.firestore()
            .collection("users")
            .doc(senderId)
            .get();

        if (!senderDoc.exists) {
          console.log("❌ Sender not found:", senderId);
          return null;
        }

        const senderData = senderDoc.data();
        const senderName = `${senderData.fname} ${senderData.lname}`;
        console.log("✅ Sender found:", senderName);

        // Get recipient's FCM token
        const recipientDoc = await admin.firestore()
            .collection("users")
            .doc(recipientId)
            .get();

        if (!recipientDoc.exists) {
          console.log("❌ Recipient not found:", recipientId);
          return null;
        }

        const recipientData = recipientDoc.data();
        const fcmToken = recipientData.fcmToken;
        const isOnline = recipientData.isOnline || false;

        console.log("📱 Recipient data:", {
          userId: recipientId,
          hasFcmToken: !!fcmToken,
          fcmTokenPreview: fcmToken ? fcmToken.substring(0, 30) + "..." : null,
          isOnline: isOnline,
        });

        if (!fcmToken) {
          console.log("❌ No FCM token for recipient:", recipientId);
          return null;
        }

        // Only send notification if user is offline
        if (!isOnline) {
          console.log("📤 User is offline, sending notification...");
          let notificationBody = message || "";
          if (messageType === "image") {
            notificationBody = "📷 Photo";
          } else if (messageType === "video") {
            notificationBody = "🎥 Video";
          } else if (messageType === "voice") {
            notificationBody = "🎤 Voice message";
          } else if (messageType === "location") {
            notificationBody = "📍 Location";
          } else if (messageType === "document") {
            notificationBody = "📄 Document";
          }

          // Truncate long messages
          if (notificationBody.length > 100) {
            notificationBody = notificationBody.substring(0, 97) + "...";
          }

          const payload = {
            notification: {
              title: senderName,
              body: notificationBody,
            },
            data: {
              type: "message",
              chatId: event.params.chatId,
              senderId: senderId,
              senderName: senderName,
              messageType: messageType || "text",
              action: "open_chat",
            },
            android: {
              notification: {
                sound: "default",
                icon: "ic_notification",
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: "default",
                },
              },
            },
            token: fcmToken,
          };

          const response = await admin.messaging().send(payload);
          console.log("✅ Successfully sent message notification:", response);

          // Store notification in database
          await admin.firestore().collection("notifications").add({
            userId: recipientId,
            title: senderName,
            body: notificationBody,
            data: payload.data,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
            type: "message",
          });

          console.log("✅ Notification stored in database");
        } else {
          console.log("⏭️ User is online, skipping notification");
        }

        return null;
      } catch (error) {
        console.error("❌ Error sending message notification:", error);
        console.error("Error stack:", error.stack);
        return null;
      }
    });

// Update user online status
exports.updateUserStatus = functions.https.onCall(async (data, context) => {
  const {userId, isOnline} = data;

  try {
    await admin.firestore().collection("users").doc(userId).update({
      isOnline: isOnline,
      lastSeen: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {success: true};
  } catch (error) {
    console.error("Error updating user status:", error);
    return {success: false, error: error.message};
  }
});
