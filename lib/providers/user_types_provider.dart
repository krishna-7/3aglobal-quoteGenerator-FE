import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_type.dart';
import 'auth_provider.dart';

class UserTypesState {
  final List<UserType> userTypes;
  final bool isLoading;
  final String? error;

  const UserTypesState({
    this.userTypes = const [],
    this.isLoading = false,
    this.error,
  });

  UserTypesState copyWith({
    List<UserType>? userTypes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserTypesState(
      userTypes: userTypes ?? this.userTypes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class UserTypesNotifier extends StateNotifier<UserTypesState> {
  final Ref _ref;

  UserTypesNotifier(this._ref) : super(const UserTypesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = _ref.read(apiServiceProvider);
      final response = await api.getUserTypesList();
      if (response['success'] == true) {
        final raw = response['data'];
        List<dynamic> list;
        if (raw is Map && raw.containsKey('data')) {
          list = raw['data'] as List<dynamic>;
        } else if (raw is List) {
          list = raw;
        } else {
          list = [];
        }
        state = state.copyWith(
          userTypes: list.map((j) => UserType.fromJson(j as Map<String, dynamic>)).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response['message']?.toString() ?? 'Failed to load');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> create({required String name, String? description}) async {
    try {
      final api = _ref.read(apiServiceProvider);
      final res = await api.createUserType(name: name, description: description);
      if (res['success'] == true) { await load(); return null; }
      return _err(res);
    } catch (e) { return e.toString(); }
  }

  Future<String?> update(int id, {required String name, String? description}) async {
    try {
      final api = _ref.read(apiServiceProvider);
      final res = await api.updateUserType(id, name: name, description: description);
      if (res['success'] == true) { await load(); return null; }
      return _err(res);
    } catch (e) { return e.toString(); }
  }

  Future<String?> delete(int id) async {
    try {
      final api = _ref.read(apiServiceProvider);
      final res = await api.deleteUserType(id);
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

final userTypesManageProvider = StateNotifierProvider<UserTypesNotifier, UserTypesState>((ref) {
  return UserTypesNotifier(ref);
});
