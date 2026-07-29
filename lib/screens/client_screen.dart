// ── KHÁCH HÀNG ────────────────────────────────────────────────────────────────
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../app_state.dart';
import '../constants.dart';
import '../l10n/app_strings.dart';
import '../models.dart';
import '../widgets/app_icon.dart';
import '../widgets/common_widgets.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});
  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  bool      _showAdd   = false;
  String    _newName   = '';
  String    _newType   = 'Nhà hàng';
  String    _newCoeff  = '1.20';
  Customer? _bangKeCust; // null = danh sách, non-null = trang bảng kê

  @override
  Widget build(BuildContext context) {
    if (_bangKeCust != null) {
      return _BangKePage(
        customer: _bangKeCust!,
        onBack: () => setState(() => _bangKeCust = null),
      );
    }

    final s     = AppStrings.of(context);
    final state = context.watch<AppState>();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
      Row(children: [
        Expanded(child: Text(s.custTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.p.textMain, letterSpacing: -0.5))),
        GestureDetector(
          onTap: () => setState(() => _showAdd = !_showAdd),
          child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: _showAdd ? const Color(0xFFFEF2F2) : context.p.navy, borderRadius: BorderRadius.circular(20)),
            child: Text(_showAdd ? s.close : s.add, style: TextStyle(color: _showAdd ? const Color(0xFFDC2626) : Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
        ),
      ]),
      const SizedBox(height: 16),
      if (_showAdd) _buildAddForm(context, state),
      ...state.customers.map((c) => _CustomerCard(
        key: ValueKey(c.id),
        customer: c,
        onBangKe: () => setState(() => _bangKeCust = c),
      )),
    ]);
  }

  Widget _buildAddForm(BuildContext context, AppState state) {
    final s = AppStrings.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.p.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: context.p.teal, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.newCust, style: TextStyle(fontSize: 10, color: context.p.teal, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        FieldLabel(s.custNameLabel),
        OceanInput(hint: s.custNameHint, onChanged: (v) => _newName = v),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FieldLabel(s.custType),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
              child: DropdownButton<String>(value: _newType, isExpanded: true, underline: const SizedBox(), dropdownColor: context.p.surface,
                items: kCustomerTypes.map((t) => DropdownMenuItem(value: t, child: Row(children: [Icon(kTypeIcon[t]?.icon ?? Icons.store_rounded, size: 14, color: kTypeIcon[t]?.color ?? context.p.text2), const SizedBox(width: 6), Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.p.textMain))]))).toList(),
                onChanged: (v) => setState(() => _newType = v!))),
          ])),
          const SizedBox(width: 10),
          SizedBox(width: 90, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FieldLabel(s.coeff),
            OceanInput(hint: '1.20', keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) => _newCoeff = v),
          ])),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            if (_newName.trim().isEmpty) return;
            final coeff = double.tryParse(_newCoeff) ?? 0;
            if (coeff <= 0) return;
            state.addCustomer(Customer(id: uid(), name: _newName.trim(), type: _newType, coefficient: coeff));
            setState(() { _showAdd = false; _newName = ''; _newCoeff = '1.20'; });
            showToast(context, s.addCustToast);
          },
          child: Container(height: 44, decoration: BoxDecoration(color: context.p.teal, borderRadius: BorderRadius.circular(22)),
              child: Center(child: Text(s.addCust, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)))),
        ),
      ]),
    );
  }

}

// ── Customer Card ──────────────────────────────────────────────────────────────
class _CustomerCard extends StatefulWidget {
  final Customer customer;
  final VoidCallback onBangKe;
  const _CustomerCard({super.key, required this.customer, required this.onBangKe});
  @override
  State<_CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<_CustomerCard> {
  bool _isConfirmDel = false;
  bool _uploading    = false;

  Future<void> _pickAvatar() async {
    final appState = context.read<AppState>();
    final xfile = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 75, maxWidth: 512);
    if (xfile == null || !mounted) return;
    final bytes = await xfile.readAsBytes();
    if (!mounted) return;
    setState(() => _uploading = true);
    try {
      await appState
          .updateCustomerAvatar(widget.customer.id, bytes)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      if (mounted) {
        final s = AppStrings.readFrom(context);
        showToast(context, '${s.errAvatarUpload}: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s        = AppStrings.of(context);
    final state    = context.watch<AppState>();
    final c        = state.customers.firstWhere((x) => x.id == widget.customer.id, orElse: () => widget.customer);
    final pricedSf = state.pricedSeafood;
    final totalSell = pricedSf.fold(0.0, (sum, sf) => sum + state.getSellPriceFor(c.id, sf.id, sf.basePrice));
    final typeStyle = kTypeIcon[c.type];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: context.p.textMain.withValues(alpha: 0.04), blurRadius: 4)],
      ),
      child: Column(children: [
        // ── header ──
        Padding(padding: const EdgeInsets.fromLTRB(14, 14, 14, 0), child: Row(children: [
          // avatar với nút camera
          GestureDetector(
            onTap: _uploading ? null : _pickAvatar,
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: c.avatarUrl != null
                    ? Image.network(c.avatarUrl!, width: 44, height: 44, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _typeIcon(typeStyle, context))
                    : _typeIcon(typeStyle, context),
              ),
              if (_uploading)
                Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(13)),
                    child: const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))))
              else
                Positioned(right: 0, bottom: 0,
                  child: Container(width: 16, height: 16,
                    decoration: BoxDecoration(color: context.p.navy, borderRadius: BorderRadius.circular(5)),
                    child: const Icon(Icons.camera_alt_rounded, size: 10, color: Colors.white))),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.p.textMain), overflow: TextOverflow.ellipsis),
            Container(margin: const EdgeInsets.only(top: 3), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(12)),
              child: Text(c.type, style: TextStyle(fontSize: 10, color: context.p.teal, fontWeight: FontWeight.w700))),
            if (c.address != null && c.address!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 10, color: context.p.textMuted),
                const SizedBox(width: 3),
                Expanded(child: Text(c.address!, style: TextStyle(fontSize: 10, color: context.p.textMuted), overflow: TextOverflow.ellipsis)),
              ]),
            ],
            if (c.taxCode != null && c.taxCode!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.receipt_long_outlined, size: 10, color: context.p.textMuted),
                const SizedBox(width: 3),
                Text('${s.taxPrefix}: ${c.taxCode}', style: TextStyle(fontSize: 10, color: context.p.textMuted)),
              ]),
            ],
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(10)),
            child: Text('×${c.coefficient.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.p.teal))),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _openEditSheet,
            child: Container(width: 30, height: 30, decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(9)),
                child: Center(child: Icon(Icons.edit_rounded, size: 14, color: context.p.text2)))),
        ])),

        // ── price table ──
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 10), child: Column(children: [
          Container(decoration: BoxDecoration(border: Border.all(color: context.p.border), borderRadius: BorderRadius.circular(12)), child: Column(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: context.p.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(11))),
              child: Row(children: [
                Expanded(child: Text(s.tblSeafood, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: context.p.textMuted))),
                SizedBox(width: 60, child: Text(s.tblBase, textAlign: TextAlign.right, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: context.p.textMuted))),
                SizedBox(width: 76, child: Text(s.tblSell, textAlign: TextAlign.right, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: context.p.textMuted))),
              ])),
            if (pricedSf.isEmpty)
              Padding(padding: const EdgeInsets.all(10), child: Text(s.noBaseTbl, style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)), textAlign: TextAlign.center))
            else ...pricedSf.asMap().entries.map((entry) => Container(
              decoration: BoxDecoration(border: entry.key > 0 ? const Border(top: BorderSide(color: Color(0xFFF4F7F8))) : null),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(children: [
                Expanded(child: Text('${entry.value.icon} ${entry.value.name}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                SizedBox(width: 60, child: Text(fmtK(entry.value.basePrice), textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: context.p.textMuted))),
                SizedBox(width: 76, child: Text(fmtK(state.getSellPriceFor(c.id, entry.value.id, entry.value.basePrice)), textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: context.p.teal, fontWeight: FontWeight.w800))),
              ]),
            )),
          ])),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Expanded(child: Text(s.sellTotal, style: const TextStyle(fontSize: 11, color: Color(0xFF0E7C8C), fontWeight: FontWeight.w600))),
              Text('${fmt(totalSell)} đ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.p.teal)),
            ])),
        ])),

        // ── actions: bảng kê + delete ──
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 12), child: Row(children: [
          // Bảng kê button
          GestureDetector(
            onTap: widget.onBangKe,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3), width: 1.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.list_alt_rounded, size: 13, color: Color(0xFF7C3AED)),
                const SizedBox(width: 4),
                Text(s.bangKeBtn, style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          const Spacer(),
          if (_isConfirmDel) ...[
            Text(s.deleteQ, style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
            const SizedBox(width: 7),
            GestureDetector(
              onTap: () { state.deleteCustomer(c.id); showToast(context, '${s.delCustToast} "${c.name}"'); },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(16)),
                  child: Text(s.confirm, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)))),
            const SizedBox(width: 6),
            GestureDetector(onTap: () => setState(() => _isConfirmDel = false),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(16)),
                  child: Text(s.cancel, style: TextStyle(fontSize: 11, color: context.p.text2)))),
          ] else GestureDetector(
            onTap: () => setState(() => _isConfirmDel = true),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECACA), width: 1.5)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.delete_outline_rounded, size: 13, color: Color(0xFFDC2626)),
                const SizedBox(width: 4),
                Text(s.delete, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.w700)),
              ]))),
        ])),
      ]),
    );
  }

  void _openEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomerEditSheet(customer: widget.customer),
    );
  }

  Widget _typeIcon(CustTypeStyle? style, BuildContext context) => Container(
    width: 44, height: 44,
    color: (style?.color ?? context.p.text2).withValues(alpha: 0.12),
    child: Center(child: Icon(style?.icon ?? Icons.person_rounded, color: style?.color ?? context.p.text2, size: 22)),
  );

  @override
  void dispose() { super.dispose(); }
}

// ── Customer Edit Sheet ───────────────────────────────────────────────────────
class _CustomerEditSheet extends StatefulWidget {
  final Customer customer;
  const _CustomerEditSheet({required this.customer});
  @override
  State<_CustomerEditSheet> createState() => _CustomerEditSheetState();
}

class _CustomerEditSheetState extends State<_CustomerEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _coeffCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _taxCtrl;
  late String _type;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c  = widget.customer;
    _nameCtrl    = TextEditingController(text: c.name);
    _coeffCtrl   = TextEditingController(text: c.coefficient.toStringAsFixed(2));
    _addressCtrl = TextEditingController(text: c.address ?? '');
    _taxCtrl     = TextEditingController(text: c.taxCode ?? '');
    _type        = c.type;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _coeffCtrl.dispose();
    _addressCtrl.dispose(); _taxCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name  = _nameCtrl.text.trim();
    final coeff = double.tryParse(_coeffCtrl.text);
    if (name.isEmpty || coeff == null || coeff <= 0) return;
    // readFrom uses context.read — safe to call outside build()
    final s         = AppStrings.readFrom(context);
    final appState  = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final nav       = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await appState.updateCustomerInfo(Customer(
        id: widget.customer.id,
        name: name,
        type: _type,
        coefficient: coeff,
        avatarUrl: widget.customer.avatarUrl,
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        taxCode: _taxCtrl.text.trim().isEmpty     ? null : _taxCtrl.text.trim(),
      ));
      nav.pop();
      messenger.showSnackBar(SnackBar(
        content: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(s.updToast, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ]),
        backgroundColor: const Color(0xFF0E7490),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      if (mounted) { setState(() => _saving = false); showToast(context, '${s.errPrefix}: $e', isError: true); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2)))),
          Text(s.editCust, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.p.textMain)),
          const SizedBox(height: 14),
          FieldLabel(s.custNameLabel),
          OceanInput(hint: s.custNameHint, controller: _nameCtrl),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(s.custType),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.p.border, width: 1.5)),
                child: DropdownButton<String>(
                  value: _type, isExpanded: true, underline: const SizedBox(), dropdownColor: context.p.surface,
                  items: kCustomerTypes.map((t) => DropdownMenuItem(value: t, child: Row(children: [
                    Icon(kTypeIcon[t]?.icon ?? Icons.store_rounded, size: 14, color: kTypeIcon[t]?.color ?? context.p.text2),
                    const SizedBox(width: 6),
                    Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.p.textMain)),
                  ]))).toList(),
                  onChanged: (v) => setState(() => _type = v!),
                )),
            ])),
            const SizedBox(width: 10),
            SizedBox(width: 90, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(s.coeff),
              OceanInput(hint: '1.20', controller: _coeffCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            ])),
          ]),
          const SizedBox(height: 10),
          FieldLabel('${s.custAddress} (${s.optional})'),
          OceanInput(hint: s.custAddressHint, controller: _addressCtrl),
          const SizedBox(height: 10),
          FieldLabel('${s.custTaxCode} (${s.optional})'),
          OceanInput(
            hint: s.custTaxHint,
            controller: _taxCtrl,
            keyboardType: TextInputType.number,
            suffix: GestureDetector(
              onTap: () {
                final text = _taxCtrl.text.trim();
                if (text.isEmpty) return;
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.copied), duration: const Duration(seconds: 1)));
              },
              child: Icon(Icons.copy_rounded, size: 16, color: context.p.textMuted),
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(height: 48,
              decoration: BoxDecoration(color: _saving ? context.p.text2 : context.p.teal, borderRadius: BorderRadius.circular(24)),
              child: Center(child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(s.saveChanges, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)))),
          ),
        ]),
      ),
    );
  }
}

// ── Trang Bảng kê ────────────────────────────────────────────────────────────
class _BangKePage extends StatefulWidget {
  final Customer customer;
  final VoidCallback onBack;
  const _BangKePage({required this.customer, required this.onBack});
  @override
  State<_BangKePage> createState() => _BangKePageState();
}

class _BangKePageState extends State<_BangKePage> {
  bool      _showForm      = false;
  bool      _saving        = false;
  bool      _confirmDelAll = false;
  bool      _exporting     = false;
  String    _delivDate     = todayStr();
  Seafood?  _selectedSf;

  final _priceCtrl  = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose(); _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final parts = _delivDate.split('-');
    final init = parts.length == 3
        ? DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]))
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() => _delivDate =
          '${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}');
    }
  }

  Future<void> _pickSeafood(AppState state) async {
    final picked = await showModalBottomSheet<Seafood>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SeafoodPickerSheet(seafood: state.seafood),
    );
    if (picked == null || !mounted) return;
    final sellPrice = state.getSellPriceFor(widget.customer.id, picked.id, picked.basePrice);
    setState(() => _selectedSf = picked);
    if (sellPrice > 0) _priceCtrl.text = sellPrice.round().toString();
  }

  Future<void> _save() async {
    if (_selectedSf == null) {
      showToast(context, 'Vui lòng chọn hải sản', isError: true); return;
    }
    final price  = double.tryParse(_priceCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ?? 0;
    if (price <= 0 || weight <= 0) {
      showToast(context, 'Vui lòng điền đầy đủ thông tin', isError: true); return;
    }
    setState(() => _saving = true);
    try {
      await context.read<AppState>().addBangKeItem(BangKeItem(
        id: uid(),
        customerId: widget.customer.id,
        seafoodName: _selectedSf!.name,
        unitPrice: price,
        weight: weight,
        deliveryDate: _delivDate,
        createdAt: DateTime.now().toIso8601String(),
      ));
      if (!mounted) return;
      _priceCtrl.clear(); _weightCtrl.clear();
      setState(() { _showForm = false; _saving = false; _delivDate = todayStr(); _selectedSf = null; });
    } catch (e) {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancelForm() {
    _priceCtrl.clear(); _weightCtrl.clear();
    setState(() { _showForm = false; _delivDate = todayStr(); _selectedSf = null; });
  }

  Future<void> _exportExcel(List<BangKeItem> items, double total) async {
    if (_exporting || items.isEmpty) return;
    setState(() => _exporting = true);
    try {
      String fmtW(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

      final rows = StringBuffer();
      for (int i = 0; i < items.length; i++) {
        final it = items[i];
        final t  = it.total.round();
        rows.write('<tr>'
            '<td>${i + 1}</td>'
            '<td>1</td>'
            '<td></td>'
            '<td>${it.seafoodName}</td>'
            '<td>KG</td>'
            '<td>${fmtW(it.weight)}</td>'
            '<td>${it.unitPrice.round()}</td>'
            '<td>0</td>'
            '<td>0</td>'
            '<td>$t</td>'
            '<td>0</td>'
            '<td>0</td>'
            '<td>$t</td>'
            '</tr>');
      }

      final today    = DateTime.now();
      final todayFmt = '${today.day.toString().padLeft(2,'0')}-${today.month.toString().padLeft(2,'0')}-${today.year}';

      final html = '''<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel"
xmlns="http://www.w3.org/TR/REC-html40">
<head><meta charset="UTF-8">
<!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets>
<x:ExcelWorksheet><x:Name>Bang ke</x:Name>
<x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions>
</x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->
<style>
  td { font-family: Arial, sans-serif; font-size: 11pt; border: 1px solid #000; }
  .h { font-weight: bold; text-align: center; background: #f2f2f2; }
</style>
</head><body>
<table border="1" cellspacing="0" cellpadding="4">
  <tr>
    <td class="h">STT</td>
    <td class="h">Tính chất</td>
    <td class="h">Mã hàng</td>
    <td class="h">Tên hàng</td>
    <td class="h">Đơn vị tính</td>
    <td class="h">Số lượng</td>
    <td class="h">Đơn giá</td>
    <td class="h">Tỷ lệ chiết khấu</td>
    <td class="h">Tiền chiết khấu</td>
    <td class="h">Thành tiền trước thu</td>
    <td class="h">Thuế suất</td>
    <td class="h">Tiền thuế</td>
    <td class="h">Tiền sau thuế</td>
  </tr>
  $rows
</table>
</body></html>''';

      final safeName = widget.customer.name.replaceAll(RegExp(r'[^\w ]'), '').trim().replaceAll(' ', '_');
      final fileName = 'BangKe_${safeName}_$todayFmt.xls'.replaceAll('/', '-');
      final bytes    = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(html)]);

      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'application/vnd.ms-excel', name: fileName)],
        subject: 'Bảng kê ${widget.customer.name}',
      );
    } catch (e) {
      if (mounted) showToast(context, 'Lỗi xuất file: $e', isError: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s     = AppStrings.of(context);
    final state = context.watch<AppState>();
    final items = state.bangKeFor(widget.customer.id);
    final total = items.fold(0.0, (sum, e) => sum + e.total);

    return Column(children: [
      PageHeader(
        title: s.bangKeTitle,
        subtitle: widget.customer.name,
        onBack: widget.onBack,
        trailing: GestureDetector(
          onTap: () => setState(() { _showForm = !_showForm; if (!_showForm) _cancelForm(); }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _showForm ? const Color(0xFFFEF2F2) : const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _showForm ? s.close : s.bangKeNew,
              style: TextStyle(
                color: _showForm ? const Color(0xFFDC2626) : Colors.white,
                fontSize: 12, fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),

      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [

          // ── Form tạo mới ──
          if (_showForm)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.p.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('✦ MỤC MỚI', style: TextStyle(fontSize: 10, color: const Color(0xFF7C3AED), fontWeight: FontWeight.w800, letterSpacing: 1)),
                const SizedBox(height: 12),
                FieldLabel(s.bangKeSeafood),
                GestureDetector(
                  onTap: () => _pickSeafood(context.read<AppState>()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: context.p.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.p.border, width: 1.5),
                    ),
                    child: Row(children: [
                      Expanded(child: Text(
                        _selectedSf?.name ?? s.bangKeSeafoodH,
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: _selectedSf != null ? context.p.textMain : context.p.textMuted,
                        ),
                      )),
                      Icon(Icons.arrow_drop_down_rounded, color: context.p.textMuted),
                    ]),
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    FieldLabel(s.bangKeWeight),
                    OceanInput(hint: '0.0', controller: _weightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ])),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    FieldLabel(s.bangKePrice),
                    OceanInput(hint: '0', controller: _priceCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ])),
                ]),
                const SizedBox(height: 10),
                FieldLabel(s.bangKeDelivery),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: context.p.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.p.border, width: 1.5),
                    ),
                    child: Row(children: [
                      Icon(Icons.calendar_today_rounded, size: 15, color: context.p.teal),
                      const SizedBox(width: 8),
                      Text(fmtDate(_delivDate), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.p.textMain)),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: _saving ? null : _save,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _saving ? const Color(0xFFAB8EE8) : const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
                    ),
                  )),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _cancelForm,
                    child: Container(
                      height: 44, width: 80,
                      decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(22)),
                      child: Center(child: Text(s.cancel, style: TextStyle(color: context.p.text2, fontWeight: FontWeight.w700, fontSize: 14))),
                    ),
                  ),
                ]),
              ]),
            ),

          // ── Danh sách mục ──
          if (items.isEmpty && !_showForm)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AppIcon(icon: Icons.list_alt_rounded, color: const Color(0xFF7C3AED), size: 64, iconSize: 30),
                const SizedBox(height: 12),
                Text(s.bangKeEmpty, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.p.textMain)),
                const SizedBox(height: 6),
                Text(s.bangKeEmptySub, style: TextStyle(fontSize: 12, color: context.p.textMuted)),
              ]),
            )
          else if (items.isNotEmpty) ...[
            // Header bảng
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                SizedBox(width: 68, child: Text('Ngày giao', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: context.p.textMuted))),
                Expanded(child: Text('Hải sản', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: context.p.textMuted))),
                SizedBox(width: 72, child: Text('Đơn giá × KL', textAlign: TextAlign.right, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: context.p.textMuted))),
                SizedBox(width: 70, child: Text('Thành tiền', textAlign: TextAlign.right, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: context.p.textMuted))),
                const SizedBox(width: 28),
              ]),
            ),
            const SizedBox(height: 4),
            ...items.map((item) => _BangKeRow(
              item: item,
              onDelete: () => context.read<AppState>().deleteBangKeItem(item.id),
            )),
            const SizedBox(height: 10),
            // Tổng cộng
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Text(s.bangKeTotal, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70)),
                const Spacer(),
                Text('${fmt(total)} đ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
              ]),
            ),
            const SizedBox(height: 8),
            // Xuất Excel
            GestureDetector(
              onTap: () => _exportExcel(items, total),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: context.p.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF15803D).withValues(alpha: 0.5), width: 1.5),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _exporting
                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF15803D)))
                      : const Icon(Icons.table_chart_rounded, size: 15, color: Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Text(_exporting ? 'Đang xuất...' : 'Xuất Excel',
                      style: const TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            // Xóa tất cả
            if (_confirmDelAll)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.25)),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, size: 15, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Xóa toàn bộ danh sách?',
                      style: TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.w700))),
                  GestureDetector(
                    onTap: () async {
                      await context.read<AppState>().deleteBangKeForCustomer(widget.customer.id);
                      if (mounted) setState(() => _confirmDelAll = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(10)),
                      child: const Text('Xóa', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _confirmDelAll = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: context.p.bg, borderRadius: BorderRadius.circular(10)),
                      child: Text(s.cancel, style: TextStyle(fontSize: 12, color: context.p.text2, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              )
            else
              GestureDetector(
                onTap: () => setState(() => _confirmDelAll = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.p.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.delete_sweep_rounded, size: 15, color: Color(0xFFDC2626)),
                    SizedBox(width: 6),
                    Text('Xóa tất cả', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
          ],
        ],
      )),
    ]);
  }
}

class _BangKeRow extends StatefulWidget {
  final BangKeItem item;
  final VoidCallback onDelete;
  const _BangKeRow({required this.item, required this.onDelete});
  @override
  State<_BangKeRow> createState() => _BangKeRowState();
}

class _BangKeRowState extends State<_BangKeRow> {
  bool _confirmDel = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.p.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.p.textMain.withValues(alpha: 0.03), blurRadius: 3)],
      ),
      child: Row(children: [
        SizedBox(width: 68, child: Text(fmtDateShort(item.deliveryDate),
            style: TextStyle(fontSize: 11, color: context.p.textMuted, fontWeight: FontWeight.w600))),
        Expanded(child: Text(item.seafoodName,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.p.textMain),
            overflow: TextOverflow.ellipsis)),
        SizedBox(width: 72, child: Text(
          '${fmtK(item.unitPrice)}×${item.weight % 1 == 0 ? item.weight.toInt() : item.weight}',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 10, color: context.p.textMuted),
        )),
        SizedBox(width: 70, child: Text(fmtK(item.total),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF7C3AED)))),
        const SizedBox(width: 4),
        if (_confirmDel)
          GestureDetector(
            onTap: widget.onDelete,
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(color: const Color(0xFFDC2626), shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.check, size: 13, color: Colors.white)),
            ),
          )
        else
          GestureDetector(
            onTap: () => setState(() => _confirmDel = true),
            child: SizedBox(
              width: 24, height: 24,
              child: Center(child: Icon(Icons.delete_outline_rounded, size: 16, color: context.p.textMuted)),
            ),
          ),
      ]),
    );
  }
}

// ── Seafood Picker Sheet ──────────────────────────────────────────────────────
class _SeafoodPickerSheet extends StatelessWidget {
  final List<Seafood> seafood;
  const _SeafoodPickerSheet({required this.seafood});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.p.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 4),
          width: 36, height: 4,
          decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text('Chọn hải sản',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.p.textMain)),
        ),
        const Divider(height: 1),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: seafood.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: context.p.border),
            itemBuilder: (_, i) {
              final sf = seafood[i];
              return InkWell(
                onTap: () => Navigator.pop(context, sf),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(children: [
                    Text(sf.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Expanded(child: Text(sf.name,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.p.textMain))),
                    Text(sf.unit,
                        style: TextStyle(fontSize: 12, color: context.p.textMuted)),
                  ]),
                ),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
      ]),
    );
  }
}

// ── ĐƠN HÀNG (empty) ─────────────────────────────────────────────────────────
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const AppIcon(icon: Icons.inventory_2_rounded, color: Color(0xFF7C3AED), size: 72, iconSize: 34),
        const SizedBox(height: 14),
        Text(s.tabOrders, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.p.textMain)),
        const SizedBox(height: 6),
        Text(s.ordersSub, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.p.textMuted, height: 1.6)),
        const SizedBox(height: 16),
        const _ComingSoonBadge(),
      ]),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      decoration: BoxDecoration(color: context.p.surface2, borderRadius: BorderRadius.circular(20)),
      child: Text(s.comingSoon, style: TextStyle(fontSize: 12, color: context.p.textMuted, fontWeight: FontWeight.w700)),
    );
  }
}
