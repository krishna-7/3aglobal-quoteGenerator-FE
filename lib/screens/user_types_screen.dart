import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user_type.dart';
import '../providers/auth_provider.dart';
import '../providers/user_types_provider.dart';
import '../widgets/sidebar.dart';

class UserTypesScreen extends ConsumerWidget {
  const UserTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = auth.user?.userTypeId == 1;
    final state = ref.watch(userTypesManageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Row(children: [
        const Sidebar(),
        Expanded(child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(children: [
              const Text('User Type Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh',
                onPressed: () => ref.read(userTypesManageProvider.notifier).load()),
            ]),
          ),
          // Content
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Breadcrumb
              Row(children: [
                TextButton(onPressed: () => context.go('/dashboard'),
                  child: const Text('Dashboard',
                    style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 14, fontFamily: 'Poppins'))),
                const Text(' / ', style: TextStyle(color: Color(0xFF6C757D))),
                const Text('Settings', style: TextStyle(color: Color(0xFF6C757D), fontSize: 14, fontFamily: 'Poppins')),
                const Text(' / ', style: TextStyle(color: Color(0xFF6C757D))),
                const Text('User Types', style: TextStyle(color: Color(0xFF6C757D), fontSize: 14, fontFamily: 'Poppins')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                const Text('User Types', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                const Spacer(),
                if (isAdmin) ElevatedButton.icon(
                  onPressed: () => _showDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add User Type'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6FAB23), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              // Error
              if (state.error != null) Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFECB5))),
                child: Row(children: [
                  const Icon(Icons.warning_amber, color: Color(0xFF856404), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.error!, style: const TextStyle(color: Color(0xFF856404), fontFamily: 'Poppins'))),
                  TextButton(onPressed: () => ref.read(userTypesManageProvider.notifier).load(), child: const Text('Retry')),
                ]),
              ),
              // Loading
              if (state.isLoading) const Center(child: Padding(
                padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
              // Grid of cards
              if (!state.isLoading && state.error == null)
                state.userTypes.isEmpty
                  ? _emptyState(isAdmin, context, ref)
                  : _grid(state.userTypes, isAdmin, context, ref),
            ]),
          )),
        ])),
      ]),
    );
  }

  Widget _emptyState(bool isAdmin, BuildContext ctx, WidgetRef ref) => Container(
    width: double.infinity, padding: const EdgeInsets.all(48),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      const Icon(Icons.category_outlined, size: 48, color: Color(0xFFADB5BD)),
      const SizedBox(height: 12),
      const Text('No user types found', style: TextStyle(fontSize: 16, color: Color(0xFF6C757D), fontFamily: 'Poppins')),
      if (isAdmin) ...[
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () => _showDialog(ctx, ref), child: const Text('Add First User Type')),
      ],
    ]),
  );

  Widget _grid(List<UserType> types, bool isAdmin, BuildContext ctx, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 140,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: types.length,
      itemBuilder: (_, i) => _typeCard(types[i], isAdmin, ctx, ref),
    );
  }

  Widget _typeCard(UserType t, bool isAdmin, BuildContext ctx, WidgetRef ref) {
    final colors = [
      const Color(0xFF6FAB23), const Color(0xFF0D6EFD), const Color(0xFFFFC107),
      const Color(0xFF6C757D), const Color(0xFFDC3545), const Color(0xFF6610F2),
    ];
    final color = colors[t.id % colors.length];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(t.name[0].toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)))),
          const SizedBox(width: 12),
          Expanded(child: Text(t.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
            overflow: TextOverflow.ellipsis)),
          if (isAdmin) PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF6C757D)),
            onSelected: (v) {
              if (v == 'edit') _showDialog(ctx, ref, userType: t);
              if (v == 'delete') _showDeleteDialog(ctx, ref, t);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [
                Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0D6EFD)),
                SizedBox(width: 8), Text('Edit'),
              ])),
              const PopupMenuItem(value: 'delete', child: Row(children: [
                Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC3545)),
                SizedBox(width: 8), Text('Delete', style: TextStyle(color: Color(0xFFDC3545))),
              ])),
            ],
          ),
        ]),
        const SizedBox(height: 12),
        if (t.description != null && t.description!.isNotEmpty)
          Text(t.description!, style: const TextStyle(fontSize: 13, color: Color(0xFF6C757D), fontFamily: 'Poppins'),
            maxLines: 2, overflow: TextOverflow.ellipsis)
        else
          const Text('No description', style: TextStyle(fontSize: 13, color: Color(0xFFADB5BD), fontFamily: 'Poppins')),
        const Spacer(),
        Text('ID: ${t.id}', style: const TextStyle(fontSize: 11, color: Color(0xFFADB5BD), fontFamily: 'Poppins')),
      ]),
    );
  }

  void _showDialog(BuildContext ctx, WidgetRef ref, {UserType? userType}) {
    showDialog(context: ctx, barrierDismissible: false,
      builder: (_) => _UserTypeDialog(userType: userType));
  }

  void _showDeleteDialog(BuildContext ctx, WidgetRef ref, UserType t) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Confirm Delete', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      content: RichText(text: TextSpan(
        style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF495057), fontSize: 14),
        children: [
          const TextSpan(text: 'Are you sure you want to delete user type '),
          TextSpan(text: '"${t.name}"', style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: '? Users assigned this type may be affected.'),
        ],
      )),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(ctx);
            Navigator.pop(ctx);
            final err = await ref.read(userTypesManageProvider.notifier).delete(t.id);
            if (err != null) {
              messenger.showSnackBar(SnackBar(content: Text(err), backgroundColor: const Color(0xFFDC3545)));
            } else {
              messenger.showSnackBar(const SnackBar(content: Text('User type deleted'),
                backgroundColor: Color(0xFF6FAB23)));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC3545), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}

// ─── Dialog ─────────────────────────────────────────────────────────────────

class _UserTypeDialog extends ConsumerStatefulWidget {
  final UserType? userType;
  const _UserTypeDialog({this.userType});

  @override
  ConsumerState<_UserTypeDialog> createState() => _DialogState();
}

class _DialogState extends ConsumerState<_UserTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSaving = false;
  String? _error;

  bool get isEdit => widget.userType != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameCtrl.text = widget.userType!.name;
      _descCtrl.text = widget.userType!.description ?? '';
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFADB5BD)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDC3545))),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      width: 420, padding: const EdgeInsets.all(28),
      child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF6FAB23).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(isEdit ? Icons.edit_outlined : Icons.add, color: const Color(0xFF6FAB23), size: 20)),
          const SizedBox(width: 12),
          Text(isEdit ? 'Edit User Type' : 'Add User Type',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
        ]),
        const SizedBox(height: 24),
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFFECB5))),
            child: Row(children: [
              const Icon(Icons.warning_amber, size: 16, color: Color(0xFF856404)),
              const SizedBox(width: 8),
              Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFF856404), fontSize: 13, fontFamily: 'Poppins'))),
            ]),
          ),
          const SizedBox(height: 16),
        ],
        const Text('Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF495057), fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameCtrl,
          validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
          decoration: _dec('e.g. Manager, Viewer'),
        ),
        const SizedBox(height: 16),
        const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF495057), fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        TextFormField(
          controller: _descCtrl, maxLines: 3,
          decoration: _dec('Briefly describe what this user type can do...'),
        ),
        const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6FAB23), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'Update' : 'Create',
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
          ),
        ]),
      ])),
    ),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; _error = null; });
    final notifier = ref.read(userTypesManageProvider.notifier);
    final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    String? err;
    if (isEdit) {
      err = await notifier.update(widget.userType!.id, name: _nameCtrl.text.trim(), description: desc);
    } else {
      err = await notifier.create(name: _nameCtrl.text.trim(), description: desc);
    }
    setState(() => _isSaving = false);
    if (err != null) {
      setState(() => _error = err);
    } else if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEdit ? 'User type updated successfully' : 'User type created successfully'),
        backgroundColor: const Color(0xFF6FAB23),
      ));
    }
  }
}
