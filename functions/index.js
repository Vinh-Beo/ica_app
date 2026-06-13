// iCa — Firebase Cloud Functions
// Deploy: cd functions && npm install && cd .. && firebase deploy --only functions
//
// Firestore Security Rules cần thêm:
//   match /push_queue/{docId} {
//     allow create: if request.auth != null;
//     allow read, update, delete: if false; // chỉ Admin SDK mới đọc/xoá
//   }

const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp }     = require('firebase-admin/app');
const { getFirestore }      = require('firebase-admin/firestore');
const { getMessaging }      = require('firebase-admin/messaging');

initializeApp();

/**
 * Triggered mỗi khi Flutter ghi một document vào push_queue/{docId}.
 * Function sẽ:
 *  1. Lấy tất cả FCM token của user từ collection `devices`
 *  2. Gửi FCM multicast tới các token đó
 *  3. Xoá token hết hạn
 *  4. Xoá document push_queue sau khi gửi xong
 */
exports.sendPush = onDocumentCreated('push_queue/{docId}', async (event) => {
  const snap = event.data;
  if (!snap) return;

  const { uid, title, body, tab } = snap.data();
  if (!uid || !title) {
    await snap.ref.delete();
    return;
  }

  const db = getFirestore();

  // Lấy tất cả token của user
  const devicesSnap = await db.collection('devices')
      .where('uid', '==', uid)
      .get();

  const tokens = devicesSnap.docs
      .map(d => d.data().token)
      .filter(t => typeof t === 'string' && t.length > 0);

  if (tokens.length === 0) {
    await snap.ref.delete();
    return;
  }

  // Gửi FCM
  const messaging = getMessaging();
  const response  = await messaging.sendEachForMulticast({
    notification: { title, body: body || '' },
    data:         { tab: tab || 'debt' },   // Flutter dùng data['tab'] để điều hướng
    tokens,
    android: {
      priority: 'high',
      notification: { channelId: 'ica_push', sound: 'default' },
    },
    apns: {
      payload: { aps: { sound: 'default', badge: 1 } },
    },
  });

  // Xoá token hết hạn / không hợp lệ
  const expired = response.responses
      .map((r, i) => (!r.success ? tokens[i] : null))
      .filter(Boolean);

  if (expired.length > 0) {
    await Promise.all(
      expired.map(token =>
        db.collection('devices').doc(token).delete().catch(() => {})
      )
    );
  }

  // Xoá document đã xử lý
  await snap.ref.delete();
});
