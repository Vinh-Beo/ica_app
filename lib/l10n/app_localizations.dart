import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý báo giá hải sản'**
  String get appSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginTitle;

  /// No description provided for @loginWelcome.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng trở lại 👋'**
  String get loginWelcome;

  /// No description provided for @loginEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginEmailHint.
  ///
  /// In vi, this message translates to:
  /// **'example@email.com'**
  String get loginEmailHint;

  /// No description provided for @loginPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get loginPassword;

  /// No description provided for @loginForgot.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get loginForgot;

  /// No description provided for @loginButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập →'**
  String get loginButton;

  /// No description provided for @loginLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang đăng nhập...'**
  String get loginLoading;

  /// No description provided for @loginErrEmail.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email'**
  String get loginErrEmail;

  /// No description provided for @loginErrPassword.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu'**
  String get loginErrPassword;

  /// No description provided for @loginFooter.
  ///
  /// In vi, this message translates to:
  /// **'iCa v1.0 · © 2026'**
  String get loginFooter;

  /// No description provided for @signOut.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get signOut;

  /// No description provided for @tabQuote.
  ///
  /// In vi, this message translates to:
  /// **'Báo giá'**
  String get tabQuote;

  /// No description provided for @tabDebt.
  ///
  /// In vi, this message translates to:
  /// **'Công nợ'**
  String get tabDebt;

  /// No description provided for @tabOrders.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng'**
  String get tabOrders;

  /// No description provided for @tabInventory.
  ///
  /// In vi, this message translates to:
  /// **'Nhập xuất'**
  String get tabInventory;

  /// No description provided for @tabCustomers.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get tabCustomers;

  /// No description provided for @add.
  ///
  /// In vi, this message translates to:
  /// **'＋ Thêm'**
  String get add;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'✕ Đóng'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp ra mắt'**
  String get comingSoon;

  /// No description provided for @baseTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giá gốc hải sản'**
  String get baseTitle;

  /// No description provided for @baseSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Dùng chung cho mọi khách'**
  String get baseSubtitle;

  /// No description provided for @items.
  ///
  /// In vi, this message translates to:
  /// **'Mặt hàng'**
  String get items;

  /// No description provided for @priced.
  ///
  /// In vi, this message translates to:
  /// **'Đã có giá'**
  String get priced;

  /// No description provided for @notPriced.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giá'**
  String get notPriced;

  /// No description provided for @addSeafood.
  ///
  /// In vi, this message translates to:
  /// **'＋ Thêm hải sản mới'**
  String get addSeafood;

  /// No description provided for @seafoodName.
  ///
  /// In vi, this message translates to:
  /// **'Tên hải sản'**
  String get seafoodName;

  /// No description provided for @seafoodNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Tôm Hùm, Cá Thu...'**
  String get seafoodNameHint;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// No description provided for @unit.
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị'**
  String get unit;

  /// No description provided for @basePrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá gốc (đ)'**
  String get basePrice;

  /// No description provided for @addToList.
  ///
  /// In vi, this message translates to:
  /// **'＋ Thêm vào danh sách'**
  String get addToList;

  /// No description provided for @quotePeriod.
  ///
  /// In vi, this message translates to:
  /// **'🗓 KỲ BÁO GIÁ'**
  String get quotePeriod;

  /// No description provided for @quoteCustomer.
  ///
  /// In vi, this message translates to:
  /// **'🏷 KHÁCH HÀNG'**
  String get quoteCustomer;

  /// No description provided for @selectAll.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tất cả'**
  String get selectAll;

  /// No description provided for @saveQuote.
  ///
  /// In vi, this message translates to:
  /// **'💾 Lưu Báo Giá'**
  String get saveQuote;

  /// No description provided for @itemsLabel.
  ///
  /// In vi, this message translates to:
  /// **'mặt hàng'**
  String get itemsLabel;

  /// No description provided for @noBaseGo.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giá gốc nào'**
  String get noBaseGo;

  /// No description provided for @goBase.
  ///
  /// In vi, this message translates to:
  /// **'→ Nhập giá gốc'**
  String get goBase;

  /// No description provided for @scBase.
  ///
  /// In vi, this message translates to:
  /// **'Giá gốc'**
  String get scBase;

  /// No description provided for @scHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get scHistory;

  /// No description provided for @scView.
  ///
  /// In vi, this message translates to:
  /// **'Xem & chỉnh'**
  String get scView;

  /// No description provided for @scReview.
  ///
  /// In vi, this message translates to:
  /// **'Xem lại'**
  String get scReview;

  /// No description provided for @histTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử báo giá'**
  String get histTitle;

  /// No description provided for @histSaved.
  ///
  /// In vi, this message translates to:
  /// **'báo giá đã lưu'**
  String get histSaved;

  /// No description provided for @noQuotes.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có báo giá nào'**
  String get noQuotes;

  /// No description provided for @statItems.
  ///
  /// In vi, this message translates to:
  /// **'Mặt hàng'**
  String get statItems;

  /// No description provided for @statProfit.
  ///
  /// In vi, this message translates to:
  /// **'Lợi nhuận'**
  String get statProfit;

  /// No description provided for @statBase.
  ///
  /// In vi, this message translates to:
  /// **'Tổng giá gốc'**
  String get statBase;

  /// No description provided for @statSell.
  ///
  /// In vi, this message translates to:
  /// **'Tổng giá bán'**
  String get statSell;

  /// No description provided for @exportExcel.
  ///
  /// In vi, this message translates to:
  /// **'Xuất Excel'**
  String get exportExcel;

  /// No description provided for @plLoss.
  ///
  /// In vi, this message translates to:
  /// **'Lỗ'**
  String get plLoss;

  /// No description provided for @plLow.
  ///
  /// In vi, this message translates to:
  /// **'Lãi thấp'**
  String get plLow;

  /// No description provided for @plNormal.
  ///
  /// In vi, this message translates to:
  /// **'Bình thường'**
  String get plNormal;

  /// No description provided for @plProfit.
  ///
  /// In vi, this message translates to:
  /// **'Lãi cao'**
  String get plProfit;

  /// No description provided for @debtUncollected.
  ///
  /// In vi, this message translates to:
  /// **'TỔNG CHƯA THU'**
  String get debtUncollected;

  /// No description provided for @debtUnitCustomer.
  ///
  /// In vi, this message translates to:
  /// **'khách'**
  String get debtUnitCustomer;

  /// No description provided for @debtUnitOrder.
  ///
  /// In vi, this message translates to:
  /// **'đơn'**
  String get debtUnitOrder;

  /// No description provided for @addNew.
  ///
  /// In vi, this message translates to:
  /// **'＋ Thêm mới'**
  String get addNew;

  /// No description provided for @noDebt.
  ///
  /// In vi, this message translates to:
  /// **'Không có công nợ'**
  String get noDebt;

  /// No description provided for @noDebtSub.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả khách hàng đã thanh toán'**
  String get noDebtSub;

  /// No description provided for @newDebt.
  ///
  /// In vi, this message translates to:
  /// **'CÔNG NỢ MỚI'**
  String get newDebt;

  /// No description provided for @customerLabel.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get customerLabel;

  /// No description provided for @amountLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền (đ)'**
  String get amountLabel;

  /// No description provided for @orderDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày tạo đơn'**
  String get orderDate;

  /// No description provided for @deliveryDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày giao hàng'**
  String get deliveryDate;

  /// No description provided for @saveDebt.
  ///
  /// In vi, this message translates to:
  /// **'＋ Lưu công nợ'**
  String get saveDebt;

  /// No description provided for @markPaid.
  ///
  /// In vi, this message translates to:
  /// **'✓ Đánh dấu đã thu'**
  String get markPaid;

  /// No description provided for @paidBadge.
  ///
  /// In vi, this message translates to:
  /// **'✓ Đã thu'**
  String get paidBadge;

  /// No description provided for @unpaidBadge.
  ///
  /// In vi, this message translates to:
  /// **'⏳ Chưa thu'**
  String get unpaidBadge;

  /// No description provided for @paidOn.
  ///
  /// In vi, this message translates to:
  /// **'✓ Thu tiền ngày'**
  String get paidOn;

  /// No description provided for @noteHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Giao tôm hùm 20kg...'**
  String get noteHint;

  /// No description provided for @uncollectedLabel.
  ///
  /// In vi, this message translates to:
  /// **'chưa thu'**
  String get uncollectedLabel;

  /// No description provided for @unpaidOrders.
  ///
  /// In vi, this message translates to:
  /// **'đơn chưa thu'**
  String get unpaidOrders;

  /// No description provided for @totalIn.
  ///
  /// In vi, this message translates to:
  /// **'Tổng nhập'**
  String get totalIn;

  /// No description provided for @totalOut.
  ///
  /// In vi, this message translates to:
  /// **'Tổng xuất'**
  String get totalOut;

  /// No description provided for @invUnits.
  ///
  /// In vi, this message translates to:
  /// **'đơn vị'**
  String get invUnits;

  /// No description provided for @viewStock.
  ///
  /// In vi, this message translates to:
  /// **'Tồn kho'**
  String get viewStock;

  /// No description provided for @viewTx.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get viewTx;

  /// No description provided for @newEntry.
  ///
  /// In vi, this message translates to:
  /// **'PHIẾU MỚI'**
  String get newEntry;

  /// No description provided for @typeIn.
  ///
  /// In vi, this message translates to:
  /// **'Nhập'**
  String get typeIn;

  /// No description provided for @typeOut.
  ///
  /// In vi, this message translates to:
  /// **'Xuất'**
  String get typeOut;

  /// No description provided for @sfItem.
  ///
  /// In vi, this message translates to:
  /// **'Mặt hàng hải sản'**
  String get sfItem;

  /// No description provided for @qtyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Khối lượng'**
  String get qtyLabel;

  /// No description provided for @negHint.
  ///
  /// In vi, this message translates to:
  /// **'âm = hoàn hàng'**
  String get negHint;

  /// No description provided for @addEntry.
  ///
  /// In vi, this message translates to:
  /// **'＋ Thêm phiếu'**
  String get addEntry;

  /// No description provided for @noEntries.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch nào'**
  String get noEntries;

  /// No description provided for @noSfHint.
  ///
  /// In vi, this message translates to:
  /// **'Thêm hải sản ở tab Báo giá → Giá gốc'**
  String get noSfHint;

  /// No description provided for @returns.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn hàng'**
  String get returns;

  /// No description provided for @returnToStock.
  ///
  /// In vi, this message translates to:
  /// **'trả lại kho'**
  String get returnToStock;

  /// No description provided for @alreadyOut.
  ///
  /// In vi, this message translates to:
  /// **'Đã xuất'**
  String get alreadyOut;

  /// No description provided for @remaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn lại'**
  String get remaining;

  /// No description provided for @custTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get custTitle;

  /// No description provided for @newCust.
  ///
  /// In vi, this message translates to:
  /// **'KHÁCH HÀNG MỚI'**
  String get newCust;

  /// No description provided for @custNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên khách hàng'**
  String get custNameLabel;

  /// No description provided for @custNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Nhà hàng Sài Gòn'**
  String get custNameHint;

  /// No description provided for @custType.
  ///
  /// In vi, this message translates to:
  /// **'Loại'**
  String get custType;

  /// No description provided for @coeff.
  ///
  /// In vi, this message translates to:
  /// **'Hệ số'**
  String get coeff;

  /// No description provided for @addCust.
  ///
  /// In vi, this message translates to:
  /// **'Thêm khách hàng'**
  String get addCust;

  /// No description provided for @sellTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng giá bán dự kiến'**
  String get sellTotal;

  /// No description provided for @noBaseTbl.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giá gốc'**
  String get noBaseTbl;

  /// No description provided for @deleteQ.
  ///
  /// In vi, this message translates to:
  /// **'Xoá?'**
  String get deleteQ;

  /// No description provided for @invoicesUnit.
  ///
  /// In vi, this message translates to:
  /// **'phiếu'**
  String get invoicesUnit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
