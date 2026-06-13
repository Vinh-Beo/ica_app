# iCa Flutter

Ứng dụng quản lý báo giá hải sản cho iOS.

## Cấu trúc thư mục

```
lib/
  main.dart                      # Entry point + Auth gate
  models.dart                    # Data models
  constants.dart                 # Màu sắc, helpers, initial data
  app_state.dart                 # ChangeNotifier state management
  screens/
    login_screen.dart            # Trang đăng nhập
    main_shell.dart              # Bottom nav + top bar + sign out
    bao_gia_screen.dart          # Tab Báo giá (+ Giá gốc, Lịch sử sub-pages)
    cong_no_screen.dart          # Tab Công nợ + Customer debt detail
    nhap_xuat_screen.dart        # Tab Nhập xuất
    khach_hang_screen.dart       # Tab Khách hàng + OrderScreen
    don_hang_screen.dart         # Tab Đơn hàng (re-export)
  widgets/
    common_widgets.dart          # Shared components
```

## Cài đặt

```bash
flutter pub get
flutter run
```

## iOS permissions (Info.plist)

Thêm vào `ios/Runner/Info.plist` để dùng tính năng chọn ảnh công nợ:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>iCa cần truy cập thư viện ảnh để đính kèm hóa đơn công nợ</string>
<key>NSCameraUsageDescription</key>
<string>iCa cần truy cập camera để chụp ảnh hóa đơn</string>
```

## Dependencies

- `provider: ^6.1.2` — State management
- `image_picker: ^1.1.2` — Chọn ảnh cho công nợ  
- `intl: ^0.19.0` — Date/number formatting
- `uuid: ^4.4.0` — Unique IDs

## Tính năng

### 🔐 Đăng nhập / Đăng xuất
- Màn hình đăng nhập với gradient animation
- Avatar + dropdown menu sign out trong top bar

### 📋 Báo giá
- Nhập giá gốc hải sản
- Lập báo giá theo khách hàng + hệ số
- Ghi đè giá từng mặt hàng
- Xem lịch sử báo giá

### 💳 Công nợ
- Chỉ hiển thị khách đang nợ
- Thêm công nợ: số tiền, ngày tạo, ngày giao, ảnh đính kèm
- Đánh dấu đã thu

### 🔄 Nhập xuất
- Tồn kho theo từng mặt hàng hải sản
- Xuất âm = hoàn hàng
- Lịch sử giao dịch theo ngày

### 📦 Đơn hàng
- Sắp ra mắt

### 👥 Khách hàng
- Quản lý hệ số từng khách
- Xem giá bán theo từng khách
