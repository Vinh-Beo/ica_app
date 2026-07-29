import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  bool _showUserMenu = false;
  String? _localAvatarUrl; // URL sau khi đổi avatar trong session này

  final _pages =  [
    const QuoteScreen(),
    const DebtScreen(),
    const ImportExportScreen(),
    const ClientScreen(),
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

    // Đã cho phép thông báo ở cấp hệ điều hành → không cần hỏi lại
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!mounted) return;
    if (granted) {
      await prefs.setBool('notif_permission_asked', true);
      FirebaseService.instance.initMessaging();
      return;
    }

    final asked = prefs.getBool('notif_permission_asked') ?? false;
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

  void _openChangePassword() {
    setState(() => _showUserMenu = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _openChangeAvatar() {
    setState(() => _showUserMenu = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangeAvatarSheet(),
    ).then((result) {
      if (result is String && mounted) setState(() => _localAvatarUrl = result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s        = AppStrings.of(context);
    // Lấy user từ Firebase Auth
    final fbUser   = FirebaseService.instance.currentUser;
    final userName = fbUser?.displayName ?? fbUser?.email?.split('@').first ?? '';
    final userEmail = fbUser?.email ?? '';
    final user     = _UserInfo(userName, userEmail);
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final photoUrl = _localAvatarUrl ?? fbUser?.photoURL;

    return Scaffold(
      backgroundColor: context.p.bg,
      body: Column(children: [
        // ── Top Bar ──
        SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
            decoration: BoxDecoration(
              color: context.p.surface,
              border: Border(bottom: BorderSide(color: context.p.border))),
            child: Row(children: [
              const FishLogo(size: 24),
              const SizedBox(width: 9),
              Text('iCa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: context.p.navy, letterSpacing: -0.4)),
              const Spacer(),
              const LangSwitcher(),
              const SizedBox(width: 8),

              // ── User avatar + menu ──
              GestureDetector(
                onTap: () => setState(() => _showUserMenu = !_showUserMenu),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 5, 10, 5),
                  decoration: BoxDecoration(
                    color: _showUserMenu ? context.p.surface2 : context.p.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.p.border, width: 1.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    _AvatarCircle(photoUrl: photoUrl, initials: initials, size: 26, fontSize: 12),
                    const SizedBox(width: 7),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 80),
                      child: Text(user.name, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.p.textMain)),
                    ),
                    const SizedBox(width: 4),
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
                      // user info header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Row(children: [
                          _AvatarCircle(photoUrl: photoUrl, initials: initials, size: 36, fontSize: 16),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(user.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.p.textMain), overflow: TextOverflow.ellipsis),
                            Text(user.email, style: TextStyle(fontSize: 11, color: context.p.textMuted), overflow: TextOverflow.ellipsis),
                          ])),
                        ]),
                      ),
                      Divider(height: 1, color: context.p.surface2),
                      // đổi mật khẩu
                      InkWell(
                        onTap: _openChangePassword,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          child: Row(children: [
                            Icon(Icons.lock_outline_rounded, size: 16, color: context.p.textMuted),
                            const SizedBox(width: 10),
                            Text('Thay đổi mật khẩu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)),
                          ]),
                        ),
                      ),
                      // đổi avatar
                      InkWell(
                        onTap: _openChangeAvatar,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          child: Row(children: [
                            Icon(Icons.photo_camera_outlined, size: 16, color: context.p.textMuted),
                            const SizedBox(width: 10),
                            Text('Thay đổi ảnh đại diện', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)),
                          ]),
                        ),
                      ),
                      Divider(height: 1, color: context.p.surface2),
                      // đăng xuất
                      InkWell(
                        onTap: () async {
                          setState(() => _showUserMenu = false);
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
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(children: [
                            const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFDC2626)),
                            const SizedBox(width: 10),
                            Text(s.signOut, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2))),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 18),
        Text(
          s.notifPermTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.p.textMain),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          s.notifPermBody,
          style: TextStyle(fontSize: 13, color: context.p.textMuted, height: 1.55),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _allow,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Center(child: Text(s.notifPermAllow, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _skip,
          child: SizedBox(
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
  const _BottomNav({required this.currentTab, required this.onTap});

  static const _icons = [
    (active: Icons.request_quote_rounded,     inactive: Icons.request_quote_outlined),
    (active: Icons.credit_card_rounded,        inactive: Icons.credit_card_outlined),
    (active: Icons.swap_horiz_rounded,         inactive: Icons.swap_horiz_rounded),
    (active: Icons.people_rounded,             inactive: Icons.people_outline_rounded),
    (active: Icons.notifications_rounded,      inactive: Icons.notifications_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<AppState>().unreadCount;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: context.p.surface,
        border: Border(top: BorderSide(color: context.p.border, width: 1)),
        boxShadow: [BoxShadow(color: context.p.textMain.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      padding: EdgeInsets.only(bottom: bottom > 0 ? bottom : 8, top: 4),
      child: Row(
        children: List.generate(_icons.length, (i) {
          final active    = currentTab == i;
          final showBadge = i == 4 && unread > 0;
          final iconData  = active ? _icons[i].active : _icons[i].inactive;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // top indicator spanning full column
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 3,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF7C3AED) : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                  ),
                ),
                const SizedBox(height: 10),
                // icon + badge
                Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: active ? 0.0 : 1.0, end: active ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (_, t, __) => Icon(
                      iconData,
                      size: active ? 28 : 24,
                      color: Color.lerp(context.p.textMuted, const Color(0xFF7C3AED), t),
                    ),
                  ),
                  if (showBadge)
                    Positioned(
                      top: -5, right: -8,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 16),
                        height: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.p.surface, width: 2),
                        ),
                        child: Center(child: Text(unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800))),
                      ),
                    ),
                ]),
                const SizedBox(height: 10),
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

// ── Avatar circle (ảnh hoặc chữ cái đầu) ─────────────────────────────────────
class _AvatarCircle extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double size;
  final double fontSize;
  const _AvatarCircle({required this.photoUrl, required this.initials, required this.size, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!, width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initials(context),
        ),
      );
    }
    return _initials(context);
  }

  Widget _initials(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [context.p.navy, context.p.teal]),
      shape: BoxShape.circle,
    ),
    child: Center(child: Text(initials, style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w800))),
  );
}

// ── Đổi mật khẩu ─────────────────────────────────────────────────────────────
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();
  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _curCtrl  = TextEditingController();
  final _newCtrl  = TextEditingController();
  final _conCtrl  = TextEditingController();
  bool _loading   = false;
  bool _showCur   = false;
  bool _showNew   = false;
  bool _showCon   = false;

  @override
  void dispose() { _curCtrl.dispose(); _newCtrl.dispose(); _conCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final cur = _curCtrl.text.trim();
    final nw  = _newCtrl.text.trim();
    final con = _conCtrl.text.trim();
    if (cur.isEmpty || nw.isEmpty || con.isEmpty) {
      showToast(context, 'Vui lòng điền đầy đủ thông tin', isError: true); return;
    }
    if (nw.length < 6) {
      showToast(context, 'Mật khẩu mới phải có ít nhất 6 ký tự', isError: true); return;
    }
    if (nw != con) {
      showToast(context, 'Mật khẩu xác nhận không khớp', isError: true); return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseService.instance.reauthenticateAndChangePassword(cur, nw);
      if (!mounted) return;
      Navigator.pop(context);
      showToast(context, 'Đã cập nhật mật khẩu');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e.toString().contains('wrong-password') || e.toString().contains('invalid-credential')
          ? 'Mật khẩu hiện tại không đúng'
          : 'Lỗi: $e';
      showToast(context, msg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    eyeBtn(bool show, VoidCallback toggle) => GestureDetector(
      onTap: toggle,
      child: Icon(show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: 16, color: context.p.textMuted),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2))),
          Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Icon(Icons.lock_rounded, size: 20, color: Color(0xFF7C3AED)))),
            const SizedBox(width: 12),
            Text('Thay đổi mật khẩu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.p.textMain)),
          ]),
          const SizedBox(height: 20),
          FieldLabel('Mật khẩu hiện tại'),
          OceanInput(hint: '••••••••', controller: _curCtrl, obscureText: !_showCur,
              suffix: eyeBtn(_showCur, () => setState(() => _showCur = !_showCur))),
          const SizedBox(height: 10),
          FieldLabel('Mật khẩu mới'),
          OceanInput(hint: '••••••••', controller: _newCtrl, obscureText: !_showNew,
              suffix: eyeBtn(_showNew, () => setState(() => _showNew = !_showNew))),
          const SizedBox(height: 10),
          FieldLabel('Xác nhận mật khẩu mới'),
          OceanInput(hint: '••••••••', controller: _conCtrl, obscureText: !_showCon,
              suffix: eyeBtn(_showCon, () => setState(() => _showCon = !_showCon))),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loading ? null : _submit,
            child: Container(
              height: 50, width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _loading
                    ? [const Color(0xFFD8B4FE), const Color(0xFFF9A8D4)]
                    : [const Color(0xFF7C3AED), const Color(0xFFEC4899)]),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Cập nhật', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Đổi avatar ────────────────────────────────────────────────────────────────
class _ChangeAvatarSheet extends StatefulWidget {
  const _ChangeAvatarSheet();
  @override
  State<_ChangeAvatarSheet> createState() => _ChangeAvatarSheetState();
}

class _ChangeAvatarSheetState extends State<_ChangeAvatarSheet> {
  Uint8List? _bytes;
  bool _uploading = false;

  Future<void> _pick() async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 512);
    if (xfile == null || !mounted) return;
    final b = await xfile.readAsBytes();
    setState(() => _bytes = b);
  }

  Future<void> _save() async {
    if (_bytes == null || _uploading) return;
    setState(() => _uploading = true);
    try {
      final url = await FirebaseService.instance.updateUserAvatar(_bytes!);
      if (!mounted) return;
      Navigator.pop(context, url);
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      showToast(context, 'Lỗi: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fbUser   = FirebaseService.instance.currentUser;
    final name     = fbUser?.displayName ?? fbUser?.email?.split('@').first ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final photoUrl = fbUser?.photoURL;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2))),
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.photo_camera_rounded, size: 20, color: Color(0xFF7C3AED)))),
          const SizedBox(width: 12),
          Text('Thay đổi ảnh đại diện', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.p.textMain)),
        ]),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _pick,
          child: Stack(alignment: Alignment.bottomRight, children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.4), width: 2.5)),
              child: ClipOval(child: _bytes != null
                  ? Image.memory(_bytes!, fit: BoxFit.cover)
                  : (photoUrl != null && photoUrl.isNotEmpty)
                      ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                          _InitialsBox(initials: initials))
                      : _InitialsBox(initials: initials)),
            ),
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white)),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Text('Nhấn vào ảnh để chọn từ thư viện',
            style: TextStyle(fontSize: 12, color: context.p.textMuted)),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _bytes == null ? _pick : (_uploading ? null : _save),
          child: Container(
            height: 50, width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _bytes == null
                  ? [const Color(0xFF7C3AED), const Color(0xFF9333EA)]
                  : [const Color(0xFF5B21B6), const Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Center(child: _uploading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_bytes == null ? 'Chọn ảnh từ thư viện' : 'Lưu ảnh đại diện',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
          ),
        ),
      ]),
    );
  }
}

class _InitialsBox extends StatelessWidget {
  final String initials;
  const _InitialsBox({required this.initials});
  @override
  Widget build(BuildContext context) => Container(
    color: context.p.navy,
    child: Center(child: Text(initials,
        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800))),
  );
}
