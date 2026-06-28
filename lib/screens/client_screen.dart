// ── KHÁCH HÀNG ────────────────────────────────────────────────────────────────
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  bool   _showAdd  = false;
  String _newName  = '';
  String _newType  = 'Nhà hàng';
  String _newCoeff = '1.20';

  @override
  Widget build(BuildContext context) {
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
      ...state.customers.map((c) => _CustomerCard(key: ValueKey(c.id), customer: c)),
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
  const _CustomerCard({super.key, required this.customer});
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
    final totalSell = pricedSf.fold(0.0, (sum, sf) => sum + sf.basePrice * c.coefficient);
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
                SizedBox(width: 76, child: Text(fmtK(entry.value.basePrice * c.coefficient), textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: context.p.teal, fontWeight: FontWeight.w800))),
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

        // ── delete ──
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 12), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
          OceanInput(hint: s.custTaxHint, controller: _taxCtrl, keyboardType: TextInputType.number),
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
