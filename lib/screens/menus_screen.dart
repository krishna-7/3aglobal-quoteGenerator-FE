import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/menu_model.dart';
import '../providers/auth_provider.dart';
import '../providers/menus_provider.dart';
import '../providers/users_provider.dart';
import '../widgets/sidebar.dart';

class MenusScreen extends ConsumerWidget {
  const MenusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final state = ref.watch(menusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Row(children: [
        const Sidebar(),
        Expanded(child: Column(children: [
          _header(context, ref),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                TextButton(onPressed: () => context.go('/dashboard'),
                  child: const Text('Dashboard', style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 14, fontFamily: 'Poppins'))),
                const Text(' / ', style: TextStyle(color: Color(0xFF6C757D))),
                const Text('Settings', style: TextStyle(color: Color(0xFF6C757D), fontSize: 14, fontFamily: 'Poppins')),
                const Text(' / ', style: TextStyle(color: Color(0xFF6C757D))),
                const Text('Menus', style: TextStyle(color: Color(0xFF6C757D), fontSize: 14, fontFamily: 'Poppins')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Menu Management', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Menu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6FAB23), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              if (state.error != null) _errorBanner(state.error!, ref),
              if (state.isLoading) const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
              if (!state.isLoading && state.error == null) _menuTree(context, ref, state),
            ]),
          )),
        ])),
      ]),
    );
  }

  Widget _header(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    color: Colors.white,
    child: Row(children: [
      const Text('Menu Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
      const Spacer(),
      IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh', onPressed: () => ref.read(menusProvider.notifier).load()),
    ]),
  );

  Widget _errorBanner(String error, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFFECB5))),
    child: Row(children: [
      const Icon(Icons.warning_amber, color: Color(0xFF856404), size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(error, style: const TextStyle(color: Color(0xFF856404), fontFamily: 'Poppins'))),
      TextButton(onPressed: () => ref.read(menusProvider.notifier).load(), child: const Text('Retry')),
    ]),
  );

  Widget _menuTree(BuildContext context, WidgetRef ref, MenusState state) {
    final parents = state.parentMenus;
    if (parents.isEmpty) return Container(
      width: double.infinity, padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        const Icon(Icons.menu_open, size: 48, color: Color(0xFFADB5BD)),
        const SizedBox(height: 12),
        const Text('No menus found', style: TextStyle(color: Color(0xFF6C757D), fontFamily: 'Poppins')),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () => _showDialog(context, ref), child: const Text('Add First Menu')),
      ]),
    );

    return Column(
      children: parents.map((parent) => _parentCard(context, ref, state, parent)).toList(),
    );
  }

  Widget _parentCard(BuildContext ctx, WidgetRef ref, MenusState state, MenuModel menu) {
    final children = state.childrenOf(menu.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Parent row
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF6FAB23).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.menu, size: 18, color: Color(0xFF6FAB23)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(menu.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                const SizedBox(width: 8),
                _activeBadge(menu.isActive),
                const SizedBox(width: 4),
                if (!menu.isVisible) _badge('Hidden', const Color(0xFF6C757D)),
              ]),
              Text('${menu.path}  •  order: ${menu.order}  •  icon: ${menu.icon}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D), fontFamily: 'Poppins')),
            ])),
            const SizedBox(width: 8),
            _userTypeBadges(menu.userTypeIds),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _showDialog(ctx, ref, parentId: menu.id),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Sub-menu', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0D6EFD)),
                foregroundColor: const Color(0xFF0D6EFD),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF6C757D)),
              onSelected: (v) {
                if (v == 'edit') _showDialog(ctx, ref, menu: menu);
                if (v == 'delete') _confirmDelete(ctx, ref, menu);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0D6EFD)), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC3545)), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Color(0xFFDC3545)))])),
              ],
            ),
          ]),
        ),
        // Children
        if (children.isNotEmpty) ...[
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ...children.map((child) => _childRow(ctx, ref, child)),
        ],
      ]),
    );
  }

  Widget _childRow(BuildContext ctx, WidgetRef ref, MenuModel menu) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))),
    child: Row(children: [
      const SizedBox(width: 32),
      const Icon(Icons.subdirectory_arrow_right, size: 16, color: Color(0xFFADB5BD)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: const Color(0xFF0D6EFD).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
        child: const Icon(Icons.link, size: 14, color: Color(0xFF0D6EFD)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(menu.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
          const SizedBox(width: 8),
          _activeBadge(menu.isActive),
          if (!menu.isVisible) ...[const SizedBox(width: 4), _badge('Hidden', const Color(0xFF6C757D))],
        ]),
        Text('${menu.path}  •  order: ${menu.order}', style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D), fontFamily: 'Poppins')),
      ])),
      _userTypeBadges(menu.userTypeIds),
      const SizedBox(width: 8),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF6C757D)),
        onSelected: (v) {
          if (v == 'edit') _showDialog(ctx, ref, menu: menu);
          if (v == 'delete') _confirmDelete(ctx, ref, menu);
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0D6EFD)), SizedBox(width: 8), Text('Edit')])),
          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC3545)), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Color(0xFFDC3545)))])),
        ],
      ),
    ]),
  );

  Widget _activeBadge(bool active) => _badge(active ? 'Active' : 'Inactive',
      active ? const Color(0xFF6FAB23) : const Color(0xFFDC3545));

  static Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
  );

  Widget _userTypeBadges(List<int> ids) {
    if (ids.isEmpty) return const SizedBox();
    return Wrap(spacing: 4, children: ids.map((id) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFF6C757D).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text('Type $id', style: const TextStyle(fontSize: 10, color: Color(0xFF6C757D), fontFamily: 'Poppins')),
    )).toList());
  }

  void _showDialog(BuildContext ctx, WidgetRef ref, {MenuModel? menu, int? parentId}) {
    showDialog(context: ctx, barrierDismissible: false,
        builder: (_) => _MenuDialog(menu: menu, defaultParentId: parentId));
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref, MenuModel menu) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Confirm Delete', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      content: RichText(text: TextSpan(
        style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF495057), fontSize: 14),
        children: [
          const TextSpan(text: 'Delete '),
          TextSpan(text: '"${menu.name}"', style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: '? Child menus will also be removed.'),
        ],
      )),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(ctx);
            Navigator.pop(ctx);
            final err = await ref.read(menusProvider.notifier).delete(menu.id);
            messenger.showSnackBar(SnackBar(
              content: Text(err ?? 'Menu deleted successfully'),
              backgroundColor: err != null ? const Color(0xFFDC3545) : const Color(0xFF6FAB23),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC3545), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}

// ─── Menu Form Dialog ─────────────────────────────────────────────────────────

class _MenuDialog extends ConsumerStatefulWidget {
  final MenuModel? menu;
  final int? defaultParentId;
  const _MenuDialog({this.menu, this.defaultParentId});
  @override
  ConsumerState<_MenuDialog> createState() => _MenuDialogState();
}

class _MenuDialogState extends ConsumerState<_MenuDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _iconCtrl = TextEditingController();
  final _routeCtrl = TextEditingController();
  final _pathCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  int? _parentId;
  bool _isActive = true;
  bool _isVisible = true;
  List<int> _selectedUserTypeIds = [];
  bool _isSaving = false;
  String? _error;

  bool get isEdit => widget.menu != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final m = widget.menu!;
      _nameCtrl.text = m.name;
      _iconCtrl.text = m.icon;
      _routeCtrl.text = m.route;
      _pathCtrl.text = m.path;
      _orderCtrl.text = m.order.toString();
      _parentId = m.parentId;
      _isActive = m.isActive;
      _isVisible = m.isVisible;
      _selectedUserTypeIds = List.from(m.userTypeIds);
    } else {
      _parentId = widget.defaultParentId;
      _orderCtrl.text = '1';
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _iconCtrl, _routeCtrl, _pathCtrl, _orderCtrl]) c.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFADB5BD)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDC3545))),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF495057), fontFamily: 'Poppins')),
  );

  @override
  Widget build(BuildContext context) {
    final menusState = ref.watch(menusProvider);
    final userTypesAsync = ref.watch(userTypesProvider);
    final parents = [null, ...menusState.parentMenus.where((m) => isEdit ? m.id != widget.menu!.id : true)];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 540,
        constraints: const BoxConstraints(maxHeight: 640),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF6FAB23).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(isEdit ? Icons.edit_outlined : Icons.add, color: const Color(0xFF6FAB23), size: 20)),
              const SizedBox(width: 12),
              Text(isEdit ? 'Edit Menu' : 'Add Menu', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
            ]),
          ),
          // Scrollable form body
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_error != null) ...[
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFFFECB5))),
                  child: Row(children: [
                    const Icon(Icons.warning_amber, size: 16, color: Color(0xFF856404)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFF856404), fontSize: 13, fontFamily: 'Poppins'))),
                  ])),
                const SizedBox(height: 16),
              ],
              // Name + Icon in a row
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Name *'),
                  TextFormField(controller: _nameCtrl, decoration: _dec('e.g. Dashboard'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Icon'),
                  TextFormField(controller: _iconCtrl, decoration: _dec('e.g. dashboard')),
                ])),
              ]),
              const SizedBox(height: 14),
              // Route + Path
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Route *'),
                  TextFormField(controller: _routeCtrl, decoration: _dec('e.g. quotes.index'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Path *'),
                  TextFormField(controller: _pathCtrl, decoration: _dec('e.g. /quotes'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                ])),
              ]),
              const SizedBox(height: 14),
              // Parent + Order
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Parent Menu'),
                  DropdownButtonFormField<int?>(
                    value: _parentId,
                    decoration: _dec('None (top-level)'),
                    items: parents.map((m) => DropdownMenuItem<int?>(
                      value: m?.id,
                      child: Text(m == null ? 'None (top-level)' : m.name, style: const TextStyle(fontSize: 14)),
                    )).toList(),
                    onChanged: (v) => setState(() => _parentId = v),
                  ),
                ])),
                const SizedBox(width: 12),
                SizedBox(width: 90, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Order'),
                  TextFormField(controller: _orderCtrl, keyboardType: TextInputType.number, decoration: _dec('1')),
                ])),
              ]),
              const SizedBox(height: 14),
              // Active + Visible toggles
              Row(children: [
                Expanded(child: Row(children: [
                  Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v),
                    activeColor: const Color(0xFF6FAB23)),
                  const SizedBox(width: 8),
                  const Text('Active', style: TextStyle(fontSize: 13, fontFamily: 'Poppins')),
                ])),
                Expanded(child: Row(children: [
                  Switch(value: _isVisible, onChanged: (v) => setState(() => _isVisible = v),
                    activeColor: const Color(0xFF6FAB23)),
                  const SizedBox(width: 8),
                  const Text('Visible', style: TextStyle(fontSize: 13, fontFamily: 'Poppins')),
                ])),
              ]),
              const SizedBox(height: 14),
              // User types
              _label('Accessible to User Types'),
              userTypesAsync.when(
                data: (types) => Wrap(spacing: 8, runSpacing: 8, children: types.map((t) {
                  final selected = _selectedUserTypeIds.contains(t.id);
                  return FilterChip(
                    label: Text(t.name, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins')),
                    selected: selected,
                    onSelected: (v) => setState(() => v ? _selectedUserTypeIds.add(t.id) : _selectedUserTypeIds.remove(t.id)),
                    selectedColor: const Color(0xFF6FAB23).withValues(alpha: 0.15),
                    checkmarkColor: const Color(0xFF6FAB23),
                    side: BorderSide(color: selected ? const Color(0xFF6FAB23) : const Color(0xFFDEE2E6)),
                  );
                }).toList()),
                loading: () => const CircularProgressIndicator(strokeWidth: 2),
                error: (e, _) => Text('Error: $e', style: const TextStyle(color: Color(0xFFDC3545))),
              ),
            ])),
          )),
          // Footer actions
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6FAB23), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                child: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Update Menu' : 'Create Menu',
                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; _error = null; });

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'icon': _iconCtrl.text.trim(),
      'route': _routeCtrl.text.trim(),
      'path': _pathCtrl.text.trim(),
      'order': int.tryParse(_orderCtrl.text) ?? 1,
      'is_active': _isActive,
      'is_visible': _isVisible,
      'user_type_ids': _selectedUserTypeIds,
    };
    if (_parentId != null) data['parent_id'] = _parentId;

    final notifier = ref.read(menusProvider.notifier);
    final err = isEdit ? await notifier.update(widget.menu!.id, data) : await notifier.create(data);

    setState(() => _isSaving = false);
    if (err != null) {
      setState(() => _error = err);
    } else if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEdit ? 'Menu updated successfully' : 'Menu created successfully'),
        backgroundColor: const Color(0xFF6FAB23),
      ));
    }
  }
}
