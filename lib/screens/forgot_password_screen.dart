import 'package:flutter/material.dart';
import '../constants.dart';
import '../l10n/app_strings.dart';
import '../services/firebase_service.dart';
import '../services/auth_errors.dart';
import '../widgets/common_widgets.dart';

/// Quên mật khẩu dùng Firebase: gửi email đặt lại mật khẩu.
/// (Firebase tự gửi link reset qua email — không cần tự xử lý OTP.)
class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading    = false;
  bool _sent       = false;
  String _error    = '';

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) { setState(() => _error = 'Vui lòng nhập email'); return; }

    setState(() { _error = ''; _loading = true; });
    try {
      await FirebaseService.instance.sendPasswordReset(email);
      if (!mounted) return;
      setState(() { _loading = false; _sent = true; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = authErrorMessage(e); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFEC4899)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(top: -60, right: -60, child: _circle(200, 0.06)),

        SafeArea(
          child: Column(children: [
            // back
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

            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    ),
                    child: Icon(Icons.lock_reset, color: Colors.white, size: 32),
                  ),
                  SizedBox(height: 14),
                  Text(AppStrings.of(context).forgotTitle,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                ]),
              ),
            ),

            // card
            Container(
              decoration: BoxDecoration(
                color: context.p.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.fromLTRB(24, 22, 24, 32 + bottom),
              child: _sent ? _buildSent() : _buildForm(),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildForm() {
    final s = AppStrings.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
    Center(child: Container(width: 40, height: 4,
      decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2)))),
    SizedBox(height: 20),
    Text(s.forgotTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.p.textMain)),
    SizedBox(height: 4),
    Text(s.forgotSub,
        style: TextStyle(fontSize: 12, color: context.p.textMuted)),
    SizedBox(height: 20),

    FieldLabel(s.loginEmail),
    OceanInput(
      controller: _emailCtrl, hint: s.loginEmailHint,
      keyboardType: TextInputType.emailAddress,
      prefix: Icon(Icons.mail_outline, size: 18, color: context.p.textMuted),
      onChanged: (_) => setState(() => _error = ''),
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
      onTap: _loading ? null : _send,
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
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(s.forgotButton, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ),
      ),
    ),
  ]);
  }

  Widget _buildSent() {
    final s = AppStrings.of(context);
    return Column(mainAxisSize: MainAxisSize.min, children: [
    Center(child: Container(width: 40, height: 4,
      decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2)))),
    SizedBox(height: 22),
    Container(
      width: 64, height: 64,
      decoration: BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
      child: Icon(Icons.mark_email_read_outlined, color: Color(0xFF15803D), size: 32),
    ),
    SizedBox(height: 16),
    Text('${s.forgotSentTitle} 📧', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.p.textMain)),
    SizedBox(height: 8),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '${s.forgotSentSub} ${_emailCtrl.text.trim()}',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: context.p.text2, height: 1.5),
      ),
    ),
    SizedBox(height: 24),
    GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: Color(0xFF9333EA).withOpacity(0.4), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Center(child: Text(s.backToLogin,
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800))),
      ),
    ),
  ]);
  }

  Widget _circle(double s, double o) => Container(
    width: s, height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(o)),
  );

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }
}
