import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_state.dart';
import '../constants.dart';
import '../l10n/app_strings.dart';
import '../services/firebase_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/lang_switcher.dart';
import 'quote_screen.dart';
import 'debt_screen.dart';
import 'import_export_screen.dart';
import 'client_screen.dart';
import 'notification_screen.dart';

class MainShell extends StatefulWidget {
  MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  bool _showUserMenu = false;

  final _pages =  [
    QuoteScreen(),
    DebtScreen(),
    ImportExportScreen(),
    ClientScreen(),
    const NotificationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initNotif());
    // Khi user tap notification từ background → mở đúng tab
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotifTap);
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg != null) _onNotifTap(msg);
    });
  }

  void _onNotifTap(RemoteMessage msg) {
    // data['tab']: 'debt' | 'quote' | 'inventory' | 'customers' | 'notifications'
    const tabMap = {'quote': 0, 'debt': 1, 'inventory': 2, 'customers': 3, 'notifications': 4};
    final tab = tabMap[msg.data['tab']] ?? 1; // mặc định: tab Công nợ
    if (mounted) setState(() => _tab = tab);
  }

  Future<void> _initNotif() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('notif_permission_asked') ?? false;
    if (!mounted) return;
    if (!asked) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _NotifPermissionSheet(prefs: prefs),
      );
    } else {
      FirebaseService.instance.initMessaging();
    }
  }

  void _onTabTap(int i) => setState(() { _tab = i; _showUserMenu = false; });

  @override
  Widget build(BuildContext context) {
    final s        = AppStrings.of(context);
    // Lấy user từ Firebase Auth
    final fbUser   = FirebaseService.instance.currentUser;
    final userName = fbUser?.displayName ?? fbUser?.email?.split('@').first ?? '';
    final userEmail = fbUser?.email ?? '';
    final user     = _UserInfo(userName, userEmail);
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: context.p.bg,
      body: Column(children: [
        // ── Top Bar ──
        SafeArea(
          bottom: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 12, 16, 12),
            decoration: BoxDecoration(
              color: context.p.surface,
              border: Border(bottom: BorderSide(color: context.p.border))),
            child: Row(children: [
              WaveLogo(size: 24),
              SizedBox(width: 9),
              Text('iCa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: context.p.navy, letterSpacing: -0.4)),
              Spacer(),
              const LangSwitcher(),
              SizedBox(width: 8),

              // ── User avatar + sign out menu ──
              GestureDetector(
                onTap: () => setState(() => _showUserMenu = !_showUserMenu),
                child: Container(
                  padding: EdgeInsets.fromLTRB(6, 5, 10, 5),
                  decoration: BoxDecoration(
                    color: _showUserMenu ? context.p.surface2 : context.p.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.p.border, width: 1.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [context.p.navy, context.p.teal]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(initials,
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
                    ),
                    SizedBox(width: 7),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 80),
                      child: Text(user.name, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.p.textMain)),
                    ),
                    SizedBox(width: 4),
                    Icon(_showUserMenu ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 16, color: context.p.textMuted),
                  ]),
                ),
              ),
            ]),
          ),
        ),

        // ── Content ──
        Expanded(
          child: Stack(children: [
            IndexedStack(index: _tab, children: _pages),

            // Dismiss menu on tap outside
            if (_showUserMenu)
              GestureDetector(
                onTap: () => setState(() => _showUserMenu = false),
                child: Container(color: Colors.transparent),
              ),

            // ── User dropdown menu ──
            if (_showUserMenu)
              Positioned(
                top: 0, right: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  shadowColor: context.p.textMain.withOpacity(0.15),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: context.p.surface, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.p.border),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      // user info
                      Padding(
                        padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [context.p.navy, context.p.teal]),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(initials,
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                          ),
                          SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(user.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.p.textMain), overflow: TextOverflow.ellipsis),
                            Text(user.email, style: TextStyle(fontSize: 11, color: context.p.textMuted), overflow: TextOverflow.ellipsis),
                          ])),
                        ]),
                      ),
                      Divider(height: 1, color: context.p.surface2),
                      // sign out button
                      InkWell(
                        onTap: () async {
                          setState(() => _showUserMenu = false);
                          // Xoá thông tin đăng nhập đã lưu để không tự login lại
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('remember_me');
                          await prefs.remove('saved_email');
                          await prefs.remove('saved_password');
                          try {
                            await FirebaseService.instance.signOut();
                          } catch (_) {
                            await FirebaseService.instance.forceSignOut();
                          }
                        },
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(children: [
                            Icon(Icons.logout_rounded, size: 16, color: Color(0xFFDC2626)),
                            SizedBox(width: 10),
                            Text(s.signOut, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ]),

      // ── Bottom Navigation ──
      bottomNavigationBar: _BottomNav(currentTab: _tab, onTap: _onTabTap),
    );
  }
}

// ── Notification Permission Sheet ─────────────────────────────────────────────
class _NotifPermissionSheet extends StatefulWidget {
  final SharedPreferences prefs;
  const _NotifPermissionSheet({required this.prefs});
  @override
  State<_NotifPermissionSheet> createState() => _NotifPermissionSheetState();
}

class _NotifPermissionSheetState extends State<_NotifPermissionSheet> {
  Future<void> _allow() async {
    await widget.prefs.setBool('notif_permission_asked', true);
    if (mounted) Navigator.pop(context);
    // Chạy nền — không block UI. OS dialog sẽ hiện trên màn hình chính.
    FirebaseService.instance.initMessaging();
  }

  Future<void> _skip() async {
    await widget.prefs.setBool('notif_permission_asked', true);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2))),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Color(0xFF6366F1).withValues(alpha: 0.35), blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: Icon(Icons.notifications_active_rounded, color: Colors.white, size: 32),
        ),
        SizedBox(height: 18),
        Text(
          s.notifPermTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.p.textMain),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          s.notifPermBody,
          style: TextStyle(fontSize: 13, color: context.p.textMuted, height: 1.55),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        GestureDetector(
          onTap: _allow,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Color(0xFF6366F1).withValues(alpha: 0.4), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Center(child: Text(s.notifPermAllow, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: _skip,
          child: Container(
            height: 44,
            child: Center(child: Text(s.notifPermLater, style: TextStyle(fontSize: 13, color: context.p.textMuted, fontWeight: FontWeight.w600))),
          ),
        ),
      ]),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTap;
  _BottomNav({required this.currentTab, required this.onTap});

  static final _tabIcons = [
    Icons.request_quote_outlined,
    Icons.credit_card_outlined,
    Icons.swap_horiz_outlined,
    Icons.people_outline,
    Icons.notifications_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final s      = AppStrings.of(context);
    final labels = [s.tabQuote, s.tabDebt, s.tabInventory, s.tabCustomers, s.tabNotif];
    final unread = context.watch<AppState>().unreadCount;
    return Container(
      decoration: BoxDecoration(
        color: context.p.surface,
        border: Border(top: BorderSide(color: context.p.border)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 4, top: 8),
      child: Row(
        children: List.generate(_tabIcons.length, (i) {
          final active = currentTab == i;
          final showBadge = i == 4 && unread > 0;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Stack(clipBehavior: Clip.none, children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 220),
                    width: 44, height: 30,
                    decoration: BoxDecoration(
                      gradient: active ? kGradPP : null,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: active
                          ? [BoxShadow(color: kPurple.withOpacity(0.4), blurRadius: 12, offset: Offset(0, 4))]
                          : null,
                    ),
                    child: Center(child: Icon(_tabIcons[i],
                        size: 20, color: active ? Colors.white : context.p.textMuted)),
                  ),
                  if (showBadge)
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 16),
                        height: 16,
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.p.surface, width: 2),
                        ),
                        child: Center(child: Text(unread > 9 ? '9+' : '$unread',
                            style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800))),
                      ),
                    ),
                ]),
                SizedBox(height: 3),
                Text(labels[i],
                    style: TextStyle(fontSize: 9, fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? Color(0xFF9333EA) : context.p.textMuted)),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// Helper nhỏ giữ tên + email user hiển thị trên top bar
class _UserInfo {
  final String name;
  final String email;
  _UserInfo(this.name, this.email);
}
