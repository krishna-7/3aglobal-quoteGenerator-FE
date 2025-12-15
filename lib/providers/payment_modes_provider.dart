import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_mode.dart';
import 'auth_provider.dart';

final paymentModesProvider = FutureProvider.autoDispose<List<PaymentMode>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    // Note: The API endpoint has a typo 'pament-modes' which we must match
    final response = await apiService.dio.get('/list/pament-modes');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PaymentMode.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to load payment modes: $e');
  }
});
