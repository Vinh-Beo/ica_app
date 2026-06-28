import 'package:flutter/material.dart';
import '../constants.dart';

// ── Page Header (with back button) ────────────────────────────────────────────
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? trailing;

  const PageHeader({super.key, required this.title, this.subtitle, required this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      decoration: BoxDecoration(color: context.p.surface, border: Border(bottom: BorderSide(color: context.p.border))),
      child: Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Icon(Icons.chevron_left, color: context.p.textMain, size: 22)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.p.textMain, letterSpacing: -0.3)),
            if (subtitle != null)
              Text(subtitle!, style: TextStyle(fontSize: 11, color: context.p.textMuted)),
          ],
        )),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

// ── Fish Logo (CustomPainter) — đồng bộ với icon app ──────────────────────────
class FishLogo extends StatelessWidget {
  final double size;
  final Color? color;
  const FishLogo({super.key, this.size = 26, this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: CustomPaint(painter: _FishPainter(color: color ?? context.p.teal)),
  );
}

class _FishPainter extends CustomPainter {
  final Color color;
  _FishPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s        = size.width;
    final cx       = s * 0.534, cy = s * 0.515;
    final bodyRx   = s * 0.210, bodyRy = s * 0.151;
    final fillPaint = Paint()..color = color;
    final eyeColor  = Color.lerp(color, Colors.black, 0.4)!;
    final glintColor = Colors.white.withValues(alpha: 0.95);

    // ── Forked tail ──
    final tailAttachTop = Offset(cx - bodyRx * 0.88, cy - bodyRy * 0.55);
    final tailAttachBot = Offset(cx - bodyRx * 0.88, cy + bodyRy * 0.55);
    final tail = Path()
      ..moveTo(tailAttachTop.dx, tailAttachTop.dy)
      ..quadraticBezierTo(cx - bodyRx * 1.6, cy - bodyRy * 1.15, cx - bodyRx * 1.95, cy - bodyRy * 1.35)
      ..quadraticBezierTo(cx - bodyRx * 1.35, cy - bodyRy * 0.25, cx - bodyRx * 1.05, cy)
      ..quadraticBezierTo(cx - bodyRx * 1.35, cy + bodyRy * 0.25, cx - bodyRx * 1.95, cy + bodyRy * 1.35)
      ..quadraticBezierTo(cx - bodyRx * 1.6, cy + bodyRy * 1.15, tailAttachBot.dx, tailAttachBot.dy)
      ..close();
    canvas.drawPath(tail, fillPaint);

    // ── Dorsal fin ──
    final dorsal = Path()
      ..moveTo(cx - bodyRx * 0.55, cy - bodyRy * 0.92)
      ..quadraticBezierTo(cx - bodyRx * 0.50, cy - bodyRy * 1.65, cx - bodyRx * 0.05, cy - bodyRy * 1.85)
      ..quadraticBezierTo(cx + bodyRx * 0.10, cy - bodyRy * 1.55, cx + bodyRx * 0.30, cy - bodyRy * 0.85)
      ..close();
    canvas.drawPath(dorsal, fillPaint);

    // ── Pectoral fin ──
    final pectoral = Path()
      ..moveTo(cx - bodyRx * 0.10, cy + bodyRy * 0.85)
      ..quadraticBezierTo(cx + bodyRx * 0.05, cy + bodyRy * 1.35, cx + bodyRx * 0.35, cy + bodyRy * 1.55)
      ..quadraticBezierTo(cx + bodyRx * 0.55, cy + bodyRy * 1.15, cx + bodyRx * 0.62, cy + bodyRy * 0.70)
      ..close();
    canvas.drawPath(pectoral, fillPaint);

    // ── Body (covers fin bases for a clean join) ──
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: bodyRx * 2, height: bodyRy * 2), fillPaint);

    // ── Smiling mouth ──
    final mouthPaint = Paint()
      ..color = eyeColor ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018 ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(cx + bodyRx * 0.74, cy + bodyRy * 0.08)
      ..quadraticBezierTo(cx + bodyRx * 0.88, cy + bodyRy * 0.42, cx + bodyRx * 0.99, cy + bodyRy * 0.10);
    canvas.drawPath(mouth, mouthPaint);

    // ── Eye: pupil + glint ──
    final eyeCenter = Offset(cx + bodyRx * 0.62, cy - bodyRy * 0.18);
    canvas.drawCircle(eyeCenter, bodyRx * 0.122, Paint()..color = eyeColor);
    canvas.drawCircle(eyeCenter.translate(bodyRx * 0.04, -bodyRy * 0.05), bodyRx * 0.033, Paint()..color = glintColor);
  }

  @override
  bool shouldRepaint(covariant _FishPainter old) => old.color != color;
}

// ── Custom CheckBox ───────────────────────────────────────────────────────────
class OceanCheckBox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  const OceanCheckBox({super.key, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22, height: 22,
      decoration: BoxDecoration(
        gradient: checked ? kGradPP : null,
        color: checked ? null : context.p.surface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: checked ? const Color(0xFF7C3AED) : const Color(0xFFCBD5E1), width: 2),
      ),
      child: checked ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
    ),
  );
}

// ── Price Level Badge ─────────────────────────────────────────────────────────
class PriceLevelBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const PriceLevelBadge({super.key, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
  );
}

// ── Info Stat Box ─────────────────────────────────────────────────────────────
class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const StatBox({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, color: context.p.text2, fontWeight: FontWeight.w600)),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
    ]),
  );
}

// ── Section Card ─────────────────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const SectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.p.surface, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: context.p.textMain.withValues(alpha: 0.05), blurRadius: 4)],
    ),
    child: child,
  );
}

// ── Custom Input Field ────────────────────────────────────────────────────────
class OceanInput extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final Color? borderColor;

  const OceanInput({super.key, required this.hint, this.controller, this.keyboardType, this.obscureText = false, this.prefix, this.suffix, this.onChanged, this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.p.bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor ?? context.p.border, width: 1.5),
    ),
    child: Row(children: [
      if (prefix != null) ...[const SizedBox(width: 12), prefix!],
      Expanded(child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.p.textMain),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: InputBorder.none,
        ),
      )),
      if (suffix != null) ...[suffix!, const SizedBox(width: 8)],
    ]),
  );
}

// ── Gradient Card ─────────────────────────────────────────────────────────────
class GradientCard extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final double borderRadius;

  const GradientCard({super.key, required this.colors, required this.child, this.borderRadius = 16});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: child,
  );
}

// ── SnackBar helper ───────────────────────────────────────────────────────────
void showToast(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      Icon(
        isError ? Icons.warning_rounded : Icons.check_circle_rounded,
        color: Colors.white, size: 16,
      ),
      const SizedBox(width: 8),
      Flexible(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700))),
    ]),
    backgroundColor: isError ? const Color(0xFFDC2626) : context.p.navy,
    duration: const Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    shape: const StadiumBorder(),
    margin: const EdgeInsets.all(16),
  ));
}

// ── Label ─────────────────────────────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text.toUpperCase(),
        style: TextStyle(fontSize: 10, color: context.p.textMuted, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
  );
}
