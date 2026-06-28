import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iCa/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'app_state.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

// NOTE: Chạy `flutter gen-l10n` sau `flutter pub get` để sinh AppLocalizations.

const _kPushChannel     = 'ica_push';
const _kPushChannelName = 'iCa Thông báo';

/// Dùng để hiển thị local notification khi app đang mở (Android foreground).
final FlutterLocalNotificationsPlugin localNotif =
    FlutterLocalNotificationsPlugin();

/// Handler nhận push khi app ở background / bị tắt — phải là top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseBgHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ── Firebase ──
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseBgHandler);

  // ── Local notifications (Android foreground display) ──
  await localNotif.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await localNotif
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        _kPushChannel, _kPushChannelName,
        description: 'Thông báo công nợ & hoạt động từ iCa',
        importance: Importance.high,
      ));

  // iOS: hiển thị banner ngay cả khi app đang mở
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, badge: true, sound: true,
  );

  // Android foreground: FCM không tự hiển thị → dùng local notification
  FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
    final n = msg.notification;
    if (n == null) return;
    localNotif.show(
      n.hashCode, n.title, n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _kPushChannel, _kPushChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(sound: 'default'),
      ),
    );
  });

  runApp(
    DevicePreview(
      enabled: kIsWeb && !kReleaseMode, // chỉ dùng Device Preview cho bản web
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => LangState()),
          ChangeNotifierProvider(create: (_) => ThemeState()),
        ],
        child: const iCaApp(),
    ),
  ));
}

// ── Language state ─────────────────────────────────────────────────────────────
class LangState extends ChangeNotifier {
  Locale _locale = const Locale('vi');
  Locale get locale => _locale;
  String get langCode => _locale.languageCode;
  void setLocale(String code) {
    final next = Locale(code);
    if (_locale == next) return;
    _locale = next;
    notifyListeners();
  }
  void toggle() {
    _locale = _locale.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    notifyListeners();
  }
}

// ── Theme state (sáng / tối / theo máy) ─────────────────────────────────────────
class ThemeState extends ChangeNotifier {
  static const _prefKey = 'theme_mode';
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  ThemeState() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_prefKey)) {
      case 'light': _mode = ThemeMode.light;
      case 'dark':  _mode = ThemeMode.dark;
      default:      _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }
}

class iCaApp extends StatelessWidget {
  const iCaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale    = context.watch<LangState>().locale;
    final themeMode = context.watch<ThemeState>().mode;
    return MaterialApp(
      title: 'iCa',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // AppLocalizations.delegate,  // bật sau khi flutter gen-l10n
      ],
      themeMode: themeMode, // sáng / tối / theo máy — chọn ở ThemeSwitcher
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: AppPalette.light.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7C8C),
          brightness: Brightness.light,
          surface: AppPalette.light.surface,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: AppPalette.dark.bg,
        canvasColor: AppPalette.dark.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DD4BF),
          brightness: Brightness.dark,
          surface: AppPalette.dark.surface,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none), dialogTheme: DialogThemeData(backgroundColor: AppPalette.dark.surface),
      ),
      home: const _AuthGate(),
    );
  }
}

/// Lắng nghe trạng thái đăng nhập Firebase. Đăng nhập rồi -> MainShell.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF0E7C8C))),
          );
        }
        final loggedIn = snapshot.hasData;
        if (loggedIn) {
          return  const MainShell();
        }
        return  const LoginScreen();
      },
    );
  }
}
