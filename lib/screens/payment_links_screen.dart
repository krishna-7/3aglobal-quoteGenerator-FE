import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/sidebar.dart';

class PaymentLinksScreen extends ConsumerStatefulWidget {
  const PaymentLinksScreen({super.key});

  @override
  ConsumerState<PaymentLinksScreen> createState() => _PaymentLinksScreenState();
}

class _PaymentLinksScreenState extends ConsumerState<PaymentLinksScreen> {
  final _formKey = GlobalKey<FormState>();

  // Customer Information
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();

  // Reference Fields
  final _referenceController = TextEditingController();
  final _reference1Controller = TextEditingController();

  // Delivery Type
  String _deliveryType = 'email';

  // Email Fields
  final _emailSubjectController = TextEditingController();
  final _emailBodyController = TextEditingController();

  // SMS Fields
  final _smsBodyController = TextEditingController();

  // Invoice Fields
  final _invoiceCurrencyController = TextEditingController();
  final _invoiceAmountController = TextEditingController();
  final _taxTypeController = TextEditingController();
  final _taxAmountController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _invoiceValidFromController = TextEditingController();
  final _termsAndConditionsController = TextEditingController();

  // Status
  String _status = 'pending';

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _referenceController.dispose();
    _reference1Controller.dispose();
    _emailSubjectController.dispose();
    _emailBodyController.dispose();
    _smsBodyController.dispose();
    _invoiceCurrencyController.dispose();
    _invoiceAmountController.dispose();
    _taxTypeController.dispose();
    _taxAmountController.dispose();
    _totalAmountController.dispose();
    _invoiceValidFromController.dispose();
    _termsAndConditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
                _buildHeader(context),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Breadcrumb
                          _buildBreadcrumb(),
                          const SizedBox(height: 16),
                          // Title
                          const Text(
                            'Payment Links',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Customer Information Section
                          _buildSectionTitle('Customer Information'),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Customer Name *',
                                  _customerNameController,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildTextField(
                                  'Customer Email *',
                                  _customerEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildTextField(
                                  'Customer Phone',
                                  _customerPhoneController,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Reference Fields
                          _buildSectionTitle('Reference Information'),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Reference *',
                                  _referenceController,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildTextField(
                                  'Reference 1 *',
                                  _reference1Controller,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Delivery Type
                          _buildSectionTitle('Delivery Method'),
                          const SizedBox(height: 16),
                          _buildDeliveryTypeSelector(),
                          const SizedBox(height: 24),
                          // Email Fields (shown when delivery_type is email)
                          if (_deliveryType == 'email') ...[
                            _buildSectionTitle('Email Details'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Email Subject',
                              _emailSubjectController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Email Body',
                              _emailBodyController,
                              maxLines: 5,
                            ),
                            const SizedBox(height: 24),
                          ],
                          // SMS Fields (shown when delivery_type is sms)
                          if (_deliveryType == 'sms') ...[
                            _buildSectionTitle('SMS Details'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'SMS Body',
                              _smsBodyController,
                              maxLines: 5,
                            ),
                            const SizedBox(height: 24),
                          ],
                          // Invoice Information
                          _buildSectionTitle('Invoice Information'),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Invoice Currency *',
                                  _invoiceCurrencyController,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildTextField(
                                  'Invoice Amount *',
                                  _invoiceAmountController,
                                  keyboardType: TextInputType.number,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildDateField(
                                  'Invoice Valid From *',
                                  _invoiceValidFromController,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Tax Type *',
                                  _taxTypeController,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildTextField(
                                  'Tax Amount *',
                                  _taxAmountController,
                                  keyboardType: TextInputType.number,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildTextField(
                                  'Total Amount *',
                                  _totalAmountController,
                                  keyboardType: TextInputType.number,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Terms and Conditions
                          _buildTextField(
                            'Terms and Conditions',
                            _termsAndConditionsController,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 24),
                          // Status
                          _buildSectionTitle('Status'),
                          const SizedBox(height: 16),
                          _buildStatusSelector(),
                          const SizedBox(height: 32),
                          // Save Button
                          SizedBox(
                            width: 191,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6FAB23),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Save Payment Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Payment Links Table
                          _buildPaymentLinksTable(),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context) {
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
            'Payment Links',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212529),
              fontFamily: 'Poppins',
            ),
          ),
          Row(
            children: [
              Container(
                width: 300,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
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

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        TextButton(
          onPressed: () => context.go('/dashboard'),
          child: const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF0D6EFD),
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const Text(' / ', style: TextStyle(color: Color(0xFF6C757D))),
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6C757D),
            fontFamily: 'Poppins',
          ),
        ),
        const Text(' / ', style: TextStyle(color: Color(0xFF6C757D))),
        const Text(
          'Payment Links',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6C757D),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212529),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212529),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: 'Enter ${label.toLowerCase().replaceAll('*', '').trim()}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 12 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212529),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: 'Select date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
            ),
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text =
                  '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)}, ${date.year}';
            }
          },
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildDeliveryTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Email'),
            value: 'email',
            groupValue: _deliveryType,
            onChanged: (value) {
              setState(() {
                _deliveryType = value!;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('SMS'),
            value: 'sms',
            groupValue: _deliveryType,
            onChanged: (value) {
              setState(() {
                _deliveryType = value!;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _status,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: ['pending', 'sent', 'paid', 'expired', 'cancelled']
          .map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(status.toUpperCase()),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _status = value!;
        });
      },
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save logic with API call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment link saved successfully')),
      );
    }
  }

  Widget _buildPaymentLinksTable() {
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
                'Payment Links',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212529),
                  fontFamily: 'Poppins',
                ),
              ),
              IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Customer Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Reference',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows (Placeholder - will be populated from API)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 2, child: Text('John Doe')),
                    Expanded(flex: 2, child: Text('REF-001')),
                    Expanded(flex: 1, child: Text('\$100.00')),
                    Expanded(flex: 1, child: Text('Pending')),
                    Expanded(flex: 1, child: Icon(Icons.more_vert, size: 20)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
