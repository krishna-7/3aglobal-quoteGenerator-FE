import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_model.dart';
import 'auth_provider.dart';

class MenusState {
  final List<MenuModel> menus; // flat list from API
  final bool isLoading;
  final String? error;

  const MenusState({this.menus = const [], this.isLoading = false, this.error});

  MenusState copyWith({List<MenuModel>? menus, bool? isLoading, String? error, bool clearError = false}) {
    return MenusState(
      menus: menus ?? this.menus,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Top-level menus (no parent)
  List<MenuModel> get parentMenus => menus.where((m) => m.parentId == null).toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  /// Children of a given parent id
  List<MenuModel> childrenOf(int parentId) => menus
      .where((m) => m.parentId == parentId)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
}

class MenusNotifier extends StateNotifier<MenusState> {
  final Ref _ref;
  MenusNotifier(this._ref) : super(const MenusState()) { load(); }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = _ref.read(apiServiceProvider);
      final res = await api.getMenus();
      if (res['success'] == true) {
        final raw = res['data'];
        List<dynamic> list;
        if (raw is Map && raw.containsKey('data')) {
          list = raw['data'] as List<dynamic>;
        } else if (raw is List) {
          list = raw;
        } else {
          list = [];
        }
        state = state.copyWith(
          menus: list.map((j) => MenuModel.fromJson(j as Map<String, dynamic>)).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: res['message']?.toString() ?? 'Failed to load menus');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      final res = await _ref.read(apiServiceProvider).createMenu(data);
      if (res['success'] == true) { await load(); return null; }
      return _err(res);
    } catch (e) { return e.toString(); }
  }

  Future<String?> update(int id, Map<String, dynamic> data) async {
    try {
      final res = await _ref.read(apiServiceProvider).updateMenu(id, data);
      if (res['success'] == true) { await load(); return null; }
      return _err(res);
    } catch (e) { return e.toString(); }
  }

  Future<String?> delete(int id) async {
    try {
      final res = await _ref.read(apiServiceProvider).deleteMenu(id);
      if (res['success'] == true) { await load(); return null; }
      return _err(res);
    } catch (e) { return e.toString(); }
  }

  String _err(Map<String, dynamic> r) {
    final errors = r['errors'];
    if (errors is Map) return errors.values.map((v) => v is List ? v.join(', ') : v.toString()).join('\n');
    return r['message']?.toString() ?? 'An error occurred';
  }
}

final menusProvider = StateNotifierProvider<MenusNotifier, MenusState>((ref) => MenusNotifier(ref));
