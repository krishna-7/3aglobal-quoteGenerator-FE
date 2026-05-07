import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/users_provider.dart';
import '../widgets/sidebar.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final usersState = ref.watch(usersProvider);
    final isAdmin = authState.user?.userTypeId == 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBreadcrumb(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'User Management',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212529),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const Spacer(),
                            if (isAdmin)
                              ElevatedButton.icon(
                                onPressed: () => _showUserDialog(context),
                                icon: const Icon(Icons.person_add, size: 18),
                                label: const Text('Add User'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6FAB23),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFilterBar(),
                        const SizedBox(height: 16),
                        if (usersState.isLoading)
                          const Center(
                              child: Padding(
                            padding: EdgeInsets.all(48),
                            child: CircularProgressIndicator(),
                          ))
                        else if (usersState.error != null)
                          _buildError(usersState.error!)
                        else
                          _buildTable(usersState.users, isAdmin),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('User Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          CircleAvatar(radius: 19, backgroundColor: Colors.grey[300], child: const Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        TextButton(
          onPressed: () => context.go('/dashboard'),
          child: const Text('Dashboard',
              style: TextStyle(fontSize: 14, color: Color(0xFF0D6EFD), fontFamily: 'Poppins')),
        ),
        const Text(' / ', style: TextStyle(color: Color(0xFF6C757D))),
        const Text('Users', style: TextStyle(fontSize: 14, color: Color(0xFF6C757D), fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildFilterBar() {
    final usersState = ref.watch(usersProvider);
    final userTypesAsync = ref.watch(userTypesProvider);

    return Row(
      children: [
        // Search
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => ref.read(usersProvider.notifier).setSearch(v),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Filter by user type
        Expanded(
          flex: 2,
          child: userTypesAsync.when(
            data: (types) => Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDEE2E6)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: usersState.filterUserTypeId,
                  hint: const Text('All Roles', style: TextStyle(fontSize: 14)),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('All Roles')),
                    ...types.map((t) => DropdownMenuItem<int?>(value: t.id, child: Text(t.name))),
                  ],
                  onChanged: (v) => ref.read(usersProvider.notifier).setFilter(v),
                ),
              ),
            ),
            loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
            error: (_, __) => const SizedBox(),
          ),
        ),
        const SizedBox(width: 12),
        // Refresh
        IconButton(
          onPressed: () => ref.read(usersProvider.notifier).loadUsers(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildTable(List<User> users, bool isAdmin) {
    if (users.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: const Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: Color(0xFFADB5BD)),
            SizedBox(height: 12),
            Text('No users found', style: TextStyle(fontSize: 16, color: Color(0xFF6C757D), fontFamily: 'Poppins')),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
          headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF495057), fontFamily: 'Poppins'),
          dataTextStyle: const TextStyle(fontSize: 14, color: Color(0xFF212529), fontFamily: 'Poppins'),
          columnSpacing: 24,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users.asMap().entries.map((entry) {
            final i = entry.key;
            final user = entry.value;
            return DataRow(
              color: WidgetStateProperty.resolveWith((states) =>
                  i.isOdd ? const Color(0xFFFAFAFA) : Colors.white),
              cells: [
                DataCell(Text('${i + 1}', style: const TextStyle(color: Color(0xFF6C757D)))),
                DataCell(Row(children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF6FAB23),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(user.name),
                ])),
                DataCell(Text(user.email, style: const TextStyle(color: Color(0xFF6C757D)))),
                DataCell(_buildRoleBadge(user.userType?.name ?? 'Type ${user.userTypeId}')),
                DataCell(Text(
                  user.createdAt != null
                      ? user.createdAt!.substring(0, 10)
                      : '—',
                  style: const TextStyle(color: Color(0xFF6C757D), fontSize: 13),
                )),
                DataCell(Row(children: [
                  if (isAdmin) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0D6EFD)),
                      tooltip: 'Edit',
                      onPressed: () => _showUserDialog(context, user: user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC3545)),
                      tooltip: 'Delete',
                      onPressed: () => _showDeleteDialog(context, user),
                    ),
                  ] else
                    const Text('—', style: TextStyle(color: Color(0xFF6C757D))),
                ])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String label) {
    final color = label.toLowerCase().contains('admin') || label == 'Type 1'
        ? const Color(0xFF6FAB23)
        : const Color(0xFF0D6EFD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
    );
  }

  Widget _buildError(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFECB5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFF856404)),
          const SizedBox(width: 12),
          Expanded(child: Text(error, style: const TextStyle(color: Color(0xFF856404), fontFamily: 'Poppins'))),
          TextButton(
            onPressed: () => ref.read(usersProvider.notifier).loadUsers(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ────────────────────────────────────────────────────────────────

  void _showUserDialog(BuildContext context, {User? user}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UserFormDialog(user: user),
    );
  }

  void _showDeleteDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Confirm Delete', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF495057), fontSize: 14),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(text: user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '? This action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final error = await ref.read(usersProvider.notifier).deleteUser(user.id);
              if (error != null) {
                messenger.showSnackBar(
                  SnackBar(content: Text(error), backgroundColor: const Color(0xFFDC3545)),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('User deleted successfully'),
                    backgroundColor: Color(0xFF6FAB23),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── User Form Dialog ────────────────────────────────────────────────────────

class _UserFormDialog extends ConsumerStatefulWidget {
  final User? user;
  const _UserFormDialog({this.user});

  @override
  ConsumerState<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _selectedUserTypeId;
  bool _isSaving = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _selectedUserTypeId = widget.user!.userTypeId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userTypesAsync = ref.watch(userTypesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6FAB23).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_outlined : Icons.person_add_outlined,
                      color: const Color(0xFF6FAB23),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Edit User' : 'Add New User',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFFECB5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, size: 16, color: Color(0xFF856404)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(color: Color(0xFF856404), fontSize: 13, fontFamily: 'Poppins'))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Name
              _buildField(
                label: 'Full Name',
                child: TextFormField(
                  controller: _nameController,
                  validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                  decoration: _inputDecoration('Enter full name'),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              _buildField(
                label: 'Email Address',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                  decoration: _inputDecoration('Enter email address'),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              _buildField(
                label: isEdit ? 'New Password (leave blank to keep)' : 'Password',
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (!isEdit && (v == null || v.isEmpty)) return 'Password is required';
                    if (v != null && v.isNotEmpty && v.length < 8) return 'Min 8 characters';
                    return null;
                  },
                  decoration: _inputDecoration('Enter password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // User Type
              _buildField(
                label: 'Role / User Type',
                child: userTypesAsync.when(
                  data: (types) => DropdownButtonFormField<int>(
                    value: _selectedUserTypeId,
                    validator: (v) => v == null ? 'Please select a role' : null,
                    decoration: _inputDecoration('Select role'),
                    items: types
                        .map((t) => DropdownMenuItem<int>(value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedUserTypeId = v),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (e, _) => Text('Error loading roles: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(height: 28),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FAB23),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Update User' : 'Create User',
                            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF495057), fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFADB5BD)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDC3545))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; _errorMessage = null; });

    String? error;
    if (isEdit) {
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'user_type_id': _selectedUserTypeId,
      };
      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }
      error = await ref.read(usersProvider.notifier).updateUser(widget.user!.id, data);
    } else {
      error = await ref.read(usersProvider.notifier).createUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userTypeId: _selectedUserTypeId!,
      );
    }

    setState(() => _isSaving = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEdit ? 'User updated successfully' : 'User created successfully'),
        backgroundColor: const Color(0xFF6FAB23),
      ));
    }
  }
}
