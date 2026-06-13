// lib/l10n/app_strings.dart
//
// Manual localization helper — works WITHOUT flutter gen-l10n.
// Usage in widgets:
//   final s = AppStrings.of(context);
//   Text(s.loginTitle)
//
// After running `flutter gen-l10n`, you can switch to AppLocalizations instead.

import 'package:flutter/material.dart';
import '../../main.dart' show LangState;
import 'package:provider/provider.dart';

class AppStrings {
  final String lang;
  AppStrings(this.lang);

  /// Dùng trong build() — đăng ký rebuild khi đổi ngôn ngữ
  static AppStrings of(BuildContext context) {
    final lang = context.watch<LangState>().langCode;
    return AppStrings(lang);
  }

  /// Dùng trong callback/async — không đăng ký listener
  static AppStrings readFrom(BuildContext context) {
    final lang = context.read<LangState>().langCode;
    return AppStrings(lang);
  }

  bool get isVi => lang == 'vi';

  String get appSubtitle   => isVi ? 'Quản lý báo giá hải sản' : 'Seafood price management';
  String get loginTitle    => isVi ? 'Đăng nhập'                : 'Sign In';
  String get loginWelcome  => isVi ? 'Chào mừng trở lại 👋'    : 'Welcome back 👋';
  String get loginEmail    => isVi ? 'Email'                    : 'Email';
  String get loginEmailHint=> isVi ? 'example@email.com'        : 'example@email.com';
  String get loginPassword => isVi ? 'Mật khẩu'                : 'Password';
  String get loginForgot   => isVi ? 'Quên mật khẩu?'          : 'Forgot password?';
  String get loginButton   => isVi ? 'Đăng nhập →'             : 'Sign In →';
  String get loginLoading  => isVi ? 'Đang đăng nhập...'       : 'Signing in...';
  String get loginErrEmail => isVi ? 'Vui lòng nhập email'     : 'Please enter your email';
  String get loginErrPw    => isVi ? 'Vui lòng nhập mật khẩu'  : 'Please enter your password';
  String get loginFooter   => isVi ? 'iCa v1.0 · © 2026': 'iCa v1.0 · © 2026';

  String get signOut       => isVi ? 'Đăng xuất'               : 'Sign Out';

  String get tabQuote      => isVi ? 'Báo giá'                 : 'Quotes';
  String get tabDebt       => isVi ? 'Công nợ'                 : 'Receivables';
  String get tabOrders     => isVi ? 'Đơn hàng'                : 'Orders';
  String get tabInventory  => isVi ? 'Nhập xuất'               : 'Inventory';
  String get tabCustomers  => isVi ? 'Khách hàng'              : 'Customers';

  String get add           => isVi ? '＋ Thêm'                 : '＋ Add';
  String get close         => isVi ? '✕ Đóng'                  : '✕ Close';
  String get cancel        => isVi ? 'Huỷ'                     : 'Cancel';
  String get delete        => isVi ? 'Xoá'                     : 'Delete';
  String get confirm       => isVi ? 'Xác nhận'                : 'Confirm';
  String get save          => isVi ? 'Lưu'                     : 'Save';
  String get comingSoon    => isVi ? 'Sắp ra mắt'              : 'Coming Soon';

  String get baseTitle     => isVi ? 'Giá gốc hải sản'         : 'Base Prices';
  String get baseSubtitle  => isVi ? 'Dùng chung cho mọi khách': 'Shared across all customers';
  String get items         => isVi ? 'Mặt hàng'                : 'Items';
  String get priced        => isVi ? 'Đã có giá'               : 'Priced';
  String get notPriced     => isVi ? 'Chưa có giá'             : 'Unpriced';
  String get addSeafood    => isVi ? '＋ Thêm hải sản mới'     : '＋ Add new seafood';
  String get seafoodName   => isVi ? 'Tên hải sản'             : 'Seafood name';
  String get seafoodHint   => isVi ? 'VD: Tôm Hùm, Cá Thu...' : 'E.g. Lobster, Salmon...';
  String get category      => isVi ? 'Danh mục'                : 'Category';
  String get unit          => isVi ? 'Đơn vị'                  : 'Unit';
  String get basePrice     => isVi ? 'Giá gốc (đ)'             : 'Base price (₫)';
  String get addToList     => isVi ? '＋ Thêm vào danh sách'   : '＋ Add to list';

  String get quotePeriod   => isVi ? 'KỲ BÁO GIÁ'              : 'QUOTE PERIOD';
  String get quoteCustomer => isVi ? 'KHÁCH HÀNG'               : 'CUSTOMER';
  String get selectAll     => isVi ? 'Chọn tất cả'             : 'Select all';
  String get saveQuote     => isVi ? 'Lưu Báo Giá'              : 'Save Quote';
  String get itemsLabel    => isVi ? 'mặt hàng'                : 'items';
  String get noBaseGo      => isVi ? 'Chưa có giá gốc nào'    : 'No base prices yet';
  String get goBase        => isVi ? '→ Nhập giá gốc'          : '→ Add base prices';

  String get scBase        => isVi ? 'Giá gốc'                 : 'Base Prices';
  String get scHistory     => isVi ? 'Lịch sử'                 : 'History';
  String get scView        => isVi ? 'Xem & chỉnh'             : 'View & edit';
  String get scReview      => isVi ? 'Xem lại'                 : 'View all';

  String get histTitle     => isVi ? 'Lịch sử báo giá'         : 'Quote History';
  String get histSaved     => isVi ? 'báo giá đã lưu'          : 'saved quotes';
  String get noQuotes      => isVi ? 'Chưa có báo giá nào'     : 'No quotes yet';
  String get statItems     => isVi ? 'Mặt hàng'                : 'Items';
  String get statProfit    => isVi ? 'Lợi nhuận'               : 'Profit';
  String get statBase      => isVi ? 'Tổng giá gốc'            : 'Total base';
  String get statSell      => isVi ? 'Tổng giá bán'            : 'Total sell';
  String get exportExcel   => isVi ? 'Xuất Excel'              : 'Export Excel';
  String get exportWord    => isVi ? 'Xuất Word'               : 'Export Word';

  String get plLoss        => isVi ? 'Lỗ'                      : 'Loss';
  String get plLow         => isVi ? 'Lãi thấp'                : 'Low margin';
  String get plNormal      => isVi ? 'Bình thường'             : 'Normal';
  String get plProfit      => isVi ? 'Lãi cao'                 : 'High margin';

  String get debtUncollected => isVi ? 'TỔNG CHƯA THU'         : 'TOTAL RECEIVABLE';
  String get debtUnitCust  => isVi ? 'khách'                   : 'customers';
  String get debtUnitOrder => isVi ? 'đơn'                     : 'orders';
  String get addNew        => isVi ? '＋ Thêm mới'             : '＋ Add New';
  String get noDebt        => isVi ? 'Không có công nợ'        : 'No receivables';
  String get noDebtSub     => isVi ? 'Tất cả khách hàng đã thanh toán' : 'All customers have paid';
  String get newDebt       => isVi ? '✦ CÔNG NỢ MỚI'           : '✦ NEW RECEIVABLE';
  String get customerLabel => isVi ? 'Khách hàng'              : 'Customer';
  String get amountLabel   => isVi ? 'Số tiền (đ)'             : 'Amount (₫)';
  String get orderDate     => isVi ? 'Ngày tạo đơn'            : 'Order Date';
  String get deliveryDate  => isVi ? 'Ngày giao hàng'          : 'Delivery Date';
  String get saveDebt      => isVi ? '＋ Lưu công nợ'          : '＋ Save Receivable';
  String get markPaid      => isVi ? '✓ Đánh dấu đã thu'       : '✓ Mark as Paid';
  String get paidBadge     => isVi ? '✓ Đã thu'                : '✓ Paid';
  String get unpaidBadge   => isVi ? '⏳ Chưa thu'             : '⏳ Unpaid';
  String get paidOn        => isVi ? '✓ Thu tiền ngày'         : '✓ Collected on';
  String get noteHint      => isVi ? 'VD: Giao tôm hùm 20kg...' : 'E.g. Lobster delivery 20kg...';
  String get uncollectedLbl=> isVi ? 'chưa thu'                : 'unpaid';
  String get unpaidOrders  => isVi ? 'đơn chưa thu'            : 'unpaid orders';

  String get totalIn       => isVi ? 'Tổng nhập'               : 'Total In';
  String get totalOut      => isVi ? 'Tổng xuất'               : 'Total Out';
  String get invUnits      => isVi ? 'đơn vị'                  : 'units';
  String get viewStock     => isVi ? 'Tồn kho'                  : 'Stock';
  String get viewTx        => isVi ? 'Giao dịch'               : 'Transactions';
  String get newEntry      => isVi ? '✦ PHIẾU MỚI'             : '✦ NEW ENTRY';
  String get typeIn        => isVi ? 'Nhập'                     : 'In';
  String get typeOut       => isVi ? 'Xuất'                     : 'Out';
  String get sfItem        => isVi ? 'Mặt hàng hải sản'        : 'Seafood item';
  String get qtyLabel      => isVi ? 'Khối lượng'              : 'Quantity';
  String get negHint       => isVi ? 'âm = hoàn hàng'          : 'negative = return';
  String get addEntry      => isVi ? '＋ Thêm phiếu'           : '＋ Add Entry';
  String get noEntries     => isVi ? 'Chưa có giao dịch nào'   : 'No transactions yet';
  String get noSfHint      => isVi ? 'Thêm hải sản ở tab Báo giá → Giá gốc' : 'Add seafood in Quotes → Base Prices';
  String get returns_      => isVi ? '↩ Hoàn hàng'             : '↩ Return';
  String get returnToStock => isVi ? 'trả lại kho'             : 'returned to stock';
  String get alreadyOut    => isVi ? 'Đã xuất'                 : 'Exported';
  String get remaining     => isVi ? 'Còn lại'                 : 'Remaining';
  String get invoicesUnit  => isVi ? 'phiếu'                   : 'entries';

  String get custTitle     => isVi ? 'Khách hàng'              : 'Customers';
  String get newCust       => isVi ? '✦ KHÁCH HÀNG MỚI'        : '✦ NEW CUSTOMER';
  String get custNameLabel => isVi ? 'Tên khách hàng'          : 'Customer name';
  String get custNameHint  => isVi ? 'VD: Nhà hàng Sài Gòn'   : 'E.g. Saigon Restaurant';
  String get custType      => isVi ? 'Loại'                    : 'Type';
  String get coeff         => isVi ? 'Hệ số'                   : 'Coefficient';
  String get addCust       => isVi ? 'Thêm khách hàng'         : 'Add Customer';
  String get editCust      => isVi ? 'Chỉnh sửa khách hàng'   : 'Edit Customer';
  String get custAddress   => isVi ? 'Địa chỉ'                : 'Address';
  String get custAddressHint => isVi ? 'VD: 123 Lê Lợi, Q.1' : 'E.g. 123 Le Loi St';
  String get custTaxCode   => isVi ? 'Mã số thuế'             : 'Tax code';
  String get custTaxHint   => isVi ? 'VD: 0123456789'         : 'E.g. 0123456789';
  String get optional      => isVi ? 'tuỳ chọn'               : 'optional';
  String get saveChanges   => isVi ? 'Lưu thay đổi'           : 'Save changes';
  String get taxPrefix     => isVi ? 'MST'                    : 'TIN';
  String get tblSeafood    => isVi ? 'Hải sản'                : 'Seafood';
  String get tblBase       => isVi ? 'Gốc'                    : 'Base';
  String get tblSell       => isVi ? 'Bán'                    : 'Sell';
  String get errAvatarUpload => isVi ? 'Lỗi cập nhật ảnh'    : 'Failed to update avatar';
  String get errPrefix     => isVi ? 'Lỗi'                    : 'Error';
  String get ordersSub     => isVi ? 'Tạo và theo dõi đơn hàng,\ncập nhật trạng thái giao hàng.' : 'Create and track orders,\nupdate delivery status.';
  String get sellTotal     => isVi ? 'Tổng giá bán dự kiến'    : 'Expected sell total';
  String get noBaseTbl     => isVi ? 'Chưa có giá gốc'         : 'No base prices';
  String get deleteQ       => isVi ? 'Xoá?'                    : 'Delete?';
  String get editSeafood   => isVi ? 'Chỉnh sửa hải sản'       : 'Edit seafood';
  String get savedToast    => isVi ? 'Đã lưu'                  : 'Saved';
  String get addSfToast    => isVi ? 'Đã thêm'                 : 'Added';

  String get loginRemember   => isVi ? 'Ghi nhớ đăng nhập'          : 'Remember me';
  String get loginRegHint    => isVi ? 'Chưa có tài khoản? '         : "Don't have an account? ";
  String get loginRegLink    => isVi ? 'Đăng ký ngay'                : 'Sign up';
  String get tabNotif        => isVi ? 'Thông báo'                   : 'Notifications';
  String get notifPermTitle  => isVi ? 'Bật thông báo'               : 'Enable Notifications';
  String get notifPermBody   => isVi ? 'Nhận thông báo tức thì khi có công nợ mới, thanh toán được cập nhật, và các hoạt động quan trọng.' : 'Get instant alerts for new receivables, payment updates, and important activity.';
  String get notifPermAllow  => isVi ? 'Cho phép thông báo'          : 'Allow Notifications';
  String get notifPermLater  => isVi ? 'Để sau'                      : 'Not now';
  String get notifTitle      => isVi ? 'Thông báo'                   : 'Notifications';
  String get markAllRead     => isVi ? 'Đọc tất cả'                  : 'Mark all read';
  String get clearAll        => isVi ? 'Xóa tất cả'                  : 'Clear all';
  String get noNotif         => isVi ? 'Chưa có thông báo'           : 'No notifications';
  String get noNotifSub      => isVi ? 'Các hoạt động công nợ, báo giá sẽ hiện ở đây' : 'Debt and quote activities will appear here';
  String get clearAllQ       => isVi ? 'Xóa tất cả thông báo?'       : 'Clear all notifications?';
  String get cannotUndo      => isVi ? 'Hành động này không thể hoàn tác.' : 'This action cannot be undone.';
  String get createdBy       => isVi ? 'Được tạo bởi'                : 'Created by';
  String get noteLabel       => isVi ? 'Ghi chú'                     : 'Note';
  String get imageOptional   => isVi ? 'Hình ảnh (tuỳ chọn)'         : 'Image (optional)';
  String get pickImage       => isVi ? 'Chọn ảnh từ thư viện'        : 'Choose from gallery';
  String get pickImageShort  => isVi ? 'Chọn ảnh'                    : 'Choose image';
  String get dateLabel       => isVi ? 'Ngày'                        : 'Date';
  String get dateCreated     => isVi ? 'Tạo đơn'                     : 'Created';
  String get dateDelivery    => isVi ? 'Giao hàng'                   : 'Delivery';
  String get debtSummUnpaid  => isVi ? 'Chưa thu'                    : 'Unpaid';
  String get debtSummPaid    => isVi ? 'Đã thu'                      : 'Collected';
  String get addDebtNew      => isVi ? '＋ Thêm công nợ mới'         : '＋ Add new receivable';
  String get noSf            => isVi ? 'Chưa có hải sản'             : 'No seafood items';
  String get viewHistTx      => isVi ? 'Lịch sử'                     : 'History';
  String get deleteDebtToast => isVi ? 'Đã xoá'                      : 'Deleted';
  String get addDebtToast    => isVi ? 'Đã thêm công nợ'             : 'Receivable added';
  String get addEntryToast   => isVi ? 'Đã thêm phiếu'              : 'Entry added';
  String get updCoeffToast   => isVi ? 'Đã cập nhật hệ số'           : 'Coefficient updated';
  String get updToast        => isVi ? 'Đã cập nhật'                 : 'Updated';
  String get delCustToast    => isVi ? 'Đã xoá'                      : 'Deleted';
  String get addCustToast    => isVi ? 'Đã thêm khách hàng'          : 'Customer added';
  String get regTitle        => isVi ? 'Tạo tài khoản'               : 'Create Account';
  String get regWelcome      => isVi ? 'Bắt đầu quản lý hải sản ngay' : 'Start managing seafood now';
  String get regName         => isVi ? 'Họ tên'                      : 'Full name';
  String get regNameHint     => isVi ? 'Nguyễn Văn A'                : 'John Doe';
  String get regPhone        => isVi ? 'Số điện thoại (tuỳ chọn)'    : 'Phone (optional)';
  String get regPhoneHint    => isVi ? '0901 234 567'                 : '555-123-4567';
  String get regButton       => isVi ? 'Tạo tài khoản →'             : 'Create Account →';
  String get regLoading      => isVi ? 'Đang tạo tài khoản...'       : 'Creating account...';
  String get regHaveAcct     => isVi ? 'Đã có tài khoản? '           : 'Already have an account? ';
  String get regSignIn       => isVi ? 'Đăng nhập'                   : 'Sign In';
  String get forgotTitle     => isVi ? 'Đặt lại mật khẩu'            : 'Reset Password';
  String get forgotSub       => isVi ? 'Nhập email để nhận link đặt lại mật khẩu' : 'Enter your email to receive a reset link';
  String get forgotButton    => isVi ? 'Gửi email đặt lại'           : 'Send Reset Email';
  String get forgotLoading   => isVi ? 'Đang gửi...'                 : 'Sending...';
  String get forgotSentTitle => isVi ? 'Email đã gửi!'               : 'Email sent!';
  String get forgotSentSub   => isVi ? 'Kiểm tra hộp thư và làm theo hướng dẫn' : 'Check your inbox and follow the instructions';
  String get backToLogin     => isVi ? '← Quay lại đăng nhập'        : '← Back to Sign In';
  String get sentNotifDevices => isVi ? 'Đã gửi tới'                 : 'Sent to';
  String get devices         => isVi ? 'thiết bị'                    : 'devices';
  String get searchSeafood   => isVi ? 'Tìm tên hải sản...'          : 'Search seafood...';
  String get searchCustomer  => isVi ? 'Tìm tên khách hàng...'       : 'Search customer...';
  String get allMonths       => isVi ? 'Tất cả'                       : 'All months';
  String get allYears        => isVi ? 'Tất cả'                      : 'All years';
  String get noTxFound       => isVi ? 'Không tìm thấy giao dịch'    : 'No transactions found';
  String get noTx            => isVi ? 'Chưa có giao dịch'           : 'No transactions yet';
  String get invoicesUnitTx  => isVi ? 'phiếu'                       : 'entries';
  String get summaryHeaderTx => isVi ? '📊 TỔNG NHẬP − XUẤT'        : '📊 TOTAL IN − OUT';
  String get negQtyHint      => isVi ? '0 hoặc −số'                  : '0 or −qty';
  String get unknownSeafood  => isVi ? 'Không rõ'                    : 'Unknown';
  String get relJustNow      => isVi ? 'Vừa xong'                    : 'Just now';
  String relMinAgo(int m)    => isVi ? '$m phút trước'               : '$m min ago';
  String relHourAgo(int h)   => isVi ? '$h giờ trước'                : '$h hr ago';
  String relDayAgo(int d)    => isVi ? '$d ngày trước'               : '$d days ago';

  List<String> get months => isVi
    ? ['Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6','Tháng 7','Tháng 8','Tháng 9','Tháng 10','Tháng 11','Tháng 12']
    : ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
}
