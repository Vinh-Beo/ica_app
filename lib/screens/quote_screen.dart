import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../constants.dart';
import '../l10n/app_strings.dart';
import '../models.dart';
import '../services/firebase_service.dart';
import '../widgets/app_icon.dart';
import '../widgets/common_widgets.dart';

// ── Root screen with sub-page navigation ──────────────────────────────────────
class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});
  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String? _sub; // null | 'giaGoc' | 'lichSu'

  @override
  Widget build(BuildContext context) {
    if (_sub == 'giaGoc') return _GiaGocPage(onBack: () => setState(() => _sub = null));
    if (_sub == 'lichSu') return _LichSuPage(onBack: () => setState(() => _sub = null));
    return _BaoGiaMain(
      onGotoGiaGoc: () => setState(() => _sub = 'giaGoc'),
      onGotoLichSu: () => setState(() => _sub = 'lichSu'),
    );
  }
}

// ── Main quote page ───────────────────────────────────────────────────────────
class _BaoGiaMain extends StatelessWidget {
  final VoidCallback onGotoGiaGoc;
  final VoidCallback onGotoLichSu;
  const _BaoGiaMain({required this.onGotoGiaGoc, required this.onGotoLichSu});

  @override
  Widget build(BuildContext context) {
    final s     = AppStrings.of(context);
    final state = context.watch<AppState>();
    return Column(children: [
      // ── Fixed header — nằm ngoài ListView để SingleChildScrollView không bị nested ──
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(children: [
          // Shortcut buttons
          Row(children: [
            Expanded(child: _ShortcutCard(
              icon: Icons.price_change_rounded, title: s.scBase,
              subtitle: '${state.seafood.length} ${s.itemsLabel}',
              color: context.p.teal, bg: const Color(0xFFE0F7FA), onTap: onGotoGiaGoc,
            )),
            const SizedBox(width: 10),
            Expanded(child: _ShortcutCard(
              icon: Icons.history_rounded, title: s.scHistory,
              subtitle: '${state.quotes.length} ${s.histSaved}',
              color: const Color(0xFF7C3AED), bg: const Color(0xFFEDE9FE), onTap: onGotoLichSu,
            )),
          ]),
          const SizedBox(height: 14),

          // Period + customer (header card)
          SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.quotePeriod, style: TextStyle(fontSize: 10, color: context.p.textMuted, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _DropdownBox(
                value: kMonths[state.quoteMonth],
                items: kMonths,
                onChanged: (v) => state.setQuoteMonth(kMonths.indexOf(v!)),
              )),
              const SizedBox(width: 8),
              SizedBox(width: 90, child: _DropdownBox(
                value: '${state.quoteYear}',
                items: const ['2024','2025','2026','2027'],
                onChanged: (v) => state.setQuoteYear(int.parse(v!)),
              )),
            ]),
            const SizedBox(height: 14),
            Text(s.quoteCustomer, style: TextStyle(fontSize: 10, color: context.p.textMuted, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            // ── Horizontal scroll không nằm trong ListView → không bị intercept ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: state.customers.map((c) {
                  final active = state.selectedCustomerId == c.id;
                  return GestureDetector(
                    onTap: () => state.setSelectedCustomer(c.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFFE0F7FA) : context.p.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? context.p.teal : context.p.border, width: 1.5),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(kTypeIcon[c.type]?.icon ?? Icons.storefront_rounded,
                            color: active ? context.p.teal : (kTypeIcon[c.type]?.color ?? context.p.text2),
                            size: 13),
                        const SizedBox(width: 6),
                        Text(c.name.length > 10 ? c.name.split(' ').last : c.name,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: active ? context.p.teal : const Color(0xFF475569))),
                        const SizedBox(width: 4),
                        Text('×${c.coefficient.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 10, color: active ? context.p.teal : context.p.textMuted, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ])),
          const SizedBox(height: 14),
        ]),
      ),

      // ── Scrollable content ──
      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [

        // ── Seafood items ──
        if (state.pricedSeafood.isEmpty)
          SectionCard(child: Column(children: [
            const SizedBox(height: 16),
            AppIcon(icon: Icons.price_change_rounded, color: context.p.teal, size: 52, iconSize: 26),
            const SizedBox(height: 8),
            Text(s.noBaseGo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            Text(s.goBase, style: TextStyle(color: context.p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
          ]))
        else ...[
          // Select all
          GestureDetector(
            onTap: state.toggleAll,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: Row(children: [
                OceanCheckBox(checked: state.pricedSeafood.every((sf) => state.isSelected(sf.id)), onTap: state.toggleAll),
                const SizedBox(width: 8),
                Text('${s.selectAll} · ${state.quoteItems.length}/${state.pricedSeafood.length} ${s.itemsLabel}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.p.text2)),
              ]),
            ),
          ),
          ..._buildGroupedItems(context, state),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              if (state.quoteItems.isEmpty) { showToast(context, s.noBaseGo, isError: true); return; }
              state.saveQuote();
              showToast(context, '${s.saveQuote} ${kMonths[state.quoteMonth]}/${state.quoteYear}');
            },
            child: AnimatedOpacity(
              opacity: state.quoteItems.isEmpty ? 0.4 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: kGradPP, borderRadius: BorderRadius.circular(26),
                  boxShadow: [BoxShadow(color: kPurple.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 7))],
                ),
                child: Center(child: Text('${s.saveQuote} — ${state.quoteItems.length} ${s.itemsLabel}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))),
              ),
            ),
          ),
        ],
      ],
      )),
    ]);
  }

  List<Widget> _buildGroupedItems(BuildContext context, AppState state) {
    final grouped = <String, List<Seafood>>{};
    for (final sf in state.pricedSeafood) {
      (grouped[sf.category] ??= []).add(sf);
    }
    return grouped.entries.map((entry) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Row(children: [
            Text(kCatIcons[entry.key] ?? '', style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: context.p.navy, letterSpacing: 0.5)),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: context.p.border)),
          ]),
        ),
        ...entry.value.map((sf) => _QuoteItemRow(sf: sf)),
      ],
    )).toList();
  }
}

class _QuoteItemRow extends StatefulWidget {
  final Seafood sf;
  const _QuoteItemRow({required this.sf});
  @override
  State<_QuoteItemRow> createState() => _QuoteItemRowState();
}

class _QuoteItemRowState extends State<_QuoteItemRow> {
  late TextEditingController _ctrl;

  String _fmt(double n) {
    final s = n.round().toString();
    final buf = StringBuffer();
    final len = s.length;
    for (int i = 0; i < len; i++) { if (i > 0 && (len - i) % 3 == 0) buf.write('.'); buf.write(s[i]); }
    return buf.toString();
  }

  @override
  void initState() { super.initState(); _ctrl = TextEditingController(); }

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppState>();
    final base    = widget.sf.basePrice;
    final sell    = state.getSellPrice(widget.sf.id, base);
    final ov      = state.isOverridden(widget.sf.id);
    final auto    = base * state.selectedCustomer.coefficient;
    final lv      = getPriceLevel(base > 0 ? sell / base : 1.0);
    final checked = state.isSelected(widget.sf.id);
    if (!ov) _ctrl.text = _fmt(auto);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: checked ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: context.p.textMain.withOpacity(0.04), blurRadius: 4)]),
        child: Column(children: [
          Row(children: [
            OceanCheckBox(checked: checked, onTap: () => state.toggleItem(widget.sf.id)),
            const SizedBox(width: 9),
            Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFEEF6F7), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(widget.sf.icon, style: const TextStyle(fontSize: 18)))),
            const SizedBox(width: 9),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.sf.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.p.textMain)),
              Text('Gốc: ${_fmt(base)}đ/${widget.sf.unit}', style: TextStyle(fontSize: 11, color: context.p.textMuted)),
            ])),
            PriceLevelBadge(label: lv.label, color: lv.color, bg: lv.bg),
          ]),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Row(children: [
              if (ov) ...[
                GestureDetector(
                  onTap: () { state.resetSellOverride(widget.sf.id); _ctrl.text = _fmt(auto); },
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFFB45309))),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: const Color(0xFFE0F7FA),
                    border: Border.all(color: ov ? const Color(0xFFFBBF24) : const Color(0xFFA5F3FC), width: 1.5),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                      color: ov ? const Color(0xFFB45309) : lv.color),
                  decoration: const InputDecoration(contentPadding: EdgeInsets.zero, isDense: true, border: InputBorder.none),
                  onChanged: (v) => state.setSellOverride(widget.sf.id, v.replaceAll('.', '')),
                ),
              )),
              const SizedBox(width: 10),
              Text(sell >= base ? '+${fmt(sell - base)}' : '-${fmt(base - sell)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: sell >= base ? const Color(0xFF15803D) : const Color(0xFFDC2626))),
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

// ── Giá gốc sub-page ──────────────────────────────────────────────────────────
class _GiaGocPage extends StatefulWidget {
  final VoidCallback onBack;
  const _GiaGocPage({required this.onBack});
  @override
  State<_GiaGocPage> createState() => _GiaGocPageState();
}

class _GiaGocPageState extends State<_GiaGocPage> {
  bool _showAdd    = false;
  bool _addLoading = false;
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _cat  = 'Tôm';
  String _unit = 'kg';

  @override
  Widget build(BuildContext context) {
    final s     = AppStrings.of(context);
    final state = context.watch<AppState>();
    return Column(children: [
      PageHeader(
        title: s.baseTitle,
        subtitle: '${state.seafood.length} ${s.items} · ${state.pricedSeafood.length} ${s.priced}',
        onBack: widget.onBack,
      ),
      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16,14,16,24), children: [
        // summary banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [context.p.navy, context.p.teal], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(children: [
            const Positioned(right: -8, top: -12, child: Opacity(opacity: 0.08, child: Icon(Icons.monetization_on_rounded, size: 90, color: Colors.white))),
            Row(children: [
              _SumItem('Tổng', '${state.seafood.length}'),
              const SizedBox(width: 24),
              _SumItem('Có giá', '${state.pricedSeafood.length}'),
              const SizedBox(width: 24),
              _SumItem('Thiếu', '${state.seafood.length - state.pricedSeafood.length}'),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        ...state.seafood.map((sf) => _SeafoodPriceRow(key: ValueKey(sf.id), sf: sf)),
        const SizedBox(height: 6),
        if (_showAdd) _buildAddForm(state)
        else GestureDetector(
          onTap: () => setState(() => _showAdd = true),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.p.teal, width: 1.5, style: BorderStyle.solid)),
            child: Center(child: Text(s.addSeafood, style: TextStyle(color: context.p.teal, fontSize: 13, fontWeight: FontWeight.w700))),
          ),
        ),
      ])),
    ]);
  }

  Widget _buildAddForm(AppState state) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.p.teal, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('✦ HẢI SẢN MỚI', style: TextStyle(fontSize: 10, color: context.p.teal, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        OceanInput(controller: _nameCtrl, hint: s.seafoodName),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _CatDropdown(value: _cat, onChanged: (v) => setState(() => _cat = v!))),
          const SizedBox(width: 8),
          Expanded(child: _UnitDropdown(value: _unit, onChanged: (v) => setState(() => _unit = v!))),
        ]),
        const SizedBox(height: 8),
        OceanInput(controller: _priceCtrl, hint: s.basePrice, keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: _addLoading ? null : () async {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty) { showToast(context, s.seafoodName, isError: true); return; }
              final price = double.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              setState(() => _addLoading = true);
              try {
                await state.addSeafood(Seafood(id: uid(), name: name, category: _cat, unit: _unit, icon: kCatIcons[_cat] ?? '🐡', basePrice: price));
                if (!mounted) return;
                _nameCtrl.clear(); _priceCtrl.clear();
                setState(() { _showAdd = false; _addLoading = false; });
                showToast(context, '${s.addSfToast} "$name"');
              } catch (e) {
                if (mounted) {
                  setState(() => _addLoading = false);
                  showToast(context, 'Lỗi: $e', isError: true);
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 40,
              decoration: BoxDecoration(
                color: _addLoading ? context.p.textMuted : context.p.teal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: _addLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(s.add, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
            ),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _showAdd = false),
            child: Container(width: 40, height: 40, decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text('✕', style: TextStyle(color: context.p.text2, fontSize: 15)))),
          ),
        ]),
      ]),
    );
  }

  @override
  void dispose() { _nameCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }
}

class _SeafoodPriceRow extends StatefulWidget {
  final Seafood sf;
  const _SeafoodPriceRow({super.key, required this.sf});
  @override
  State<_SeafoodPriceRow> createState() => _SeafoodPriceRowState();
}

class _SeafoodPriceRowState extends State<_SeafoodPriceRow> {
  late TextEditingController _ctrl;
  late FocusNode             _focusNode;
  Timer?  _debounce;
  bool    _saved      = false;
  bool    _saving     = false;
  bool    _confirmDel = false;

  @override
  void initState() {
    super.initState();
    _ctrl      = TextEditingController(text: widget.sf.basePrice > 0 ? fmt(widget.sf.basePrice) : '');
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  // Khi người dùng rời khỏi ô giá (tap sang chỗ khác / bấm back)
  void _onFocusChange() {
    if (!_focusNode.hasFocus && _debounce?.isActive == true) {
      _debounce!.cancel();
      _savePrice(_ctrl.text);
    }
  }

  void _onPriceChange(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () => _savePrice(v));
  }

  Future<void> _savePrice(String v) async {
    final p = double.tryParse(v.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    if (!mounted) return;
    setState(() { _saving = true; _saved = false; });
    try {
      await context.read<AppState>().updateBasePrice(widget.sf.id, p);
      if (!mounted) return;
      setState(() { _saving = false; _saved = true; });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _saved = false);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showToast(context, 'Lỗi lưu giá: $e', isError: true);
      }
    }
  }

  void _openEdit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SeafoodEditSheet(sf: widget.sf),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state      = context.read<AppState>();
    final hasPriced  = widget.sf.basePrice > 0;
    final borderColor = _saved  ? const Color(0xFF15803D)
                      : _saving ? const Color(0xFFF59E0B)
                      : hasPriced ? context.p.teal
                      : context.p.border;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: context.p.surface, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: context.p.textMain.withValues(alpha: 0.04), blurRadius: 4)],
      ),
      child: Row(children: [
        // ── icon + name → tap để chỉnh sửa ──
        GestureDetector(
          onTap: _openEdit,
          child: Container(width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFEEF6F7), borderRadius: BorderRadius.circular(11)),
            child: Center(child: Text(widget.sf.icon, style: const TextStyle(fontSize: 20))),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: _openEdit,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(widget.sf.name,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.p.textMain))),
                Icon(Icons.edit_outlined, size: 13, color: context.p.textMuted),
              ]),
              Text('${widget.sf.category} · ${widget.sf.unit}',
                  style: TextStyle(fontSize: 11, color: context.p.textMuted)),
            ]),
          ),
        ),
        const SizedBox(width: 6),
        // ── phải: giá + xoá (hoặc confirm xoá) ──
        if (_confirmDel) ...[
          GestureDetector(
            onTap: () => state.deleteSeafood(widget.sf.id),
            child: Container(
              height: 32, padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(9)),
              child: const Center(child: Text('Xoá', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _confirmDel = false),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(9)),
              child: Center(child: Text('✕', style: TextStyle(color: context.p.text2, fontSize: 13))),
            ),
          ),
        ] else ...[
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: (_saved || _saving) ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _saving
                  ? const SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFF59E0B)))
                  : const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF15803D)),
            ),
          ),
          SizedBox(width: 100, child: TextField(
            controller:  _ctrl,
            focusNode:   _focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                color: hasPriced ? context.p.teal : context.p.textMain),
            decoration: InputDecoration(
              hintText: '0',
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              filled: true, fillColor: context.p.bg,
              border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.p.teal, width: 1.5)),
            ),
            onChanged:   _onPriceChange,
            onSubmitted: (v) { _debounce?.cancel(); _savePrice(v); },
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _confirmDel = true),
            child: Container(width: 32, height: 32,
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(9)),
              child: const Center(child: Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626))),
            ),
          ),
        ],
      ]),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    // Nếu debounce còn pending (user back trước 700ms), lưu ngay vào Firestore
    if (_debounce?.isActive == true) {
      _debounce!.cancel();
      final p = double.tryParse(_ctrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
      FirebaseService.instance.updateBasePrice(widget.sf.id, p).catchError((_) {});
    }
    _ctrl.dispose();
    super.dispose();
  }
}

// ── Lịch sử sub-page ─────────────────────────────────────────────────────────
class _LichSuPage extends StatefulWidget {
  final VoidCallback onBack;
  const _LichSuPage({required this.onBack});
  @override
  State<_LichSuPage> createState() => _LichSuPageState();
}

class _LichSuPageState extends State<_LichSuPage> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _fMonth = 'all';
  String _fYear  = 'all';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s     = AppStrings.of(context);
    final state = context.watch<AppState>();
    final years = ({...state.quotes.map((q) => q.year.toString())}.toList()..sort((a, b) => b.compareTo(a)));
    final filtered = state.quotes.where((q) {
      final okM = _fMonth == 'all' || q.month == int.parse(_fMonth);
      final okY = _fYear == 'all' || q.year.toString() == _fYear;
      final okS = _search.trim().isEmpty || q.customerName.toLowerCase().contains(_search.trim().toLowerCase());
      return okM && okY && okS;
    }).toList();
    final hasFilter = _search.trim().isNotEmpty || _fMonth != 'all' || _fYear != 'all';

    return Column(children: [
      PageHeader(title: s.histTitle, subtitle: '${state.quotes.length} ${s.histSaved}', onBack: widget.onBack),
      if (state.quotes.isNotEmpty)
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: BoxDecoration(color: context.p.surface, border: Border(bottom: BorderSide(color: context.p.border))),
          child: Column(children: [
            Container(
              decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.p.border, width: 1.5)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Icon(Icons.search, size: 18, color: context.p.textMuted),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain),
                  decoration: InputDecoration(isDense: true, border: InputBorder.none, hintText: s.searchCustomer, hintStyle: TextStyle(color: context.p.textMuted, fontSize: 13)),
                )),
                if (_search.isNotEmpty) GestureDetector(onTap: () => setState(() { _search = ''; _searchCtrl.clear(); }), child: Icon(Icons.close, size: 16, color: context.p.textMuted)),
              ]),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _HistFilterDD(value: _fMonth,
                items: [DropdownMenuItem(value: 'all', child: Text(s.allMonths, style: TextStyle(fontSize: 13, color: context.p.textMain))), ...List.generate(12, (i) => DropdownMenuItem(value: '$i', child: Text(kMonths[i], style: TextStyle(fontSize: 13, color: context.p.textMain))))]
                  ,
                onChanged: (v) => setState(() => _fMonth = v ?? 'all'))),
              const SizedBox(width: 8),
              SizedBox(width: 110, child: _HistFilterDD(value: _fYear,
                items: [DropdownMenuItem(value: 'all', child: Text(s.allYears, style: TextStyle(fontSize: 13, color: context.p.textMain))), ...years.map((y) => DropdownMenuItem(value: y, child: Text(y, style: TextStyle(fontSize: 13, color: context.p.textMain))))]
                  ,
                onChanged: (v) => setState(() => _fYear = v ?? 'all'))),
            ]),
            if (hasFilter) Padding(padding: const EdgeInsets.only(top: 8), child: Align(alignment: Alignment.centerLeft,
              child: Text('Hiển thị ${filtered.length} kết quả', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.p.text2)))),
          ]),
        ),
      Expanded(child: state.quotes.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [AppIcon(icon: Icons.waves_rounded, color: context.p.teal, size: 64, iconSize: 30), const SizedBox(height: 12), Text(s.noQuotes, style: TextStyle(color: context.p.textMuted, fontWeight: FontWeight.w700, fontSize: 16))]))
          : filtered.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [AppIcon(icon: Icons.search_off_rounded, color: context.p.textMuted, size: 60, iconSize: 28), const SizedBox(height: 12), Text(s.noTxFound, style: TextStyle(color: context.p.textMuted, fontWeight: FontWeight.w700, fontSize: 15))]))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _QuoteHistoryCard(quote: filtered[i]),
                )),
    ]);
  }
}

class _HistFilterDD extends StatelessWidget {
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  const _HistFilterDD({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(11), border: Border.all(color: context.p.border, width: 1.5)),
    child: DropdownButton<String>(
      value: value, isExpanded: true, underline: const SizedBox(), isDense: true,
      dropdownColor: context.p.surface,
      style: TextStyle(fontSize: 13, color: context.p.textMain),
      items: items, onChanged: onChanged,
    ),
  );
}

class _QuoteHistoryCard extends StatefulWidget {
  final Quote quote;
  const _QuoteHistoryCard({required this.quote});
  @override
  State<_QuoteHistoryCard> createState() => _QuoteHistoryCardState();
}

class _QuoteHistoryCardState extends State<_QuoteHistoryCard> {
  bool _confirmDel    = false;
  bool _exporting     = false;
  bool _exportingExcel = false;

  Future<void> _exportWord() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    final q = widget.quote;
    try {
      String fmtN(double v) {
        final s   = v.round().toString();
        final buf = StringBuffer();
        for (int i = 0; i < s.length; i++) {
          if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
          buf.write(s[i]);
        }
        return buf.toString();
      }

      final rows = StringBuffer();
      for (int i = 0; i < q.items.length; i++) {
        final it   = q.items[i];
        final diff = it.sellPrice - it.basePrice;
        final diffStr = '${diff >= 0 ? "+" : ""}${fmtN(diff)}';
        final diffColor = diff >= 0 ? '#15803d' : '#dc2626';
        rows.write('''
        <tr>
          <td style="text-align:center">${i + 1}</td>
          <td>${it.icon} ${it.name}</td>
          <td style="text-align:center">${it.unit}</td>
          <td style="text-align:right">${fmtN(it.basePrice)}</td>
          <td style="text-align:right;font-weight:bold">${fmtN(it.sellPrice)}</td>
          <td style="text-align:right;color:$diffColor;font-weight:bold">$diffStr</td>
        </tr>''');
      }

      final profitColor = q.profit >= 0 ? '#15803d' : '#dc2626';
      final profitStr   = '${q.profit >= 0 ? "+" : ""}${fmtN(q.profit)}';
      final today       = DateTime.now();
      final todayFmt    = '${today.day.toString().padLeft(2,'0')}/${today.month.toString().padLeft(2,'0')}/${today.year}';

      final html = '''<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<style>
  body{font-family:"Times New Roman",serif;margin:40px 50px;color:#1a1a2e}
  h1{text-align:center;font-size:20px;text-transform:uppercase;letter-spacing:1px;margin-bottom:4px}
  .sub{text-align:center;font-size:14px;color:#555;margin-bottom:20px}
  .info-table{width:100%;margin-bottom:20px;border-collapse:collapse}
  .info-table td{padding:4px 8px;font-size:13px}
  .info-table td:first-child{font-weight:bold;width:160px;color:#444}
  table.data{width:100%;border-collapse:collapse;font-size:13px}
  table.data th{background:#0e7c8c;color:#fff;padding:9px 10px;text-align:center}
  table.data td{padding:7px 10px;border:1px solid #ddd}
  table.data tr:nth-child(even) td{background:#f5fffe}
  .sum-row td{border-top:2px solid #0e7c8c;font-weight:bold;background:#e0f7fa}
  .footer{margin-top:40px;display:flex;justify-content:space-between}
  .sig{text-align:center;width:200px}
  .sig p{font-weight:bold;margin-bottom:60px}
</style>
</head><body>
<h1>Bảng báo giá hải sản</h1>
<p class="sub">${kMonths[q.month]} / ${q.year}</p>
<table class="info-table">
  <tr><td>Khách hàng</td><td>${q.customerName}</td></tr>
  <tr><td>Loại khách hàng</td><td>${q.customerType}</td></tr>
  <tr><td>Hệ số</td><td>${q.coefficient.toStringAsFixed(2)}</td></tr>
  <tr><td>Ngày lập</td><td>$todayFmt</td></tr>
</table>
<table class="data">
  <tr>
    <th style="width:40px">STT</th>
    <th>Mặt hàng</th>
    <th style="width:55px">ĐVT</th>
    <th style="width:110px">Giá gốc (đ)</th>
    <th style="width:110px">Giá bán (đ)</th>
    <th style="width:110px">Chênh lệch</th>
  </tr>
  $rows
  <tr class="sum-row">
    <td colspan="3" style="text-align:right">TỔNG CỘNG</td>
    <td style="text-align:right">${fmtN(q.totalBase)}</td>
    <td style="text-align:right">${fmtN(q.totalSell)}</td>
    <td style="text-align:right;color:$profitColor">$profitStr</td>
  </tr>
</table>
<div class="footer">
  <div class="sig"><p>Khách hàng</p><p>........................</p></div>
  <div class="sig"><p>Người lập báo giá</p><p>........................</p></div>
</div>
</body></html>''';

      final dir      = await getTemporaryDirectory();
      final safeName = q.customerName.replaceAll(RegExp(r'[^\w ]'), '').trim().replaceAll(' ', '_');
      final fileName = 'BaoGia_${safeName}_T${q.month + 1}_${q.year}.doc';
      final file     = File('${dir.path}/$fileName');
      // UTF-8 BOM → Word/Google Docs nhận đúng tiếng Việt
      await file.writeAsBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(html)]);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/msword', name: fileName)],
        subject: 'Báo giá ${q.customerName} — ${kMonths[q.month]}/${q.year}',
      );
    } catch (e) {
      if (mounted) showToast(context, 'Lỗi xuất file: $e', isError: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportExcel() async {
    if (_exportingExcel) return;
    setState(() => _exportingExcel = true);
    final q = widget.quote;
    try {
      String fmtN(double v) {
        final s   = v.round().toString();
        final buf = StringBuffer();
        for (int i = 0; i < s.length; i++) {
          if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
          buf.write(s[i]);
        }
        return buf.toString();
      }

      final rows = StringBuffer();
      for (int i = 0; i < q.items.length; i++) {
        final it   = q.items[i];
        final diff = it.sellPrice - it.basePrice;
        rows.write('<tr>'
            '<td>${i + 1}</td>'
            '<td>${it.icon} ${it.name}</td>'
            '<td>${it.unit}</td>'
            '<td>${fmtN(it.basePrice)}</td>'
            '<td>${fmtN(it.sellPrice)}</td>'
            '<td>${diff >= 0 ? "+" : ""}${fmtN(diff)}</td>'
            '</tr>');
      }

      final today    = DateTime.now();
      final todayFmt = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';

      final html = '''<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel"
xmlns="http://www.w3.org/TR/REC-html40">
<head><meta charset="UTF-8">
<!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets>
<x:ExcelWorksheet><x:Name>Bao gia</x:Name>
<x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions>
</x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->
<style>
  td { font-family: Arial, sans-serif; font-size: 11pt; }
  .h { background:#0e7c8c; color:#fff; font-weight:bold; text-align:center; }
  .sum { background:#e0f7fa; font-weight:bold; }
  .label { font-weight:bold; color:#444; }
</style>
</head><body>
<table border="1" cellspacing="0" cellpadding="6">
  <tr><td colspan="6" style="font-weight:bold;font-size:16pt;text-align:center">BẢNG BÁO GIÁ HẢI SẢN</td></tr>
  <tr><td colspan="6" style="text-align:center">${kMonths[q.month]} / ${q.year}</td></tr>
  <tr><td colspan="6"></td></tr>
  <tr><td class="label">Khách hàng</td><td colspan="5">${q.customerName}</td></tr>
  <tr><td class="label">Loại khách hàng</td><td colspan="5">${q.customerType}</td></tr>
  <tr><td class="label">Hệ số</td><td colspan="5">${q.coefficient.toStringAsFixed(2)}</td></tr>
  <tr><td class="label">Ngày lập</td><td colspan="5">$todayFmt</td></tr>
  <tr><td colspan="6"></td></tr>
  <tr>
    <td class="h">STT</td>
    <td class="h">Mặt hàng</td>
    <td class="h">ĐVT</td>
    <td class="h">Giá gốc (đ)</td>
    <td class="h">Giá bán (đ)</td>
    <td class="h">Chênh lệch</td>
  </tr>
  $rows
  <tr>
    <td class="sum" colspan="3" style="text-align:right">TỔNG CỘNG</td>
    <td class="sum">${fmtN(q.totalBase)}</td>
    <td class="sum">${fmtN(q.totalSell)}</td>
    <td class="sum">${q.profit >= 0 ? "+" : ""}${fmtN(q.profit)}</td>
  </tr>
</table>
</body></html>''';

      final dir      = await getTemporaryDirectory();
      final safeName = q.customerName.replaceAll(RegExp(r'[^\w ]'), '').trim().replaceAll(' ', '_');
      final fileName = 'BaoGia_${safeName}_T${q.month + 1}_${q.year}.xls';
      final file     = File('${dir.path}/$fileName');
      await file.writeAsBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(html)]);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/vnd.ms-excel', name: fileName)],
        subject: 'Báo giá ${q.customerName} — ${kMonths[q.month]}/${q.year}',
      );
    } catch (e) {
      if (mounted) showToast(context, 'Lỗi xuất file: $e', isError: true);
    } finally {
      if (mounted) setState(() => _exportingExcel = false);
    }
  }

  @override
  Widget _statCell(BuildContext context, {required String label, required String value, required Color color}) =>
    Expanded(child: Column(children: [
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
          textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(fontSize: 9, color: context.p.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.3),
          textAlign: TextAlign.center),
    ]));

  Widget _vDivider(BuildContext context) =>
    Container(width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 4),
        color: context.p.border.withOpacity(0.5));

  @override
  Widget build(BuildContext context) {
    final s  = AppStrings.of(context);
    final q  = widget.quote;
    final lv = getPriceLevel(q.totalBase > 0 ? q.totalSell / q.totalBase : 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0E7C8C).withOpacity(0.13), blurRadius: 22, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Gradient header ──
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D8A9C), Color(0xFF0B4F72)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('${kMonths[q.month]} / ${q.year}'.toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: lv.bg, borderRadius: BorderRadius.circular(20)),
                child: Text(lv.label, style: TextStyle(fontSize: 10, color: lv.color, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _confirmDel = !_confirmDel),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: _confirmDel ? const Color(0xFFDC2626) : const Color(0xFFDC2626).withOpacity(0.75),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _confirmDel ? Icons.close_rounded : Icons.delete_outline_rounded,
                    size: 15, color: Colors.white,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Text(q.customerName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.4, height: 1.1)),
            const SizedBox(height: 8),
            Row(children: [
              if (q.customerType.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
                  child: Text(q.customerType,
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
              ],
              Text('× ${q.coefficient.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),

        // ── Stats row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Row(children: [
            _statCell(context, label: s.statItems, value: '${q.items.length} ${s.itemsLabel}', color: context.p.teal),
            _vDivider(context),
            _statCell(context,
              label: s.statProfit,
              value: '${q.profit >= 0 ? "+" : "−"}${fmtK(q.profit.abs())}đ',
              color: q.profit >= 0 ? const Color(0xFF15803D) : const Color(0xFFDC2626)),
            _vDivider(context),
            _statCell(context, label: s.statBase, value: fmtK(q.totalBase), color: context.p.text2),
            _vDivider(context),
            _statCell(context, label: s.statSell, value: fmtK(q.totalSell), color: context.p.textMain),
          ]),
        ),

        Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 14), color: context.p.border.withOpacity(0.4)),
        const SizedBox(height: 12),

        // ── Items ──
        ...q.items.map((it) => Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Row(children: [
            Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(color: Color(0xFFE0F7FA), shape: BoxShape.circle),
              child: Center(child: Text(it.icon, style: const TextStyle(fontSize: 17))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(it.name,
                style: TextStyle(fontSize: 13, color: context.p.textMain, fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: it.sellPrice < it.basePrice ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('${fmtK(it.sellPrice)}/${it.unit}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: it.sellPrice < it.basePrice ? const Color(0xFFDC2626) : const Color(0xFF15803D))),
            ),
          ]),
        )),

        const SizedBox(height: 10),

        // ── Actions ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Column(children: [
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: _exporting ? null : _exportWord,
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                      border: Border.all(color: context.p.navy, width: 1.5),
                      borderRadius: BorderRadius.circular(21)),
                  child: Center(child: _exporting
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.p.navy))
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.description_rounded, size: 15, color: context.p.navy),
                          const SizedBox(width: 6),
                          Text(s.exportWord, style: TextStyle(color: context.p.navy, fontSize: 12, fontWeight: FontWeight.w700)),
                        ])),
                ),
              )),
              const SizedBox(width: 8),
              Expanded(child: GestureDetector(
                onTap: _exportingExcel ? null : _exportExcel,
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF15803D), width: 1.5),
                      borderRadius: BorderRadius.circular(21)),
                  child: Center(child: _exportingExcel
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF15803D)))
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.table_chart_rounded, size: 15, color: Color(0xFF15803D)),
                          const SizedBox(width: 6),
                          Text(s.exportExcel, style: const TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.w700)),
                        ])),
                ),
              )),
            ]),
            if (_confirmDel) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, size: 15, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Xóa báo giá này?',
                      style: TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.w700))),
                  GestureDetector(
                    onTap: () { context.read<AppState>().deleteQuote(q.id); showToast(context, s.deleteDebtToast); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(12)),
                      child: Text(s.delete, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _confirmDel = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Text(s.cancel, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────
class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color, bg;
  final VoidCallback onTap;
  const _ShortcutCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.p.border, width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppIcon(icon: icon, color: color, bg: bg, size: 38, iconSize: 19),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: context.p.textMain)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: context.p.textMuted)),
          const SizedBox(height: 8),
          Row(children: [
            Text(s.scView, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right, size: 14, color: color),
          ]),
        ]),
      ),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownBox({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(11), border: Border.all(color: context.p.border, width: 1.5)),
    child: DropdownButton<String>(
      value: value, items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)))).toList(),
      onChanged: onChanged, underline: const SizedBox(), isExpanded: true, dropdownColor: context.p.surface,
    ),
  );
}

class _CatDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _CatDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
    child: DropdownButton<String>(
      value: value, isExpanded: true, underline: const SizedBox(), dropdownColor: context.p.surface,
      items: kCategories.map((c) => DropdownMenuItem(value: c, child: Text('${kCatIcons[c]} $c', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)))).toList(),
      onChanged: onChanged,
    ),
  );
}

class _UnitDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _UnitDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
    child: DropdownButton<String>(
      value: value, isExpanded: true, underline: const SizedBox(), dropdownColor: context.p.surface,
      items: kSeafoodUnits.map((u) => DropdownMenuItem(value: u, child: Text(u, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)))).toList(),
      onChanged: onChanged,
    ),
  );
}

class _SumItem extends StatelessWidget {
  final String label, value;
  const _SumItem(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
    Text(value, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w800)),
  ]);
}

// ── Edit sheet (bottom sheet) ─────────────────────────────────────────────────
class _SeafoodEditSheet extends StatefulWidget {
  final Seafood sf;
  const _SeafoodEditSheet({required this.sf});
  @override
  State<_SeafoodEditSheet> createState() => _SeafoodEditSheetState();
}

class _SeafoodEditSheetState extends State<_SeafoodEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late String _cat;
  late String _unit;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.sf.name);
    _priceCtrl = TextEditingController(
        text: widget.sf.basePrice > 0 ? fmt(widget.sf.basePrice) : '');
    _cat  = widget.sf.category;
    _unit = widget.sf.unit;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final s    = AppStrings.readFrom(context);
    if (name.isEmpty) { showToast(context, s.seafoodName, isError: true); return; }
    final price = double.tryParse(
        _priceCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    setState(() => _saving = true);
    try {
      await context.read<AppState>().updateSeafood(
        widget.sf.copyWith(
          name: name, category: _cat, unit: _unit,
          icon: kCatIcons[_cat] ?? '🐡', basePrice: price,
        ),
      );
      if (!mounted) return;
      showToast(context, '${s.savedToast} "$name"');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showToast(context, 'Lỗi: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s      = AppStrings.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        // handle
        Center(child: Container(width: 36, height: 4,
          decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        // header
        Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42, height: 42,
            decoration: BoxDecoration(color: const Color(0xFFEEF6F7), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(kCatIcons[_cat] ?? '🐡', style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Text(s.editSeafood, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.p.textMain)),
        ]),
        const SizedBox(height: 16),
        // tên
        FieldLabel(s.seafoodName),
        OceanInput(controller: _nameCtrl, hint: s.seafoodHint),
        const SizedBox(height: 10),
        // danh mục + đơn vị
        Row(children: [
          Expanded(child: _CatDropdown(value: _cat, onChanged: (v) => setState(() => _cat = v!))),
          const SizedBox(width: 8),
          Expanded(child: _UnitDropdown(value: _unit, onChanged: (v) => setState(() => _unit = v!))),
        ]),
        const SizedBox(height: 10),
        // giá gốc
        FieldLabel(s.basePrice),
        OceanInput(controller: _priceCtrl, hint: '0', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        // nút
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: _saving ? null : _save,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                gradient: _saving ? null : kGradPP,
                color: _saving ? context.p.textMuted : null,
                borderRadius: BorderRadius.circular(24),
                boxShadow: _saving ? [] : [
                  BoxShadow(color: kPurple.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              child: Center(child: _saving
                  ? const Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Đang lưu...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    ])
                  : Text(s.save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
            ),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(24)),
              child: Center(child: Text('✕', style: TextStyle(color: context.p.text2, fontSize: 17))),
            ),
          ),
        ]),
      ]),
    );
  }

  @override
  void dispose() { _nameCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }
}
