import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/payment_link_report_provider.dart';
import '../models/payment_link.dart';
import '../widgets/sidebar.dart';

class PaymentLinkReportScreen extends ConsumerStatefulWidget {
  const PaymentLinkReportScreen({super.key});
  @override
  ConsumerState<PaymentLinkReportScreen> createState() => _State();
}

class _State extends ConsumerState<PaymentLinkReportScreen> {
  final _searchCtrl = TextEditingController();

  static const _statuses = ['pending', 'sent', 'paid', 'expired', 'cancelled'];
  static const _statusColors = {
    'pending': Color(0xFFFFC107),
    'sent': Color(0xFF0D6EFD),
    'paid': Color(0xFF6FAB23),
    'expired': Color(0xFF6C757D),
    'cancelled': Color(0xFFDC3545),
  };

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final report = ref.watch(reportProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Row(children: [
        const Sidebar(),
        Expanded(child: Column(children: [
          _header(),
          Expanded(child: report.isLoading
            ? const Center(child: CircularProgressIndicator())
            : report.error != null ? _errView(report.error!) : _body(report)),
        ])),
      ]),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    color: Colors.white,
    child: Row(children: [
      const Text('Payment Link Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
      const Spacer(),
      IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh',
          onPressed: () => ref.read(reportProvider.notifier).loadReport()),
    ]),
  );

  Widget _errView(String e) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC3545)),
    const SizedBox(height: 12),
    Text(e, style: const TextStyle(color: Color(0xFF6C757D))),
    const SizedBox(height: 12),
    ElevatedButton(onPressed: () => ref.read(reportProvider.notifier).loadReport(), child: const Text('Retry')),
  ]));

  Widget _body(ReportState r) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        TextButton(onPressed: () => context.go('/dashboard'),
          child: const Text('Dashboard', style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 14, fontFamily: 'Poppins'))),
        const Text(' / ', style: TextStyle(color: Color(0xFF6C757D))),
        const Text('Payment Link Report', style: TextStyle(color: Color(0xFF6C757D), fontSize: 14, fontFamily: 'Poppins')),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        const Text('Payment Link Report', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () => _exportCsv(r.filteredLinks),
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Export CSV'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF6FAB23)),
            foregroundColor: const Color(0xFF6FAB23),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ]),
      const SizedBox(height: 24),
      _kpiRow(r),
      const SizedBox(height: 20),
      _statusChips(r),
      const SizedBox(height: 16),
      _filterBar(r),
      const SizedBox(height: 16),
      _table(r.filteredLinks),
    ]),
  );

  Widget _kpiRow(ReportState r) {
    final cur = r.allLinks.isNotEmpty ? r.allLinks.first.invoiceCurrency : 'AED';
    return Row(children: [
      _kpi('Total Links', '${r.totalLinks}', Icons.link, const Color(0xFF0D6EFD)),
      const SizedBox(width: 16),
      _kpi('Revenue', '$cur ${r.totalRevenue.toStringAsFixed(2)}', Icons.attach_money, const Color(0xFF6FAB23)),
      const SizedBox(width: 16),
      _kpi('Tax', '$cur ${r.totalTax.toStringAsFixed(2)}', Icons.receipt, const Color(0xFFFFC107)),
      const SizedBox(width: 16),
      _kpi('Paid', '${r.countByStatus('paid')}', Icons.check_circle_outline, const Color(0xFF6FAB23)),
      const SizedBox(width: 16),
      _kpi('Pending', '${r.countByStatus('pending')}', Icons.hourglass_empty, const Color(0xFFDC3545)),
    ]);
  }

  Widget _kpi(String label, String val, IconData icon, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'), overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D), fontFamily: 'Poppins')),
        ])),
      ]),
    ),
  );

  Widget _statusChips(ReportState r) {
    final n = ref.read(reportProvider.notifier);
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _chip('All', null, r.statusFilter, r.allLinks.length, const Color(0xFF495057), n),
      ..._statuses.map((s) => _chip(
        s[0].toUpperCase() + s.substring(1), s, r.statusFilter,
        r.countByStatus(s), _statusColors[s] ?? const Color(0xFF495057), n)),
    ]);
  }

  Widget _chip(String label, String? val, String? cur, int count, Color color, ReportNotifier n) {
    final active = cur == val;
    return InkWell(
      onTap: () => n.setStatusFilter(val),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : const Color(0xFFDEE2E6)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontSize: 13, fontFamily: 'Poppins',
            color: active ? Colors.white : color, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: active ? Colors.white.withValues(alpha: 0.25) : color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: TextStyle(fontSize: 11, color: active ? Colors.white : color, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  Widget _filterBar(ReportState r) => Row(children: [
    Expanded(flex: 3, child: SizedBox(height: 40, child: TextField(
      controller: _searchCtrl,
      decoration: InputDecoration(
        hintText: 'Search customer, reference or email...',
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: const Icon(Icons.search, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true, fillColor: Colors.white,
      ),
      onChanged: (v) => ref.read(reportProvider.notifier).setSearch(v),
    ))),
    const SizedBox(width: 12),
    _datePick('From', r.dateFrom, (d) => ref.read(reportProvider.notifier).setDateRange(d, r.dateTo)),
    const SizedBox(width: 8),
    _datePick('To', r.dateTo, (d) => ref.read(reportProvider.notifier).setDateRange(r.dateFrom, d)),
    const SizedBox(width: 8),
    if (r.statusFilter != null || r.searchQuery.isNotEmpty || r.dateFrom != null || r.dateTo != null)
      TextButton.icon(
        onPressed: () { _searchCtrl.clear(); ref.read(reportProvider.notifier).clearFilters(); },
        icon: const Icon(Icons.clear, size: 16), label: const Text('Clear'),
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC3545)),
      ),
  ]);

  Widget _datePick(String hint, DateTime? val, void Function(DateTime?) pick) => InkWell(
    onTap: () async {
      final d = await showDatePicker(context: context, initialDate: val ?? DateTime.now(),
        firstDate: DateTime(2020), lastDate: DateTime(2100));
      pick(d);
    },
    child: Container(
      height: 40, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white,
        border: Border.all(color: const Color(0xFFDEE2E6)), borderRadius: BorderRadius.circular(4)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.calendar_today, size: 14, color: Color(0xFF6C757D)),
        const SizedBox(width: 6),
        Text(val != null ? '${val.day}/${val.month}/${val.year}' : hint,
          style: TextStyle(fontSize: 13, fontFamily: 'Poppins',
            color: val != null ? const Color(0xFF212529) : const Color(0xFFADB5BD))),
      ]),
    ),
  );

  Widget _table(List<PaymentLink> links) {
    if (links.isEmpty) return Container(
      width: double.infinity, padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: const Column(children: [
        Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFADB5BD)),
        SizedBox(height: 12),
        Text('No records match your filters', style: TextStyle(color: Color(0xFF6C757D), fontFamily: 'Poppins')),
      ]),
    );

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
          headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF495057), fontFamily: 'Poppins'),
          dataTextStyle: const TextStyle(fontSize: 13, color: Color(0xFF212529), fontFamily: 'Poppins'),
          columnSpacing: 20, horizontalMargin: 16,
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Reference')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Tax')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Delivery')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Link')),
          ],
          rows: links.asMap().entries.map((e) {
            final i = e.key; final l = e.value;
            return DataRow(
              color: WidgetStateProperty.resolveWith((s) => i.isOdd ? const Color(0xFFFAFAFA) : Colors.white),
              cells: [
                DataCell(Text('${i + 1}', style: const TextStyle(color: Color(0xFF6C757D)))),
                DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(l.customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(l.customerEmail, style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D))),
                ])),
                DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(l.reference),
                  Text(l.reference1, style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D))),
                ])),
                DataCell(Text('${l.invoiceCurrency} ${l.invoiceAmount}')),
                DataCell(Text('${l.invoiceCurrency} ${l.taxAmount}')),
                DataCell(Text('${l.invoiceCurrency} ${l.totalAmount}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6FAB23)))),
                DataCell(_statusBadge(l.status)),
                DataCell(_deliveryBadge(l.deliveryType)),
                DataCell(Text(l.createdAt?.substring(0, 10) ?? '—',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D)))),
                DataCell(
                  l.paymentLinkUrl != null
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        // Copy button
                        Tooltip(
                          message: 'Copy link',
                          child: InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: l.paymentLinkUrl!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Link copied to clipboard!'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Color(0xFF0D6EFD),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D6EFD).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF0D6EFD).withValues(alpha: 0.25)),
                              ),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.copy_outlined, size: 12, color: Color(0xFF0D6EFD)),
                                SizedBox(width: 4),
                                Text('Copy', style: TextStyle(fontSize: 11, color: Color(0xFF0D6EFD), fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                              ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Open button
                        Tooltip(
                          message: 'Open in browser',
                          child: InkWell(
                            onTap: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final uri = Uri.tryParse(l.paymentLinkUrl!);
                              if (uri != null && await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not open link'),
                                    backgroundColor: Color(0xFFDC3545),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6FAB23).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF6FAB23).withValues(alpha: 0.25)),
                              ),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.open_in_new, size: 12, color: Color(0xFF6FAB23)),
                                SizedBox(width: 4),
                                Text('Open', style: TextStyle(fontSize: 11, color: Color(0xFF6FAB23), fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                              ]),
                            ),
                          ),
                        ),
                      ])
                    : const Text('—', style: TextStyle(color: Color(0xFF6C757D))),
                ),
              ],
            );
          }).toList(),
        ),
      )),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColors[status] ?? const Color(0xFF6C757D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35))),
      child: Text(status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
    );
  }

  Widget _deliveryBadge(String type) {
    final isEmail = type == 'email';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(isEmail ? Icons.email_outlined : Icons.sms_outlined, size: 14,
        color: isEmail ? const Color(0xFF0D6EFD) : const Color(0xFF6FAB23)),
      const SizedBox(width: 4),
      Text(isEmail ? 'Email' : 'SMS', style: TextStyle(fontSize: 12, fontFamily: 'Poppins',
        color: isEmail ? const Color(0xFF0D6EFD) : const Color(0xFF6FAB23))),
    ]);
  }

  void _exportCsv(List<PaymentLink> links) {
    final sb = StringBuffer();
    sb.writeln('Customer,Email,Reference,Ref1,Currency,Amount,Tax,Total,Status,Delivery,Date');
    for (final l in links) {
      sb.writeln('"${l.customerName}","${l.customerEmail}","${l.reference}","${l.reference1}",'
        '"${l.invoiceCurrency}","${l.invoiceAmount}","${l.taxAmount}","${l.totalAmount}",'
        '"${l.status}","${l.deliveryType}","${l.createdAt?.substring(0, 10) ?? ''}"');
    }
    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${links.length} records copied as CSV'),
      backgroundColor: const Color(0xFF6FAB23),
    ));
  }
}
