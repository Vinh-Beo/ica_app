import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../constants.dart';
import '../models.dart';
import '../widgets/app_icon.dart';
import '../widgets/common_widgets.dart';

// ── Root ──────────────────────────────────────────────────────────────────────
class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});
  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  String? _detailId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (_detailId != null) {
      final cust = state.customers.firstWhere((c) => c.id == _detailId, orElse: () => state.customers.first);
      return _CustomerDebtDetail(customer: cust, onBack: () => setState(() => _detailId = null));
    }
    return _CongNoMain(onSelect: (id) => setState(() => _detailId = id));
  }
}

// ── Main debt page ────────────────────────────────────────────────────────────
class _CongNoMain extends StatefulWidget {
  final ValueChanged<String> onSelect;
  const _CongNoMain({required this.onSelect});
  @override
  State<_CongNoMain> createState() => _CongNoMainState();
}

String _fmtInput(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';
  final n = int.tryParse(digits) ?? 0;
  return fmt(n.toDouble());
}

class _CongNoMainState extends State<_CongNoMain> {
  bool _showAdd = false;
  String? _selectedCustId;
  final _amountCtrl       = TextEditingController();
  final _noteCtrl         = TextEditingController();
  String _createdDate     = todayStr();
  String _deliveryDate    = todayStr();
  Uint8List? _imageBytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    if (_selectedCustId == null && state.customers.isNotEmpty) {
      _selectedCustId = state.customers.first.id;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 65);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  bool _saving = false;

  Future<void> _addDebt(AppState state) async {
    final amt = double.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (amt <= 0 || _selectedCustId == null || _saving) return;
    setState(() => _saving = true);
    try {
      await state.addDebt(DebtRecord(
        id: uid(), customerId: _selectedCustId!,
        amount: amt, deliveryDate: _deliveryDate, createdDate: _createdDate,
        imageBytes: _imageBytes, note: _noteCtrl.text.trim(),
        by: state.currentUserName,
      ));
      _amountCtrl.clear(); _noteCtrl.clear();
      if (mounted) {
        setState(() { _showAdd = false; _imageBytes = null; _saving = false; });
        showToast(context, 'Đã lưu: ${fmt(amt)}đ');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showToast(context, 'Lỗi: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state    = context.watch<AppState>();
    final unpaidAll = state.debts.where((d) => !d.isPaid);
    final totalAll  = unpaidAll.fold(0.0, (s, d) => s + d.amount);
    final debtorIds = unpaidAll.map((d) => d.customerId).toSet();
    final debtors   = state.customers.where((c) => debtorIds.contains(c.id)).toList();

    return Column(children: [
      // ── sticky header ──
      Container(
        color: context.p.bg,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(children: [
          // banner
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4F1D96), kPurple]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TỔNG CHƯA THU', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                const SizedBox(height: 3),
                Text('${fmt(totalAll)} đ', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
                Text('${debtors.length} khách · ${unpaidAll.length} đơn', style: const TextStyle(fontSize: 10, color: Colors.white70)),
              ])),
              GestureDetector(
                onTap: () => setState(() { _showAdd = !_showAdd; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: _showAdd ? const Color(0xFFFEF2F2) : context.p.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _showAdd ? const Color(0xFFFECACA) : context.p.surface.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Text(_showAdd ? '✕ Đóng' : '＋ Thêm mới',
                      style: TextStyle(color: _showAdd ? const Color(0xFFDC2626) : Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ]),
      ),

      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        // ── Add form ──
        if (_showAdd) _buildAddForm(context, state),

        // ── Debtor list ──
        if (debtors.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 60),
            child: Column(children: [
              const AppIcon(icon: Icons.celebration_rounded, color: Color(0xFF15803D), size: 64, iconSize: 30),
              const SizedBox(height: 12),
              Text('Không có công nợ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.p.textMain)),
              const SizedBox(height: 4),
              Text('Tất cả khách hàng đã thanh toán', style: TextStyle(fontSize: 12, color: context.p.textMuted)),
            ]),
          )
        else
          ...debtors.map((c) {
            final unpaid  = state.debts.where((d) => d.customerId == c.id && !d.isPaid).toList();
            final total   = unpaid.fold(0.0, (s, d) => s + d.amount);
            final latest  = unpaid.isEmpty ? null : (unpaid..sort((a,b) => b.createdDate.compareTo(a.createdDate))).first;
            return GestureDetector(
              onTap: () => widget.onSelect(c.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.p.surface, borderRadius: BorderRadius.circular(16),
                  border: const Border(left: BorderSide(color: Color(0xFFDC2626), width: 3)),
                  boxShadow: [BoxShadow(color: context.p.textMain.withValues(alpha: 0.04), blurRadius: 4)],
                ),
                child: Row(children: [
                  Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Icon(kTypeIcon[c.type]?.icon ?? Icons.person_rounded, color: kTypeIcon[c.type]?.color ?? const Color(0xFF0E7C8C), size: 22))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.p.textMain), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Wrap(spacing: 6, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1), decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(12)),
                          child: Text(c.type, style: TextStyle(fontSize: 10, color: context.p.teal, fontWeight: FontWeight.w700))),
                      if (latest != null)
                        Row(children: [Icon(Icons.local_shipping_rounded, size: 11, color: context.p.textMuted), const SizedBox(width: 3), Text(fmtDateShort(latest.deliveryDate), style: TextStyle(fontSize: 10, color: context.p.textMuted))]),
                      Text('${unpaid.length} đơn', style: const TextStyle(fontSize: 10, color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                    ]),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('${fmtK(total)}đ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                    Text('chưa thu', style: TextStyle(fontSize: 10, color: context.p.textMuted)),
                  ]),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 18),
                ]),
              ),
            );
          }),
      ])),
    ]);
  }

  Widget _buildAddForm(BuildContext context, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kPurple, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('✦ CÔNG NỢ MỚI', style: TextStyle(fontSize: 10, color: kPurple, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        // customer
        const FieldLabel('Khách hàng'),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
          child: DropdownButton<String>(
            value: _selectedCustId, isExpanded: true, underline: const SizedBox(), dropdownColor: context.p.surface,
            items: state.customers.map((c) => DropdownMenuItem<String>(value: c.id, child: Row(children: [Icon(kTypeIcon[c.type]?.icon ?? Icons.store_rounded, size: 14, color: kTypeIcon[c.type]?.color ?? context.p.text2), const SizedBox(width: 6), Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)))]))).toList(),
            onChanged: (v) => setState(() => _selectedCustId = v),
          ),
        ),
        const SizedBox(height: 10),
        // amount
        const FieldLabel('Số tiền (đ)'),
        OceanInput(
          controller: _amountCtrl, hint: '0', keyboardType: TextInputType.number,
          onChanged: (v) {
            final formatted = _fmtInput(v);
            if (formatted != v) {
              _amountCtrl.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        // dates
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FieldLabel('📝 Ngày tạo đơn'),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (d != null) setState(() => _createdDate = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}');
              },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
                  child: Text(fmtDate(_createdDate), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain))),
            ),
          ])),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FieldLabel('🚚 Ngày giao hàng'),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (d != null) setState(() => _deliveryDate = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}');
              },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
                  child: Text(fmtDate(_deliveryDate), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain))),
            ),
          ])),
        ]),
        const SizedBox(height: 10),
        // note
        const FieldLabel('Ghi chú'),
        OceanInput(controller: _noteCtrl, hint: 'VD: Giao tôm hùm 20kg...'),
        const SizedBox(height: 10),
        // image
        const FieldLabel('📷 Hình ảnh (tuỳ chọn)'),
        _imageBytes != null
            ? Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_imageBytes!, width: double.infinity, height: 130, fit: BoxFit.cover)),
                Positioned(top: 6, right: 6, child: GestureDetector(onTap: () => setState(() => _imageBytes = null),
                  child: Container(width: 26, height: 26, decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Center(child: Text('✕', style: TextStyle(color: Colors.white, fontSize: 12)))))),
              ])
            : GestureDetector(onTap: _pickImage,
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, style: BorderStyle.solid, width: 1.5)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.photo_library_rounded, size: 18, color: context.p.textMuted), const SizedBox(width: 8), Text('Chọn ảnh từ thư viện', style: TextStyle(fontSize: 12, color: context.p.textMuted, fontWeight: FontWeight.w600))]))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: _saving ? null : () => _addDebt(state),
            child: Container(height: 42, decoration: BoxDecoration(color: kPurple, borderRadius: BorderRadius.circular(21)),
                child: Center(child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('＋ Lưu công nợ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)))),
          )),
          const SizedBox(width: 8),
          GestureDetector(onTap: _saving ? null : () => setState(() => _showAdd = false),
            child: Container(width: 42, height: 42, decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(21)),
                child: Center(child: Text('✕', style: TextStyle(color: context.p.text2, fontSize: 15))))),
        ]),
      ]),
    );
  }

  @override
  void dispose() { _amountCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }
}

// ── Customer debt detail ──────────────────────────────────────────────────────
class _CustomerDebtDetail extends StatefulWidget {
  final Customer customer;
  final VoidCallback onBack;
  const _CustomerDebtDetail({required this.customer, required this.onBack});
  @override
  State<_CustomerDebtDetail> createState() => _CustomerDebtDetailState();
}

class _CustomerDebtDetailState extends State<_CustomerDebtDetail> {
  bool _showAdd = false;
  String? _confirmDelId;
  Uint8List? _expandImg;
  String? _expandUrl;
  final _amountCtrl    = TextEditingController();
  final _noteCtrl      = TextEditingController();
  String _createdDate  = todayStr();
  String _deliveryDate = todayStr();
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 65);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  bool _saving = false;

  Future<void> _addDebt(AppState state) async {
    final amt = double.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (amt <= 0 || _saving) return;
    setState(() => _saving = true);
    try {
      await state.addDebt(DebtRecord(
        id: uid(), customerId: widget.customer.id,
        amount: amt, deliveryDate: _deliveryDate, createdDate: _createdDate,
        imageBytes: _imageBytes, note: _noteCtrl.text.trim(),
        by: state.currentUserName,
      ));
      _amountCtrl.clear(); _noteCtrl.clear();
      if (mounted) {
        setState(() { _showAdd = false; _imageBytes = null; _saving = false; });
        showToast(context, 'Đã lưu: ${fmt(amt)}đ');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showToast(context, 'Lỗi: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state       = context.watch<AppState>();
    final custDebts   = state.debts.where((d) => d.customerId == widget.customer.id).toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
    final unpaidTotal = custDebts.where((d) => !d.isPaid).fold(0.0, (s, d) => s + d.amount);
    final paidTotal   = custDebts.where((d) => d.isPaid).fold(0.0, (s, d) => s + d.amount);

    return Column(children: [
      PageHeader(title: widget.customer.name, subtitle: widget.customer.type, onBack: widget.onBack),
      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
        // summary
        Row(children: [
          Expanded(child: _DebtStat('Chưa thu', '${fmtK(unpaidTotal)}đ', '${custDebts.where((d)=>!d.isPaid).length} đơn', const Color(0xFFDC2626), const Color(0xFFFEF2F2))),
          const SizedBox(width: 10),
          Expanded(child: _DebtStat('Đã thu', '${fmtK(paidTotal)}đ', '${custDebts.where((d)=>d.isPaid).length} đơn', const Color(0xFF15803D), const Color(0xFFDCFCE7))),
        ]),
        const SizedBox(height: 12),
        if (!_showAdd) GestureDetector(
          onTap: () => setState(() => _showAdd = true),
          child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFAB47BC), Color(0xFFEC407A)]), borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('＋ Thêm công nợ mới', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)))),
        ),
        if (_showAdd) _buildAddForm(context, state),
        const SizedBox(height: 8),
        if (custDebts.isEmpty)
          Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Column(children: [AppIcon(icon: Icons.receipt_long_rounded, color: context.p.textMuted, size: 56, iconSize: 26), const SizedBox(height: 8), Text('Chưa có công nợ', style: TextStyle(color: context.p.textMuted, fontWeight: FontWeight.w600))])))
        else
          ...custDebts.map((d) => _DebtCard(
            debt: d,
            isConfirmDel: _confirmDelId == d.id,
            onMarkPaid: () { state.markDebtPaid(d.id); showToast(context, 'Đã đánh dấu đã thu ✓'); },
            onDeleteTap: () => setState(() => _confirmDelId = d.id),
            onDeleteConfirm: () { state.deleteDebt(d.id); setState(() => _confirmDelId = null); showToast(context, 'Đã xoá'); },
            onDeleteCancel: () => setState(() => _confirmDelId = null),
            onImageTap: (bytes, url) => setState(() { _expandImg = bytes; _expandUrl = url; }),
          )),
      ])),
      // fullscreen image
      if (_expandImg != null || _expandUrl != null) GestureDetector(
        onTap: () => setState(() { _expandImg = null; _expandUrl = null; }),
        child: Container(color: Colors.black87, width: double.infinity, height: double.infinity,
          child: Stack(alignment: Alignment.center, children: [
            _expandImg != null
                ? Image.memory(_expandImg!, fit: BoxFit.contain)
                : Image.network(_expandUrl!, fit: BoxFit.contain,
                    loadingBuilder: (ctx, child, progress) => progress == null
                        ? child
                        : const CircularProgressIndicator(color: Colors.white)),
            Positioned(top: 40, right: 20, child: GestureDetector(onTap: () => setState(() { _expandImg = null; _expandUrl = null; }),
              child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.close, color: Colors.white, size: 20))))),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildAddForm(BuildContext context, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kPurple, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('✦ CÔNG NỢ MỚI', style: TextStyle(fontSize: 10, color: kPurple, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        const FieldLabel('Số tiền (đ)'),
        OceanInput(
          controller: _amountCtrl, hint: '0', keyboardType: TextInputType.number,
          onChanged: (v) {
            final formatted = _fmtInput(v);
            if (formatted != v) {
              _amountCtrl.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FieldLabel('📝 Ngày tạo đơn'),
            GestureDetector(onTap: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); if (d != null) setState(() => _createdDate = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}'); },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
                  child: Text(fmtDate(_createdDate), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)))),
          ])),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FieldLabel('🚚 Ngày giao hàng'),
            GestureDetector(onTap: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); if (d != null) setState(() => _deliveryDate = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}'); },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
                  child: Text(fmtDate(_deliveryDate), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.p.textMain)))),
          ])),
        ]),
        const SizedBox(height: 10),
        const FieldLabel('Ghi chú'),
        OceanInput(controller: _noteCtrl, hint: 'VD: Giao tôm hùm 20kg...'),
        const SizedBox(height: 10),
        const FieldLabel('📷 Hình ảnh (tuỳ chọn)'),
        _imageBytes != null
            ? Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_imageBytes!, width: double.infinity, height: 120, fit: BoxFit.cover)),
                Positioned(top: 6, right: 6, child: GestureDetector(onTap: () => setState(() => _imageBytes = null),
                  child: Container(width: 26, height: 26, decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Center(child: Text('✕', style: TextStyle(color: Colors.white, fontSize: 12)))))),
              ])
            : GestureDetector(onTap: _pickImage,
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.photo_library_rounded, size: 18, color: context.p.textMuted), const SizedBox(width: 8), Text('Chọn ảnh', style: TextStyle(fontSize: 12, color: context.p.textMuted, fontWeight: FontWeight.w600))]))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: _saving ? null : () => _addDebt(state),
            child: Container(height: 42, decoration: BoxDecoration(color: kPurple, borderRadius: BorderRadius.circular(21)),
                child: Center(child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('＋ Lưu công nợ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)))))),
          const SizedBox(width: 8),
          GestureDetector(onTap: _saving ? null : () => setState(() { _showAdd = false; _imageBytes = null; }),
            child: Container(width: 42, height: 42, decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(21)),
                child: Center(child: Text('✕', style: TextStyle(color: context.p.text2, fontSize: 15))))),
        ]),
      ]),
    );
  }

  @override
  void dispose() { _amountCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }
}

class _DebtCard extends StatelessWidget {
  final DebtRecord debt;
  final bool isConfirmDel;
  final VoidCallback onMarkPaid, onDeleteTap, onDeleteConfirm, onDeleteCancel;
  final void Function(Uint8List? bytes, String? url) onImageTap;
  const _DebtCard({required this.debt, required this.isConfirmDel, required this.onMarkPaid, required this.onDeleteTap, required this.onDeleteConfirm, required this.onDeleteCancel, required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    final isPaid = debt.isPaid;

    // Resolve image: prefer local bytes, decode base64, or use URL
    Uint8List? imgBytes = debt.imageBytes;
    if (imgBytes == null && debt.imageBase64 != null) {
      try { imgBytes = base64Decode(debt.imageBase64!); } catch (_) {}
    }
    final hasImg = imgBytes != null || debt.imageUrl != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isPaid ? 0.7 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.p.surface, borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: isPaid ? const Color(0xFF22C55E) : const Color(0xFFF59E0B), width: 3)),
          boxShadow: [BoxShadow(color: context.p.textMain.withValues(alpha: 0.04), blurRadius: 4)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('${fmt(debt.amount)} đ', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: isPaid ? const Color(0xFF15803D) : const Color(0xFFDC2626), letterSpacing: -0.4)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(18)),
                child: Text(isPaid ? '✓ Đã thu' : '⏳ Chưa thu', style: TextStyle(color: isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _DateBox('📝 Tạo đơn', fmtDate(debt.createdDate))),
            const SizedBox(width: 8),
            Expanded(child: _DateBox('🚚 Giao hàng', fmtDate(debt.deliveryDate))),
          ]),
          if (debt.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: context.p.surface2, borderRadius: BorderRadius.circular(9)),
                child: Row(children: [Icon(Icons.chat_bubble_outline_rounded, size: 13, color: context.p.textMuted), const SizedBox(width: 6), Expanded(child: Text(debt.note, style: TextStyle(fontSize: 12, color: context.p.text2, fontStyle: FontStyle.italic)))])),
          ],
          // ── Image thumbnail inline ──
          if (hasImg) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => onImageTap(imgBytes, debt.imageUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imgBytes != null
                    ? Image.memory(imgBytes, width: double.infinity, height: 160, fit: BoxFit.cover)
                    : Image.network(
                        debt.imageUrl!,
                        width: double.infinity, height: 160, fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) => progress == null
                            ? child
                            : Container(height: 160, color: context.p.bg,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        errorBuilder: (_, __, ___) => Container(
                          height: 50, color: context.p.bg,
                          child: Center(child: Icon(Icons.broken_image_rounded, color: context.p.textMuted)),
                        ),
                      ),
              ),
            ),
          ],
          if (isPaid && debt.paidDate != null) ...[
            const SizedBox(height: 6),
            Text('✓ Thu tiền ngày ${fmtDate(debt.paidDate)}', style: const TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
          ],
          if (debt.by.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.person_outline_rounded, size: 12, color: context.p.textMuted),
              const SizedBox(width: 4),
              Text.rich(TextSpan(children: [
                TextSpan(text: 'Được tạo bởi ', style: TextStyle(fontSize: 10.5, color: context.p.textMuted, fontWeight: FontWeight.w600)),
                TextSpan(text: debt.by, style: TextStyle(fontSize: 10.5, color: context.p.text2, fontWeight: FontWeight.w800)),
              ])),
            ]),
          ],
          const SizedBox(height: 10),
          Row(children: [
            if (!isPaid && !isConfirmDel) ...[
              Expanded(child: GestureDetector(onTap: onMarkPaid,
                child: Container(height: 38, decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(19)),
                    child: const Center(child: Text('✓ Đánh dấu đã thu', style: TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.w700)))))),
              const SizedBox(width: 8),
            ],
            if (isConfirmDel) ...[
              const Text('Xoá?', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Expanded(child: GestureDetector(onTap: onDeleteConfirm, child: Container(height: 38, decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(19)), child: const Center(child: Text('Xác nhận xoá', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))))),
              const SizedBox(width: 8),
              GestureDetector(onTap: onDeleteCancel, child: Container(width: 38, height: 38, decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(19)), child: Center(child: Icon(Icons.close_rounded, size: 16, color: context.p.text2)))),
            ] else GestureDetector(onTap: onDeleteTap, child: Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(19)), child: const Center(child: Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626))))),
          ]),
        ]),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label, value;
  const _DateBox(this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 9, color: context.p.textMuted, fontWeight: FontWeight.w700, textBaseline: TextBaseline.alphabetic, letterSpacing: 0.5)),
    const SizedBox(height: 2), Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.p.textMain)),
  ]));
}

class _DebtStat extends StatelessWidget {
  final String title, amount, sub;
  final Color color, bg;
  const _DebtStat(this.title, this.amount, this.sub, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(14,12,14,12), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title.toUpperCase(), style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.75), fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    const SizedBox(height: 3), Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    Text(sub, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.75))),
  ]));
}
