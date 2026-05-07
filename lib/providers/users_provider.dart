import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/user_type.dart';
import 'auth_provider.dart';

// ─── User Types (for dropdowns) ────────────────────────────────────────────

final userTypesProvider = FutureProvider<List<UserType>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getUserTypes();
  if (response['success'] == true) {
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => UserType.fromJson(json as Map<String, dynamic>)).toList();
  }
  return [];
});

// ─── Users State ────────────────────────────────────────────────────────────

class UsersState {
  final List<User> users;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int? filterUserTypeId;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterUserTypeId,
  });

  UsersState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? filterUserTypeId,
    bool clearFilter = false,
    bool clearError = false,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      filterUserTypeId: clearFilter ? null : (filterUserTypeId ?? this.filterUserTypeId),
    );
  }
}

// ─── Users Notifier ─────────────────────────────────────────────────────────

class UsersNotifier extends StateNotifier<UsersState> {
  final Ref _ref;

  UsersNotifier(this._ref) : super(const UsersState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.getUsers(
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        userTypeId: state.filterUserTypeId,
      );

      if (response['success'] == true) {
        // Handle both paginated and plain list responses
        final dynamic raw = response['data'];
        List<dynamic> list;
        if (raw is Map && raw.containsKey('data')) {
          list = raw['data'] as List<dynamic>;
        } else if (raw is List) {
          list = raw;
        } else {
          list = [];
        }
        final users = list
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
        state = state.copyWith(users: users, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message']?.toString() ?? 'Failed to load users',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadUsers();
  }

  void setFilter(int? userTypeId) {
    if (userTypeId == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterUserTypeId: userTypeId);
    }
    loadUsers();
  }

  /// Returns null on success, error message on failure.
  Future<String?> createUser({
    required String name,
    required String email,
    required String password,
    required int userTypeId,
  }) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.createUser(
        name: name,
        email: email,
        password: password,
        userTypeId: userTypeId,
      );
      if (response['success'] == true) {
        await loadUsers();
        return null;
      }
      return _extractError(response);
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns null on success, error message on failure.
  Future<String?> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.updateUser(id, data);
      if (response['success'] == true) {
        await loadUsers();
        return null;
      }
      return _extractError(response);
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns null on success, error message on failure.
  Future<String?> deleteUser(int id) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.deleteUser(id);
      if (response['success'] == true) {
        await loadUsers();
        return null;
      }
      return _extractError(response);
    } catch (e) {
      return e.toString();
    }
  }

  String _extractError(Map<String, dynamic> response) {
    final errors = response['errors'];
    if (errors != null && errors is Map) {
      return errors.values
          .map((v) => v is List ? v.join(', ') : v.toString())
          .join('\n');
    }
    return response['message']?.toString() ?? 'An error occurred';
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(ref);
});
