import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_link.dart';
import 'auth_provider.dart';

class ReportState {
  final List<PaymentLink> allLinks;
  final bool isLoading;
  final String? error;
  final String? statusFilter; // null = all
  final String searchQuery;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ReportState({
    this.allLinks = const [],
    this.isLoading = false,
    this.error,
    this.statusFilter,
    this.searchQuery = '',
    this.dateFrom,
    this.dateTo,
  });

  ReportState copyWith({
    List<PaymentLink>? allLinks,
    bool? isLoading,
    String? error,
    String? statusFilter,
    String? searchQuery,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearStatus = false,
    bool clearError = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return ReportState(
      allLinks: allLinks ?? this.allLinks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
    );
  }

  // ─── Computed getters ────────────────────────────────────────────────────

  List<PaymentLink> get filteredLinks {
    return allLinks.where((link) {
      // Status filter
      if (statusFilter != null && link.status != statusFilter) return false;
      // Search
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!link.customerName.toLowerCase().contains(q) &&
            !link.reference.toLowerCase().contains(q) &&
            !link.customerEmail.toLowerCase().contains(q)) {
          return false;
        }
      }
      // Date range
      if (dateFrom != null || dateTo != null) {
        final created = link.createdAt != null ? DateTime.tryParse(link.createdAt!) : null;
        if (created != null) {
          if (dateFrom != null && created.isBefore(dateFrom!)) return false;
          if (dateTo != null && created.isAfter(dateTo!.add(const Duration(days: 1)))) return false;
        }
      }
      return true;
    }).toList();
  }

  int get totalLinks => filteredLinks.length;

  double get totalRevenue => filteredLinks.fold(0, (sum, l) => sum + (double.tryParse(l.totalAmount) ?? 0));

  double get totalTax => filteredLinks.fold(0, (sum, l) => sum + (double.tryParse(l.taxAmount) ?? 0));

  double get totalInvoiceAmount => filteredLinks.fold(0, (sum, l) => sum + (double.tryParse(l.invoiceAmount) ?? 0));

  Map<String, int> get byStatus {
    final map = <String, int>{};
    for (final l in allLinks) {
      map[l.status] = (map[l.status] ?? 0) + 1;
    }
    return map;
  }

  int countByStatus(String s) => allLinks.where((l) => l.status == s).length;
}

class ReportNotifier extends StateNotifier<ReportState> {
  final Ref _ref;

  ReportNotifier(this._ref) : super(const ReportState()) {
    loadReport();
  }

  Future<void> loadReport() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = _ref.read(apiServiceProvider);
      final response = await api.getPaymentLinksReport();
      if (response['success'] == true) {
        final raw = response['data'];
        final list = raw is List ? raw : (raw is Map && raw.containsKey('data') ? raw['data'] as List : []);
        final links = list.map((j) => PaymentLink.fromJson(j as Map<String, dynamic>)).toList();
        state = state.copyWith(allLinks: links, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response['message']?.toString() ?? 'Failed to load');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setStatusFilter(String? status) => state = state.copyWith(
        statusFilter: status,
        clearStatus: status == null,
      );

  void setSearch(String q) => state = state.copyWith(searchQuery: q);

  void setDateRange(DateTime? from, DateTime? to) => state = state.copyWith(
        dateFrom: from,
        clearDateFrom: from == null,
        dateTo: to,
        clearDateTo: to == null,
      );

  void clearFilters() => state = state.copyWith(
        clearStatus: true,
        searchQuery: '',
        clearDateFrom: true,
        clearDateTo: true,
      );
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref);
});
