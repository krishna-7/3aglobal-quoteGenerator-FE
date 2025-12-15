import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/payment_link.dart';
import 'auth_provider.dart';

final paymentLinksProvider = FutureProvider.autoDispose<List<PaymentLink>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.dio.get('/payment-links');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PaymentLink.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to load payment links: $e');
  }
});

final createPaymentLinkProvider = FutureProvider.family<PaymentLink, Map<String, dynamic>>((ref, data) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.dio.post('/payment-links', data: data);
    if (response.statusCode == 201 && response.data['success'] == true) {
      return PaymentLink.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to create payment link');
  } on DioException catch (e) {
    if (e.response != null && e.response!.data != null) {
      final errorMessage = e.response!.data['message'] ?? 'Failed to create payment link';
      final errors = e.response!.data['errors'];
      if (errors != null) {
        throw Exception('$errorMessage: ${errors.toString()}');
      }
      throw Exception(errorMessage);
    }
    throw Exception('Network error: ${e.message}');
  } catch (e) {
    throw Exception('Failed to create payment link: $e');
  }
});



