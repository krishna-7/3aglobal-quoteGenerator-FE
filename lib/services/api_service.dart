import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/auth_response.dart';

class ApiService {
  static const String baseUrl =
      'https://llapi.3aglobal.ae/api'; //https://llapi.3aglobal.ae/api
  late final Dio _dio;

  Dio get dio => _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add interceptor to attach token to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear token and redirect to login
            _clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success && authResponse.data != null) {
        // Store token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', authResponse.data!.token);
        await prefs.setString(
          'user_data',
          jsonEncode(authResponse.data!.user.toJson()),
        );
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        return AuthResponse.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Even if logout fails on server, clear local token
    } finally {
      await _clearToken();
    }
  }

  Future<AuthResponse> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return AuthResponse.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // ─── User Management ───────────────────────────────────────────────────────

  /// Fetch paginated list of users. Supports optional search and userTypeId filter.
  Future<Map<String, dynamic>> getUsers({
    String? search,
    int? userTypeId,
    int perPage = 100,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'per_page': perPage, 'page': page};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (userTypeId != null) {
        queryParams['user_type_id'] = userTypeId;
      }

      final response = await _dio.get('/users', queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new user.
  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required int userTypeId,
  }) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'user_type_id': userTypeId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update an existing user. Only send the fields that changed.
  Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/users/$id', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete a user by id.
  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/users/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Fetch user types list (used for dropdowns).
  Future<Map<String, dynamic>> getUserTypes() async {
    try {
      final response = await _dio.get('/list/user-types');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  // ─── Payment Link Report ────────────────────────────────────────────────────

  /// Fetch payment links for reporting (large page size to get all records).
  Future<Map<String, dynamic>> getPaymentLinksReport({
    String? status,
    String? deliveryType,
    int perPage = 500,
  }) async {
    try {
      final params = <String, dynamic>{
        'per_page': perPage,
        'sort_by': 'created_at',
        'sort_order': 'desc',
      };
      if (status != null) params['status'] = status;
      if (deliveryType != null) params['delivery_type'] = deliveryType;
      final response = await _dio.get(
        '/payment-links',
        queryParameters: params,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  // ─── User Types CRUD ────────────────────────────────────────────────────────

  /// Full list of user types (for CRUD management).
  Future<Map<String, dynamic>> getUserTypesList() async {
    try {
      final response = await _dio.get(
        '/user-types',
        queryParameters: {'per_page': 100},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> createUserType({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/user-types',
        data: {'name': name, 'description': description},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> updateUserType(
    int id, {
    required String name,
    String? description,
  }) async {
    try {
      final response = await _dio.put(
        '/user-types/$id',
        data: {'name': name, 'description': description},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> deleteUserType(int id) async {
    try {
      final response = await _dio.delete('/user-types/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  // ─── Menus CRUD ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMenus({int perPage = 200}) async {
    try {
      final response = await _dio.get(
        '/menus',
        queryParameters: {
          'per_page': perPage,
          'sort_by': 'order',
          'sort_order': 'asc',
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> createMenu(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/menus', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> updateMenu(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/menus/$id', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> deleteMenu(int id) async {
    try {
      final response = await _dio.delete('/menus/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data as Map<String, dynamic>;
      throw Exception('Network error: ${e.message}');
    }
  }
}
