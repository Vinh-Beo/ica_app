import 'package:flutter/material.dart';
import '../constants.dart';
import '../l10n/app_strings.dart';
import '../services/firebase_service.dart';
import '../services/auth_errors.dart';
import '../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _pwCtrl       = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool  _showPw       = false;
  bool  _agree        = false;
  bool  _loading      = false;
  String _error       = '';

  Future<void> _register() async {
    final name    = _nameCtrl.text.trim();
    final email   = _emailCtrl.text.trim();
    final pw      = _pwCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty)        { setState(() => _error = 'Vui lòng nhập họ tên'); return; }
    if (email.isEmpty)       { setState(() => _error = 'Vui lòng nhập email'); return; }
    if (pw.isEmpty)          { setState(() => _error = 'Vui lòng nhập mật khẩu'); return; }
    if (pw.length < 6)       { setState(() => _error = 'Mật khẩu tối thiểu 6 ký tự'); return; }
    if (pw != confirm)       { setState(() => _error = 'Mật khẩu không khớp'); return; }
    if (!_agree)             { setState(() => _error = 'Vui lòng đồng ý điều khoản'); return; }

    setState(() { _error = ''; _loading = true; });
    try {
      // Tạo tài khoản trên Firebase Auth + profile trên Firestore
      await FirebaseService.instance.signUp(
        name: name, email: email, password: pw, phone: _phoneCtrl.text.trim(),
      );
      // AuthGate tự chuyển vào app. Đóng màn đăng ký.
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = authErrorMessage(e); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s      = AppStrings.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        // gradient bg
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFEC4899)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(top: -60, right: -60, child: _circle(200, 0.06)),
        Positioned(bottom: 340, left: -50, child: _circle(150, 0.05)),

        SafeArea(
          child: Column(children: [
            // header with back
            Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Icon(Icons.chevron_left, color: Colors.white, size: 22),
                  ),
                ),
              ]),
            ),

            // branding compact
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    ),
                    child: Center(child: WaveLogo(size: 32, color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                  Text('iCa',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.6)),
                ]),
              ),
            ),

            // form card (scrollable)
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.72),
              decoration: BoxDecoration(
                color: context.p.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2)))),
                  SizedBox(height: 18),
                  Text(s.regTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.p.textMain)),
                  SizedBox(height: 4),
                  Text(s.regWelcome,
                      style: TextStyle(fontSize: 12, color: context.p.textMuted)),
                  SizedBox(height: 18),

                  FieldLabel(s.regName),
                  OceanInput(controller: _nameCtrl, hint: s.regNameHint,
                      prefix: Icon(Icons.person_outline, size: 18, color: context.p.textMuted),
                      onChanged: (_) => setState(() => _error = '')),
                  SizedBox(height: 12),

                  FieldLabel(s.loginEmail),
                  OceanInput(controller: _emailCtrl, hint: s.loginEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      prefix: Icon(Icons.mail_outline, size: 18, color: context.p.textMuted),
                      onChanged: (_) => setState(() => _error = '')),
                  SizedBox(height: 12),

                  FieldLabel(s.regPhone),
                  OceanInput(controller: _phoneCtrl, hint: s.regPhoneHint,
                      keyboardType: TextInputType.phone,
                      prefix: Icon(Icons.phone_outlined, size: 18, color: context.p.textMuted)),
                  SizedBox(height: 12),

                  FieldLabel(s.loginPassword),
                  OceanInput(controller: _pwCtrl, hint: '••••••••', obscureText: !_showPw,
                      prefix: Icon(Icons.lock_outline, size: 18, color: context.p.textMuted),
                      suffix: GestureDetector(
                        onTap: () => setState(() => _showPw = !_showPw),
                        child: Icon(_showPw ? Icons.visibility_off : Icons.visibility, size: 20, color: context.p.textMuted),
                      ),
                      onChanged: (_) => setState(() => _error = '')),
                  SizedBox(height: 12),

                  FieldLabel(s.loginPassword),
                  OceanInput(controller: _confirmCtrl, hint: '••••••••', obscureText: !_showPw,
                      prefix: Icon(Icons.lock_outline, size: 18, color: context.p.textMuted),
                      onChanged: (_) => setState(() => _error = '')),
                  SizedBox(height: 14),

                  // terms checkbox
                  GestureDetector(
                    onTap: () => setState(() { _agree = !_agree; _error = ''; }),
                    child: Row(children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: _agree ? Color(0xFF9333EA) : Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: _agree ? Color(0xFF9333EA) : context.p.textMuted, width: 2),
                        ),
                        child: _agree ? Icon(Icons.check, color: Colors.white, size: 14) : null,
                      ),
                      SizedBox(width: 9),
                      Expanded(child: Text.rich(TextSpan(children: [
                        TextSpan(text: 'Tôi đồng ý với ', style: TextStyle(fontSize: 12, color: context.p.text2)),
                        TextSpan(text: 'Điều khoản & Chính sách', style: TextStyle(fontSize: 12, color: Color(0xFF9333EA), fontWeight: FontWeight.w700)),
                      ]))),
                    ]),
                  ),
                  SizedBox(height: 16),

                  if (_error.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(color: Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                      child: Text('⚠️ $_error', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: 12),
                  ],

                  GestureDetector(
                    onTap: _loading ? null : _register,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: _loading ? null : LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                        color: _loading ? context.p.textMuted : null,
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: _loading ? [] : [BoxShadow(color: Color(0xFF9333EA).withOpacity(0.4), blurRadius: 18, offset: Offset(0, 8))],
                      ),
                      child: Center(
                        child: _loading
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                SizedBox(width: 10),
                                Text(s.regLoading, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                              ])
                            : Text(s.regButton, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(s.regHaveAcct, style: TextStyle(fontSize: 13, color: context.p.text2)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Text(s.regSignIn, style: TextStyle(fontSize: 13, color: Color(0xFF9333EA), fontWeight: FontWeight.w800)),
                    ),
                  ])),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _circle(double s, double o) => Container(
    width: s, height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(o)),
  );

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _pwCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }
}
