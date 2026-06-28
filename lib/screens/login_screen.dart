import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../l10n/app_strings.dart';
import '../main.dart' show LangState;
import '../services/firebase_service.dart';
import '../services/auth_errors.dart';
import '../widgets/common_widgets.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

const _kEmail    = 'saved_email';
const _kPassword = 'saved_password';
const _kRemember = 'remember_me';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool  _showPassword = false;
  bool  _loading      = false;
  bool  _rememberMe   = false;
  String _error       = '';

  late final AnimationController _animCtrl;
  late final Animation<double>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_kRemember) ?? false;
    if (!remember) return;
    final email    = prefs.getString(_kEmail) ?? '';
    final password = prefs.getString(_kPassword) ?? '';
    if (email.isEmpty || password.isEmpty) return;

    _emailCtrl.text    = email;
    _passwordCtrl.text = password;
    if (mounted) setState(() => _rememberMe = true);

    // tự động đăng nhập
    await _login(auto: true);
  }

  Future<void> _login({bool auto = false}) async {
    final s        = AppStrings.readFrom(context);
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty)    { setState(() => _error = s.loginErrEmail); return; }
    if (password.isEmpty) { setState(() => _error = s.loginErrPw); return; }

    setState(() { _error = ''; _loading = true; });
    try {
      await FirebaseService.instance.signIn(email, password);
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool(_kRemember, true);
        await prefs.setString(_kEmail, email);
        await prefs.setString(_kPassword, password);
      } else {
        await prefs.remove(_kRemember);
        await prefs.remove(_kEmail);
        await prefs.remove(_kPassword);
      }
      // AuthGate StreamBuilder tự chuyển sang MainShell
    } catch (e) {
      if (!mounted) return;
      // nếu auto-login thất bại, xoá credentials cũ để user tự nhập lại
      if (auto) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_kRemember);
        await prefs.remove(_kEmail);
        await prefs.remove(_kPassword);
        setState(() { _rememberMe = false; _loading = false; });
      } else {
        setState(() { _loading = false; _error = authErrorMessage(e); });
      }
    }
  }

  void _goRegister() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _goForgot() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final s          = AppStrings.of(context);
    final keyboardH  = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: context.p.surface,
      body: Stack(children: [

        // ── gradient background ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFEC4899)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),

        // ── decorative circles ──
        const Positioned(top: -60, right: -60, child: _Circle(220, 0.06)),
        const Positioned(top: 50, right: -30,  child: _Circle(140, 0.04)),
        const Positioned(bottom: 280, left: -50, child: _Circle(160, 0.05)),

        // ── lang switcher (top-right) ──
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 16,
          child: const _WhiteLangSwitcher(),
        ),

        // ── content ──
        SafeArea(
          bottom: false,
          child: Column(children: [
            // branding
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                    ),
                    child: const Center(child: FishLogo(size: 44, color: Colors.white)),
                  ),
                  const SizedBox(height: 18),
                  const Text('iCa',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.8)),
                  const SizedBox(height: 6),
                  Text(s.appSubtitle,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75), fontWeight: FontWeight.w500)),
                ]),
              ),
            ),

            // ── form card (slides up) ──
            AnimatedBuilder(
              animation: _slideAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, 60 * (1 - _slideAnim.value)),
                child: Opacity(opacity: _slideAnim.value, child: child),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 0),
                padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + keyboardH + safeBottom),
                decoration: BoxDecoration(
                  color: context.p.surface,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32),bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  // handle
                  Center(child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2)),
                  )),
                  const SizedBox(height: 22),

                  Text(s.loginTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.p.textMain)),
                  const SizedBox(height: 4),
                  Text(s.loginWelcome,
                      style: TextStyle(fontSize: 13, color: context.p.textMuted, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 22),

                  // email
                  FieldLabel(s.loginEmail),
                  OceanInput(
                    controller: _emailCtrl,
                    hint: s.loginEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    prefix: Icon(Icons.email_outlined, color: context.p.textMuted, size: 18),
                    borderColor: _error.isNotEmpty && _emailCtrl.text.isEmpty
                        ? const Color(0xFFDC2626) : null,
                    onChanged: (_) => setState(() => _error = ''),
                  ),
                  const SizedBox(height: 14),

                  // password
                  FieldLabel(s.loginPassword),
                  OceanInput(
                    controller: _passwordCtrl,
                    hint: '••••••••',
                    obscureText: !_showPassword,
                    prefix: Icon(Icons.lock_outline, color: context.p.textMuted, size: 18),
                    suffix: GestureDetector(
                      onTap: () => setState(() => _showPassword = !_showPassword),
                      child: Icon(_showPassword ? Icons.visibility_off : Icons.visibility,
                          color: context.p.textMuted, size: 20),
                    ),
                    borderColor: _error.isNotEmpty && _passwordCtrl.text.isEmpty
                        ? const Color(0xFFDC2626) : null,
                    onChanged: (_) => setState(() => _error = ''),
                  ),
                  const SizedBox(height: 12),

                  // ── remember me + forgot password ──
                  Row(children: [
                    GestureDetector(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: _rememberMe ? const Color(0xFF9333EA) : context.p.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _rememberMe ? const Color(0xFF9333EA) : context.p.border,
                              width: 2,
                            ),
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check, color: Colors.white, size: 13)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(s.loginRemember,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                color: context.p.text2)),
                      ]),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _goForgot,
                      child: Text(s.loginForgot,
                          style: const TextStyle(color: Color(0xFF9333EA), fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // error
                  if (_error.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text('⚠️ $_error',
                          style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // login button
                  GestureDetector(
                    onTap: _loading ? null : _login,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: _loading ? null : const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                        color: _loading ? context.p.textMuted : null,
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: _loading ? [] : [
                          BoxShadow(color: const Color(0xFF9333EA).withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Center(
                        child: _loading
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                const SizedBox(width: 10),
                                Text(s.loginLoading, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                              ])
                            : Text(s.loginButton, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // register link
                  Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(s.loginRegHint,
                          style: TextStyle(fontSize: 13, color: context.p.text2)),
                      GestureDetector(
                        onTap: _goRegister,
                        child: Text(s.loginRegLink,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF9333EA), fontWeight: FontWeight.w800)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  Center(child: Text(s.loginFooter,
                      style: TextStyle(fontSize: 11, color: context.p.textMuted, fontWeight: FontWeight.w500))),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  @override
  void dispose() { _animCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle(this.size, this.opacity);

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}

class _WhiteLangSwitcher extends StatelessWidget {
  const _WhiteLangSwitcher();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LangState>();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _WLBtn(code: 'vi', flag: '🇻🇳', current: state.langCode),
        _WLBtn(code: 'en', flag: '🇬🇧', current: state.langCode),
      ]),
    );
  }
}

class _WLBtn extends StatelessWidget {
  final String code, flag, current;
  const _WLBtn({required this.code, required this.flag, required this.current});

  @override
  Widget build(BuildContext context) {
    final active = code == current;
    return GestureDetector(
      onTap: () => context.read<LangState>().setLocale(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.30) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(flag, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
