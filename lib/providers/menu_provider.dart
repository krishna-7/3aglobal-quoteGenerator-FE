import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu.dart';
import 'auth_provider.dart';

final menuProvider = FutureProvider<List<Menu>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.dio.get('/menus/user/my-menus');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Menu.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    return [];
  }
});

final userMenusProvider = FutureProvider<List<Menu>>((ref) async {
  final menus = await ref.watch(menuProvider.future);
  // Filter only visible menus and sort by order
  // Note: Children are already included in the API response
  return menus
      .where((menu) => menu.isVisible)
      .toList()
    ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
});
