import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/sidebar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Redirect to login if not authenticated
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Row(
        children: [
          // Sidebar
          const Sidebar(),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(context, user?.name ?? 'User'),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Text
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            'Hello, ${user?.name ?? 'User'}\nWelcome Back',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        // Summary Cards
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        // Charts Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Finance Chart
                            Expanded(flex: 2, child: _buildFinanceChart()),
                            const SizedBox(width: 24),
                            // Summary & Transactions
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  _buildSummaryOverview(),
                                  const SizedBox(height: 24),
                                  _buildRecentTransactions(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Budget Chart
                        _buildBudgetChart(),
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

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212529),
              fontFamily: 'Poppins',
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today, size: 20),
                onPressed: () {},
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC3545),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '12',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 19,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Revenue', '\$30.4K', Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Orders', '\$3.6K', Colors.green)),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('Avg. Order Value', '\$423K', Colors.orange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('Net Profit', '\$13.4K', Colors.purple),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212529),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial year',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212529),
                  fontFamily: 'Poppins',
                ),
              ),
              Row(
                children: [
                  _buildChartButton('Day', isActive: true),
                  const SizedBox(width: 8),
                  _buildChartButton('Week'),
                  const SizedBox(width: 8),
                  _buildChartButton('Month'),
                  const SizedBox(width: 8),
                  _buildChartButton('Year'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Placeholder for chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(child: Text('Chart will be implemented here')),
          ),
        ],
      ),
    );
  }

  Widget _buildChartButton(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isActive ? const Color(0xFF6FAB23) : const Color(0xFFADB5BD),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          decoration: isActive ? TextDecoration.underline : null,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildSummaryOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF212529),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aug 1, 2023 - Aug 31, 2023',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFF6C757D),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('\$30.4K', 'Revenue'),
              _buildSummaryItem('\$3.6K', 'Orders'),
              _buildSummaryItem('\$423K', 'Avg. Order Value'),
              _buildSummaryItem('\$13.4K', 'Net Profit'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212529),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF343A40),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212529),
                  fontFamily: 'Poppins',
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6FAB23),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTransactionItem('Text line', '10:42 PM', '+\$409.00', true),
          const SizedBox(height: 16),
          _buildTransactionItem('Text line', '08:42 PM', '-\$339.00', false),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String time,
    String amount,
    bool isIncoming,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isIncoming ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIncoming ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncoming ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF212529),
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                isIncoming ? 'Incoming' : 'Outgoing',
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF6C757D),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(
                fontSize: 10,
                color: isIncoming ? Colors.green : Colors.red,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6C757D),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget Spent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212529),
                  fontFamily: 'Poppins',
                ),
              ),
              Row(
                children: [
                  _buildChartButton('Day', isActive: true),
                  const SizedBox(width: 8),
                  _buildChartButton('Week'),
                  const SizedBox(width: 8),
                  _buildChartButton('Month'),
                  const SizedBox(width: 8),
                  _buildChartButton('Year'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Placeholder for chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text('Budget Chart will be implemented here'),
            ),
          ),
        ],
      ),
    );
  }
}
