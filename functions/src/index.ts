import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {setGlobalOptions} from "firebase-functions";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

export const sendChatNotification = onDocumentCreated(
  "plans/{planId}/messages/{messageId}",
  async (event) => {
    console.log("🔥 Function started");

    // ```
    const messageData = event.data?.data();

    if (!messageData) {
      console.log("❌ messageData is null");
      return;
    }

    const db = getFirestore();

    const planId = event.params.planId;

    const senderId = messageData.senderId;
    const senderName = messageData.senderName ?? "新着メッセージ";
    const chat = messageData.chat ?? "";

    console.log("📨 New message:", messageData);

    const planDoc = await db
      .collection("plans")
      .doc(planId)
      .get();

    if (!planDoc.exists) {
      console.log("❌ Plan not found");
      return;
    }

    const ownerId = planDoc.data()?.ownerId;
    const inviteFriends = planDoc.data()?.inviteFriends ?? [];

    console.log("👑 ownerId:", ownerId);
    console.log("👥 inviteFriends:", inviteFriends);

    const targetUsers = [
      ownerId,
      ...inviteFriends,
    ].filter(
      (uid: string | undefined) =>
        !!uid && uid !== senderId
    ) as string[];

    console.log("🎯 targetUsers:", targetUsers);

    const tokens: string[] = [];

    for (const uid of targetUsers) {
      const userDoc = await db
        .collection("users")
        .doc(uid)
        .get();

      const token = userDoc.data()?.fcmToken;

      console.log(`👤 ${uid} token:`, token);

      if (token) {
        tokens.push(token);
      }
    }

    console.log("📱 tokens count:", tokens.length);

    if (tokens.length === 0) {
      console.log("❌ 通知先なし");
      return;
    }

    const response = await getMessaging().sendEachForMulticast({
      tokens,
      notification: {
        title: senderName,
        body: chat,
      },
      data: {
        planId: planId,
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    });

    console.log("✅ success:", response.successCount);
    console.log("❌ failure:", response.failureCount);

    response.responses.forEach((result, index) => {
      if (!result.success) {
        console.log(
          `❌ token error ${index}:`,
          result.error
        );
      }
    });

    console.log(`🎉 ${tokens.length}人へ通知送信完了`);
    // ```
  }
);
