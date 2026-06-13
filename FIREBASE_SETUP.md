# 🔥 Hướng dẫn kết nối Firebase cho iCa

Toàn bộ dữ liệu của app được lưu & lấy trên Firebase:
- **Firestore** — khách hàng, hải sản, báo giá, công nợ, nhập xuất, thông báo
- **Storage** — ảnh công nợ, avatar khách hàng
- **Auth** — đăng nhập / đăng ký / quên mật khẩu
- **Cloud Messaging (FCM)** — push thông báo tới mọi thiết bị

---

## 1. Tạo project Firebase

1. Vào https://console.firebase.google.com → **Add project**
2. Bật các dịch vụ:
   - **Authentication** → Sign-in method → bật **Email/Password**
   - **Firestore Database** → Create database (chế độ Production)
   - **Storage** → Get started
   - **Cloud Messaging** (tự bật sẵn)

## 2. Cấu hình FlutterFire

```bash
# Cài CLI
dart pub global activate flutterfire_cli
npm install -g firebase-tools
firebase login

# Tự sinh lib/firebase_options.dart với key thật
cd ocean_price_flutter
flutterfire configure
```

Lệnh trên sẽ **ghi đè** `lib/firebase_options.dart` (file hiện tại chỉ là template).

## 3. Cài dependencies

```bash
flutter pub get
```

## 4. Cấu hình iOS (cho image_picker + FCM)

`ios/Runner/Info.plist` thêm:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>iCa cần truy cập thư viện ảnh để đính kèm hoá đơn công nợ</string>
<key>NSCameraUsageDescription</key>
<string>iCa cần camera để chụp ảnh hoá đơn</string>
```

Bật **Push Notifications** + **Background Modes → Remote notifications** trong Xcode → Signing & Capabilities.

---

## 5. Firestore Security Rules

Vào Firestore → Rules, dán:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Mỗi user chỉ đọc/ghi dữ liệu của chính mình
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // Thiết bị nhận push: user tự quản token của mình
    match /devices/{token} {
      allow read, write: if request.auth != null
        && request.resource.data.uid == request.auth.uid;
    }

    // Hàng đợi push — chỉ tạo, server xử lý
    match /push_queue/{id} {
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid;
      allow read, update, delete: if false; // chỉ Cloud Function
    }
  }
}
```

## 6. Storage Security Rules

Vào Storage → Rules:

```js
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

---

## 7. Cloud Function gửi push (tự động)

Khi tạo/sửa công nợ, app ghi 1 doc vào `push_queue`. Cloud Function dưới đây
lắng nghe và gửi FCM tới mọi thiết bị của user.

`functions/index.js`:

```js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendPush = functions.firestore
  .document("push_queue/{id}")
  .onCreate(async (snap) => {
    const { uid, title, body } = snap.data();

    // lấy tất cả token thiết bị của user
    const devices = await admin.firestore()
      .collection("devices").where("uid", "==", uid).get();
    const tokens = devices.docs.map((d) => d.data().token);
    if (tokens.length === 0) return;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: { type: "debt" },
    });

    await snap.ref.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp() });
  });
```

Deploy:

```bash
cd functions && npm install firebase-admin firebase-functions
firebase deploy --only functions
```

---

## 8. Dùng trong code

```dart
final fb = FirebaseService.instance;

// Auth
await fb.signUp(name: "Minh", email: "minh@x.com", password: "123456");
await fb.signIn("minh@x.com", "123456");
await fb.signOut();
await fb.sendPasswordReset("minh@x.com");

// Khách hàng (realtime)
StreamBuilder<List<Customer>>(
  stream: fb.watchCustomers(),
  builder: (ctx, snap) { ... },
);
await fb.addCustomer(customer, avatarBytes: bytes);

// Công nợ + ảnh
await fb.addDebt(debt, imageBytes: bytes);   // tự push thông báo
await fb.updateDebt(debt, imageAction: bytes); // hoặc 'remove' / null
await fb.markDebtPaid(debtId, amount);

// Nhập xuất, báo giá, thông báo... tương tự
```

`app_state.dart` nên được sửa để gọi các method này thay cho lưu in-memory.
Xem `app_state_firebase.dart` (ví dụ tích hợp) để tham khảo cách wiring.
