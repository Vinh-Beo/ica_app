// ── NHẬP XUẤT ──────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../constants.dart';
import '../l10n/app_strings.dart';
import '../models.dart';
import '../widgets/app_icon.dart';
import '../widgets/common_widgets.dart';

class ImportExportScreen extends StatefulWidget {
  ImportExportScreen({super.key});
  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  String _view    = 'tonkho'; // 'tonkho' | 'giaodich'
  bool   _showAdd = false;
  String _type    = 'nhap';
  String? _sfId;
  final _qtyCtrl  = TextEditingController();
  String _date    = todayStr();
  String? _confirmDelId;

  final _searchCtrl = TextEditingController();
  String _search  = '';
  String _fMonth  = 'all';
  String _fYear   = 'all';

  bool _matchSf(Seafood s) =>
      _search.trim().isEmpty || s.name.toLowerCase().contains(_search.trim().toLowerCase());
  bool _inPeriod(String d) {
    final p = d.split('-');
    final okY = _fYear == 'all' || p[0] == _fYear;
    final okM = _fMonth == 'all' || ((int.tryParse(p.length > 1 ? p[1] : '') ?? 0) - 1) == int.parse(_fMonth);
    return okY && okM;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    if (_sfId == null && state.seafood.isNotEmpty) _sfId = state.seafood.first.id;
  }

  void _addEntry(AppState state) {
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '.')) ?? 0;
    if (qty == 0 || _sfId == null) return;
    state.addInventoryEntry(InventoryEntry(id: uid(), type: _type, sfId: _sfId!, qty: qty, date: _date));
    _qtyCtrl.clear();
    setState(() => _showAdd = false);
    showToast(context, AppStrings.readFrom(context).addEntryToast);
  }

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppState>();
    double bp(String id) => state.seafood.firstWhere((sf) => sf.id == id, orElse: () => Seafood(id:'',name:'',unit:'',icon:'',category:'',basePrice:0)).basePrice;
    final all = state.inventoryEntries;
    final periodEntries = all.where((e) => _inPeriod(e.date)).toList();
    final cardEntries = _view == 'giaodich' ? periodEntries : all; // tồn kho: all-time; lịch sử: theo kỳ
    final allNhap = cardEntries.where((e) => e.type == 'nhap').fold(0.0, (s, e) => s + e.qty);
    final allXuat = cardEntries.where((e) => e.type == 'xuat').fold(0.0, (s, e) => s + e.qty);
    final nhapVal = cardEntries.where((e) => e.type == 'nhap').fold(0.0, (s, e) => s + e.qty * bp(e.sfId));
    final xuatVal = cardEntries.where((e) => e.type == 'xuat').fold(0.0, (s, e) => s + e.qty.abs() * bp(e.sfId));
    final years = ({...all.map((e) => e.date.split('-')[0])}.toList()..sort((a, b) => b.compareTo(a)));

    final s = AppStrings.of(context);
    if (state.seafood.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        AppIcon(icon: Icons.set_meal_rounded, color: context.p.teal, size: 64, iconSize: 30), SizedBox(height: 12),
        Text(s.noSf, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.p.textMain)),
        SizedBox(height: 6), Text(s.noSfHint, style: TextStyle(fontSize: 12, color: context.p.textMuted)),
      ]));
    }

    return Column(children: [
      // header
      Container(color: context.p.bg, padding: EdgeInsets.fromLTRB(16,12,16,0), child: Column(children: [
        Row(children: [
          Expanded(child: _NXStat(s.totalIn, '${fmtK(nhapVal)}đ', '$allNhap ${s.invUnits}', [context.p.navy, context.p.teal])),
          SizedBox(width: 10),
          Expanded(child: _NXStat(s.totalOut, '${fmtK(xuatVal)}đ', '$allXuat ${s.invUnits}', [Color(0xFF15803D), Color(0xFF16A34A)])),
        ]),
        SizedBox(height: 10),
        Row(children: [
          Container(padding: EdgeInsets.all(3), decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: context.p.border, width: 1.5)), child: Row(mainAxisSize: MainAxisSize.min, children: [
            _ViewBtn(s.viewStock, 'tonkho', _view, () => setState(() => _view = 'tonkho')),
            _ViewBtn(s.viewHistTx, 'giaodich', _view, () => setState(() => _view = 'giaodich')),
          ])),
          Spacer(),
          GestureDetector(onTap: () => setState(() => _showAdd = !_showAdd),
            child: Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: _showAdd ? Color(0xFFFEF2F2) : context.p.teal, borderRadius: BorderRadius.circular(20)),
                child: Text(_showAdd ? s.close : s.add, style: TextStyle(color: _showAdd ? Color(0xFFDC2626) : Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))),
        ]),
        SizedBox(height: 10),
        // ── Thanh lọc: tìm tên hải sản (luôn hiện) + tháng/năm (chỉ ở Lịch sử) ──
        Container(
          decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.p.border, width: 1.5)),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Icon(Icons.search, size: 18, color: context.p.textMuted),
            SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain),
              decoration: InputDecoration(isDense: true, border: InputBorder.none, hintText: s.searchSeafood, hintStyle: TextStyle(color: context.p.textMuted, fontSize: 13)),
            )),
            if (_search.isNotEmpty) GestureDetector(onTap: () => setState(() { _search = ''; _searchCtrl.clear(); }), child: Icon(Icons.close, size: 16, color: context.p.textMuted)),
          ]),
        ),
        if (_view == 'giaodich') ...[
          SizedBox(height: 8),
          Row(children: [
            Expanded(child: _FilterDropdown(value: _fMonth, hint: s.allMonths,
              items: [DropdownMenuItem(value: 'all', child: Text(s.allMonths, style: TextStyle(fontSize: 13, color: context.p.textMain)))]
                ..addAll(List.generate(12, (i) => DropdownMenuItem(value: '$i', child: Text(kMonths[i], style: TextStyle(fontSize: 13, color: context.p.textMain))))),
              onChanged: (v) => setState(() => _fMonth = v ?? 'all'))),
            SizedBox(width: 8),
            SizedBox(width: 110, child: _FilterDropdown(value: _fYear, hint: s.allYears,
              items: [DropdownMenuItem(value: 'all', child: Text(s.allYears, style: TextStyle(fontSize: 13, color: context.p.textMain)))]
                ..addAll(years.map((y) => DropdownMenuItem(value: y, child: Text(y, style: TextStyle(fontSize: 13, color: context.p.textMain))))),
              onChanged: (v) => setState(() => _fYear = v ?? 'all'))),
          ]),
        ],
        SizedBox(height: 10),
      ])),

      Expanded(child: ListView(padding: EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        if (_showAdd) _buildAddForm(context, state),
        if (_view == 'tonkho') ..._buildTonKho(state),
        if (_view == 'giaodich') ..._buildGiaoDich(context, state, periodEntries),
      ])),
    ]);
  }

  Widget _buildAddForm(BuildContext context, AppState state) {
    final s  = AppStrings.of(context);
    final sf = _sfId != null ? state.seafood.firstWhere((item) => item.id == _sfId, orElse: () => state.seafood.first) : null;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.p.teal, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.newEntry, style: TextStyle(fontSize: 10, color: context.p.teal, fontWeight: FontWeight.w800, letterSpacing: 1)),
        SizedBox(height: 10),
        Row(children: [
          Expanded(child: _TypeBtn(s.typeIn, 'nhap', _type, () => setState(() => _type = 'nhap'))),
          SizedBox(width: 8),
          Expanded(child: _TypeBtn(s.typeOut, 'xuat', _type, () => setState(() => _type = 'xuat'))),
        ]),
        SizedBox(height: 10),
        FieldLabel(s.sfItem),
        Container(padding: EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
          child: DropdownButton<String>(
            value: _sfId, isExpanded: true, underline: SizedBox(), dropdownColor: context.p.surface,
            items: state.seafood.map((item) => DropdownMenuItem(value: item.id, child: Text('${item.icon} ${item.name} (${item.unit})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)))).toList(),
            onChanged: (v) => setState(() => _sfId = v),
          )),
        SizedBox(height: 8),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FieldLabel('${s.qtyLabel} (${sf?.unit ?? ''})${_type == 'xuat' ? " – ${s.negHint}" : ""}'),
            OceanInput(controller: _qtyCtrl, hint: _type == 'xuat' ? s.negQtyHint : '0',
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true)),
          ])),
          SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FieldLabel(s.dateLabel),
            GestureDetector(onTap: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); if (d != null) setState(() => _date = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}'); },
              child: Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
                  child: Text(fmtDate(_date), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)))),
          ])),
        ]),
        SizedBox(height: 12),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => _addEntry(state),
            child: Container(height: 40, decoration: BoxDecoration(color: context.p.teal, borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text(s.addEntry, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)))))),
          SizedBox(width: 8),
          GestureDetector(onTap: () => setState(() => _showAdd = false),
            child: Container(width: 40, height: 40, decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text('✕', style: TextStyle(color: context.p.text2, fontSize: 15))))),
        ]),
      ]),
    );
  }

  List<Widget> _buildTonKho(AppState state) {
    final s       = AppStrings.of(context);
    final visible = state.seafood.where(_matchSf).toList();
    if (visible.isEmpty) {
      return [Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Column(children: [
        AppIcon(icon: Icons.search_off_rounded, color: context.p.textMuted, size: 60, iconSize: 28), SizedBox(height: 10),
        Text(s.noTxFound, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.p.textMuted)),
      ])))];
    }
    return visible.map((sf) {
      final nhap     = state.totalNhap(sf.id);
      final xuat     = state.totalXuat(sf.id);
      final ton      = state.tonKho(sf.id);
      final hasData  = nhap > 0 || xuat != 0;
      final netXuat  = xuat < 0 ? 0.0 : xuat;
      final xuatPct  = nhap > 0 ? (netXuat / nhap).clamp(0.0, 1.0) : 0.0;
      final tonColor = ton > 0 ? Color(0xFF15803D) : ton < 0 ? Color(0xFFDC2626) : context.p.textMuted;
      final tonBg    = ton > 0 ? Color(0xFFDCFCE7) : ton < 0 ? Color(0xFFFEE2E2) : context.p.surface2;
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: context.p.textMain.withOpacity(0.04), blurRadius: 4)]),
        child: Column(children: [
          Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: Color(0xFFEEF6F7), borderRadius: BorderRadius.circular(13)),
                child: Center(child: Text(sf.icon, style: TextStyle(fontSize: 21)))),
            SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(sf.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.p.textMain)),
              Text('${sf.category} · ${sf.unit}', style: TextStyle(fontSize: 11, color: context.p.textMuted)),
            ])),
            Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: tonBg, borderRadius: BorderRadius.circular(10)),
                child: Text('${ton > 0 ? "+" : ""}${ton.toStringAsFixed(ton.truncateToDouble() == ton ? 0 : 1)} ${sf.unit}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tonColor))),
          ]),
          SizedBox(height: 12),
          Row(children: [
            Expanded(child: _InvStatBox(s.typeIn, nhap, sf.unit, context.p.teal, Color(0xFFE0F7FA), state.inventoryEntries.where((e) => e.sfId == sf.id && e.type == 'nhap').length)),
            SizedBox(width: 8),
            Expanded(child: _InvStatBox(xuat < 0 ? s.returns_ : s.typeOut, xuat, sf.unit, xuat < 0 ? Color(0xFFB45309) : Color(0xFF15803D), xuat < 0 ? Color(0xFFFEF3C7) : Color(0xFFDCFCE7), state.inventoryEntries.where((e) => e.sfId == sf.id && e.type == 'xuat').length)),
          ]),
          if (hasData) ...[
            SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: xuatPct, backgroundColor: context.p.surface2, color: context.p.teal, minHeight: 6)),
            SizedBox(height: 4),
            Row(children: [
              Text('${s.alreadyOut} ${(xuatPct * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 9, color: context.p.textMuted, fontWeight: FontWeight.w600)),
              Spacer(),
              Text('${s.remaining} ${((1 - xuatPct) * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 9, color: context.p.textMuted, fontWeight: FontWeight.w600)),
            ]),
          ],
        ]),
      );
    }).toList();
  }

  List<Widget> _buildGiaoDich(BuildContext context, AppState state, List<InventoryEntry> periodEntries) {
    String f(double v) => v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
    final filtered = periodEntries.where((e) {
      final sf = state.seafood.firstWhere((s) => s.id == e.sfId, orElse: () => Seafood(id:'',name:'',unit:'',icon:'🐡',category:'',basePrice:0));
      return _matchSf(sf);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
    final grouped = <String, List<InventoryEntry>>{};
    for (final e in filtered) { (grouped[e.date] ??= []).add(e); }
    final hasFilter = _search.trim().isNotEmpty || _fMonth != 'all' || _fYear != 'all';

    final s = AppStrings.of(context);
    if (grouped.isEmpty) return [Center(child: Padding(padding: EdgeInsets.only(top: 60), child: Column(children: [AppIcon(icon: hasFilter ? Icons.search_off_rounded : Icons.inventory_2_rounded, color: context.p.textMuted, size: 60, iconSize: 28), SizedBox(height: 10), Text(hasFilter ? s.noTxFound : s.noTx, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.p.textMuted))])))];

    // ── Bảng tổng nhập − xuất của từng hải sản trong kỳ ──
    final sfIds = <String>{...filtered.map((e) => e.sfId)}.toList();
    final periodLabel = (_fMonth != 'all' ? ' · ${kMonths[int.parse(_fMonth)]}' : '') + (_fYear != 'all' ? ' $_fYear' : '');
    final summaryCard = Container(
      margin: EdgeInsets.only(top: 4, bottom: 6),
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [context.p.navy, context.p.teal], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${s.summaryHeaderTx}$periodLabel', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.85), letterSpacing: 0.5)),
        ...sfIds.map((id) {
          final sf = state.seafood.firstWhere((s) => s.id == id, orElse: () => Seafood(id:'',name:'?',unit:'',icon:'🐡',category:'',basePrice:0));
          final n = filtered.where((e) => e.sfId == id && e.type == 'nhap').fold(0.0, (s, e) => s + e.qty);
          final x = filtered.where((e) => e.sfId == id && e.type == 'xuat').fold(0.0, (s, e) => s + e.qty);
          final net = n - x;
          return Container(
            padding: EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.18)))),
            child: Row(children: [
              Text(sf.icon, style: TextStyle(fontSize: 16)), SizedBox(width: 8),
              Expanded(child: Text(sf.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis)),
              _SumChip('📥 ${f(n)}'), SizedBox(width: 5), _SumChip('📤 ${f(x)}'), SizedBox(width: 8),
              SizedBox(width: 60, child: Text('${net > 0 ? "+" : ""}${f(net)} ${sf.unit}', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white))),
            ]),
          );
        }),
      ]),
    );

    return [
      summaryCard,
      ...grouped.entries.map((entry) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Row(children: [
          Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(20)), child: Text(fmtDate(entry.key), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.p.navy))),
          SizedBox(width: 8), Expanded(child: Divider(color: context.p.border)),
          SizedBox(width: 8), Text('${entry.value.length} ${s.invoicesUnitTx}', style: TextStyle(fontSize: 10, color: context.p.textMuted, fontWeight: FontWeight.w600)),
        ])),
        ...entry.value.map((e) {
          final sf = state.seafood.firstWhere((s) => s.id == e.sfId, orElse: () => Seafood(id:'',name:AppStrings.readFrom(context).unknownSeafood,unit:'',icon:'🐡',category:'',basePrice:0));
          final isNhap  = e.type == 'nhap';
          final isReturn = e.type == 'xuat' && e.qty < 0;
          final bgIcon  = isReturn ? Color(0xFFFEF3C7) : isNhap ? Color(0xFFE0F7FA) : Color(0xFFDCFCE7);
          final qtyColor = isReturn ? Color(0xFFB45309) : isNhap ? context.p.teal : Color(0xFF15803D);
          final badgeTxt = isReturn ? s.returns_ : isNhap ? s.typeIn : s.typeOut;
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: context.p.textMain.withOpacity(0.04), blurRadius: 4)]),
            child: Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: bgIcon, borderRadius: BorderRadius.circular(13)), child: Center(child: Text(sf.icon, style: TextStyle(fontSize: 20)))),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(sf.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.p.textMain))),
                  SizedBox(width: 6),
                  Container(padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: bgIcon, borderRadius: BorderRadius.circular(9)), child: Text(badgeTxt, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: qtyColor))),
                ]),
                SizedBox(height: 2),
                Text('${e.qty.abs()} ${sf.unit}${sf.basePrice > 0 ? " · ~${fmtK(e.qty.abs() * sf.basePrice)}đ" : ""}${isReturn ? " · ${s.returnToStock}" : ""}', style: TextStyle(fontSize: 11, color: context.p.textMuted)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${isNhap ? "+" : "↩"}${e.qty.abs()} ${sf.unit}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: qtyColor)),
                if (_confirmDelId == e.id) ...[
                  SizedBox(height: 4),
                  Row(children: [
                    GestureDetector(onTap: () { state.deleteInventoryEntry(e.id); setState(() => _confirmDelId = null); showToast(context, s.deleteDebtToast); },
                        child: Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Color(0xFFDC2626), borderRadius: BorderRadius.circular(8)), child: Text(s.delete, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))),
                    SizedBox(width: 4),
                    GestureDetector(onTap: () => setState(() => _confirmDelId = null),
                        child: Container(padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(8)), child: Text(s.cancel, style: TextStyle(fontSize: 10, color: context.p.text2)))),
                  ]),
                ] else ...[
                  SizedBox(height: 4),
                  GestureDetector(onTap: () => setState(() => _confirmDelId = e.id),
                      child: Container(width: 26, height: 26, decoration: BoxDecoration(color: Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFDC2626))))),
                ],
              ]),
            ]),
          );
        }),
      ],
    )),
    ];
  }

  @override
  void dispose() { _qtyCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }
}

class _NXStat extends StatelessWidget {
  final String title, value, sub;
  final List<Color> colors;
  _NXStat(this.title, this.value, this.sub, this.colors);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      SizedBox(height: 3),
      Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
      Text(sub, style: TextStyle(fontSize: 10, color: Colors.white70)),
    ]),
  );
}

class _InvStatBox extends StatelessWidget {
  final String label;
  final double qty;
  final String unit;
  final Color color, bg;
  final int count;
  _InvStatBox(this.label, this.qty, this.unit, this.color, this.bg, this.count);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, textBaseline: TextBaseline.alphabetic)),
      SizedBox(height: 3),
      Text('${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text('$unit · $count ${AppStrings.of(context).invoicesUnitTx}', style: TextStyle(fontSize: 10, color: color.withOpacity(0.75))),
    ]),
  );
}

class _ViewBtn extends StatelessWidget {
  final String label, key_, active;
  final VoidCallback onTap;
  _ViewBtn(this.label, this.key_, this.active, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 150),
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(color: active == key_ ? context.p.navy : Colors.transparent, borderRadius: BorderRadius.circular(19)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active == key_ ? Colors.white : context.p.text2)),
    ),
  );
}

class _TypeBtn extends StatelessWidget {
  final String label, key_, active;
  final VoidCallback onTap;
  _TypeBtn(this.label, this.key_, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isActive = active == key_;
    final color = key_ == 'nhap' ? context.p.teal : Color(0xFF15803D);
    final bg    = key_ == 'nhap' ? Color(0xFFE0F7FA) : Color(0xFFDCFCE7);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: isActive ? bg : context.p.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: isActive ? color : context.p.border, width: 1.5)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isActive ? color : context.p.textMuted))),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value, hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  _FilterDropdown({required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: context.p.border, width: 1.5)),
    child: DropdownButton<String>(
      value: value, isExpanded: true, underline: SizedBox(), isDense: true,
      dropdownColor: context.p.surface,
      style: TextStyle(fontSize: 13, color: context.p.textMain),
      items: items, onChanged: onChanged,
    ),
  );
}

class _SumChip extends StatelessWidget {
  final String label;
  _SumChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
  );
}
