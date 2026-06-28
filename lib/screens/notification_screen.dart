import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../constants.dart';
import '../l10n/app_strings.dart';
import '../models.dart';
import '../widgets/app_icon.dart';

// ── Loại thông báo → icon + màu ──
class _NType { final IconData ic; final Color color; const _NType(this.ic, this.color); }
const _notifTypes = {
  'debt_new':     _NType(Icons.receipt_long_rounded,     Color(0xFF7C3AED)),
  'debt_paid':    _NType(Icons.check_circle_rounded,     Color(0xFF15803D)),
  'debt_deleted': _NType(Icons.delete_outline_rounded,   Color(0xFFDC2626)),
  'quote':        _NType(Icons.description_rounded,      Color(0xFF0E7C8C)),
  'system':       _NType(Icons.notifications_rounded,    Color(0xFFB45309)),
};

// Thiết bị giả lập (mock) để minh hoạ push
const _devices = [
  {'name': 'iPhone 15 Pro · Minh', 'icon': Icons.phone_iphone_rounded,  'online': true},
  {'name': 'Samsung S24 · Hùng',   'icon': Icons.smartphone_rounded,    'online': true},
  {'name': 'iPad Air · Quản lý',   'icon': Icons.tablet_mac_rounded,    'online': false},
];

// tint thích ứng theme: trộn màu accent lên nền surface
Color _tint(Color c, Color surface, [double a = 0.14]) =>
    Color.alphaBlend(c.withValues(alpha: a), surface);

String _relTime(int ts, AppStrings s) {
  final diff = (DateTime.now().millisecondsSinceEpoch - ts) ~/ 1000;
  if (diff < 60) return s.relJustNow;
  if (diff < 3600) return s.relMinAgo(diff ~/ 60);
  if (diff < 86400) return s.relHourAgo(diff ~/ 3600);
  return s.relDayAgo(diff ~/ 86400);
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s     = AppStrings.of(context);
    final app   = context.watch<AppState>();
    final p     = context.p;
    final items = app.notifications;
    final unread = app.unreadCount;

    return Column(
      children: [
        // ── Header ──
        Container(
          color: p.surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(s.notifTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.textMain)),
                  const SizedBox(width: 8),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(10)),
                      child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  const Spacer(),
                  if (unread > 0)
                    _chipBtn(context, s.markAllRead, p.teal, _tint(p.teal, p.surface),
                        () => context.read<AppState>().markAllRead()),
                  if (items.isNotEmpty) const SizedBox(width: 8),
                  if (items.isNotEmpty)
                    _chipBtn(context, s.clearAll, const Color(0xFFDC2626),
                        _tint(const Color(0xFFDC2626), p.surface, 0.12),
                        () => _confirmClear(context)),
                ],
              ),
              const SizedBox(height: 10),
              // dải trạng thái thiết bị
              SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _devices.map((d) {
                    final on = d['online'] == true;
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: on ? _tint(const Color(0xFF22C55E), p.surface, 0.13) : p.surface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: on ? _tint(const Color(0xFF22C55E), p.border, 0.32) : p.border),
                      ),
                      child: Row(children: [
                        Icon(d['icon'] as IconData, size: 13, color: on ? p.textMain : p.textMuted),
                        const SizedBox(width: 5),
                        Text(d['name'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: on ? p.textMain : p.textMuted)),
                        const SizedBox(width: 5),
                        Container(width: 6, height: 6, decoration: BoxDecoration(
                          color: on ? const Color(0xFF22C55E) : p.textMuted, shape: BoxShape.circle)),
                      ]),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: p.border),

        // ── List ──
        Expanded(
          child: items.isEmpty
              ? _empty(context, s, p)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _card(context, items[i], s, p),
                ),
        ),
      ],
    );
  }

  Widget _chipBtn(BuildContext c, String label, Color fg, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }

  Widget _empty(BuildContext context, AppStrings s, AppPalette p) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AppIcon(icon: Icons.notifications_outlined, color: p.textMuted, bg: p.surface2, size: 64, iconSize: 30),
          const SizedBox(height: 10),
          Text(s.noNotif, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: p.textMain)),
          const SizedBox(height: 4),
          Text(s.noNotifSub, style: TextStyle(fontSize: 12, color: p.textMuted)),
        ]),
      );

  Widget _card(BuildContext context, AppNotification n, AppStrings s, AppPalette p) {
    final nt = _notifTypes[n.type] ?? _notifTypes['system']!;
    return GestureDetector(
      onTap: () => context.read<AppState>().markRead(n.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: n.read ? p.surface : _tint(kPurple, p.surface, 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: n.read ? p.surface2 : _tint(kPurple, p.border, 0.30)),
        ),
        child: Stack(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AppIcon(icon: nt.ic, color: nt.color, bg: _tint(nt.color, p.surface, 0.16), size: 42, iconSize: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(n.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: p.textMain))),
                  const SizedBox(width: 6),
                  Text(_relTime(n.ts, s), style: TextStyle(fontSize: 9, color: p.textMuted, fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 2),
                Text(n.body, style: TextStyle(fontSize: 12, color: p.text2, height: 1.4)),
                // nhãn "Được tạo bởi"
                if (n.by.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.person_outline_rounded, size: 12, color: p.textMuted),
                    const SizedBox(width: 4),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: '${s.createdBy} ', style: TextStyle(fontSize: 10.5, color: p.textMuted, fontWeight: FontWeight.w600)),
                      TextSpan(text: n.by, style: TextStyle(fontSize: 10.5, color: p.text2, fontWeight: FontWeight.w800)),
                    ])),
                  ]),
                ],
                // badge đã gửi push
                if (n.deviceCount > 0) ...[
                  const SizedBox(height: 6),
                  Wrap(spacing: 5, runSpacing: 5, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: _tint(p.teal, p.surface), borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.cell_tower_rounded, size: 10, color: p.teal),
                        const SizedBox(width: 4),
                        Text('${s.sentNotifDevices} ${n.deviceCount} ${s.devices}',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: p.teal)),
                      ]),
                    ),
                  ]),
                ],
              ]),
            ),
          ]),
          if (!n.read)
            Positioned(top: 0, right: 0, child: Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: kPurple, shape: BoxShape.circle))),
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: () => context.read<AppState>().deleteNotification(n.id),
              child: Container(width: 22, height: 22,
                  decoration: BoxDecoration(color: _tint(const Color(0xFFDC2626), p.surface, 0.12), borderRadius: BorderRadius.circular(7)),
                  child: const Center(child: Icon(Icons.delete_outline_rounded, size: 13, color: Color(0xFFDC2626)))),
            ),
          ),
        ]),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    final s = AppStrings.readFrom(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.clearAllQ),
        content: Text(s.cannotUndo),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          TextButton(
            onPressed: () { context.read<AppState>().clearNotifications(); Navigator.pop(ctx); },
            child: Text(s.delete, style: const TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }
}
