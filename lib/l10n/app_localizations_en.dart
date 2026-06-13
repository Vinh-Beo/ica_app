// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appSubtitle => 'Seafood price management';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginWelcome => 'Welcome back 👋';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginEmailHint => 'example@email.com';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginForgot => 'Forgot password?';

  @override
  String get loginButton => 'Sign In →';

  @override
  String get loginLoading => 'Signing in...';

  @override
  String get loginErrEmail => 'Please enter your email';

  @override
  String get loginErrPassword => 'Please enter your password';

  @override
  String get loginFooter => 'iCa v1.0 · © 2026';

  @override
  String get signOut => 'Sign Out';

  @override
  String get tabQuote => 'Quotes';

  @override
  String get tabDebt => 'Receivables';

  @override
  String get tabOrders => 'Orders';

  @override
  String get tabInventory => 'Inventory';

  @override
  String get tabCustomers => 'Customers';

  @override
  String get add => '＋ Add';

  @override
  String get close => '✕ Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get baseTitle => 'Base Prices';

  @override
  String get baseSubtitle => 'Shared across all customers';

  @override
  String get items => 'Items';

  @override
  String get priced => 'Priced';

  @override
  String get notPriced => 'Unpriced';

  @override
  String get addSeafood => '＋ Add new seafood';

  @override
  String get seafoodName => 'Seafood name';

  @override
  String get seafoodNameHint => 'E.g. Lobster, Salmon...';

  @override
  String get category => 'Category';

  @override
  String get unit => 'Unit';

  @override
  String get basePrice => 'Base price (₫)';

  @override
  String get addToList => '＋ Add to list';

  @override
  String get quotePeriod => '🗓 QUOTE PERIOD';

  @override
  String get quoteCustomer => '🏷 CUSTOMER';

  @override
  String get selectAll => 'Select all';

  @override
  String get saveQuote => '💾 Save Quote';

  @override
  String get itemsLabel => 'items';

  @override
  String get noBaseGo => 'No base prices yet';

  @override
  String get goBase => '→ Add base prices';

  @override
  String get scBase => 'Base Prices';

  @override
  String get scHistory => 'History';

  @override
  String get scView => 'View & edit';

  @override
  String get scReview => 'View all';

  @override
  String get histTitle => 'Quote History';

  @override
  String get histSaved => 'saved quotes';

  @override
  String get noQuotes => 'No quotes yet';

  @override
  String get statItems => 'Items';

  @override
  String get statProfit => 'Profit';

  @override
  String get statBase => 'Total base';

  @override
  String get statSell => 'Total sell';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get plLoss => 'Loss';

  @override
  String get plLow => 'Low margin';

  @override
  String get plNormal => 'Normal';

  @override
  String get plProfit => 'High margin';

  @override
  String get debtUncollected => 'TOTAL RECEIVABLE';

  @override
  String get debtUnitCustomer => 'customers';

  @override
  String get debtUnitOrder => 'orders';

  @override
  String get addNew => '＋ Add New';

  @override
  String get noDebt => 'No receivables';

  @override
  String get noDebtSub => 'All customers have paid';

  @override
  String get newDebt => 'NEW RECEIVABLE';

  @override
  String get customerLabel => 'Customer';

  @override
  String get amountLabel => 'Amount (₫)';

  @override
  String get orderDate => 'Order Date';

  @override
  String get deliveryDate => 'Delivery Date';

  @override
  String get saveDebt => '＋ Save Receivable';

  @override
  String get markPaid => '✓ Mark as Paid';

  @override
  String get paidBadge => '✓ Paid';

  @override
  String get unpaidBadge => '⏳ Unpaid';

  @override
  String get paidOn => '✓ Collected on';

  @override
  String get noteHint => 'E.g. Lobster delivery 20kg...';

  @override
  String get uncollectedLabel => 'unpaid';

  @override
  String get unpaidOrders => 'unpaid orders';

  @override
  String get totalIn => 'Total In';

  @override
  String get totalOut => 'Total Out';

  @override
  String get invUnits => 'units';

  @override
  String get viewStock => 'Stock';

  @override
  String get viewTx => 'Transactions';

  @override
  String get newEntry => 'NEW ENTRY';

  @override
  String get typeIn => 'In';

  @override
  String get typeOut => 'Out';

  @override
  String get sfItem => 'Seafood item';

  @override
  String get qtyLabel => 'Quantity';

  @override
  String get negHint => 'negative = return';

  @override
  String get addEntry => '＋ Add Entry';

  @override
  String get noEntries => 'No transactions yet';

  @override
  String get noSfHint => 'Add seafood in Quotes → Base Prices';

  @override
  String get returns => 'Return';

  @override
  String get returnToStock => 'returned to stock';

  @override
  String get alreadyOut => 'Exported';

  @override
  String get remaining => 'Remaining';

  @override
  String get custTitle => 'Customers';

  @override
  String get newCust => 'NEW CUSTOMER';

  @override
  String get custNameLabel => 'Customer name';

  @override
  String get custNameHint => 'E.g. Saigon Restaurant';

  @override
  String get custType => 'Type';

  @override
  String get coeff => 'Coefficient';

  @override
  String get addCust => 'Add Customer';

  @override
  String get sellTotal => 'Expected sell total';

  @override
  String get noBaseTbl => 'No base prices';

  @override
  String get deleteQ => 'Delete?';

  @override
  String get invoicesUnit => 'entries';
}
