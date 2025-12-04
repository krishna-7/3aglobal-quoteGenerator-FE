import 'package:json_annotation/json_annotation.dart';

part 'payment_link.g.dart';

@JsonSerializable()
class PaymentLink {
  final int id;
  
  @JsonKey(name: 'customer_name')
  final String customerName;
  
  final String reference;
  
  @JsonKey(name: 'reference_1')
  final String reference1;
  
  @JsonKey(name: 'delivery_type')
  final String deliveryType; // 'email' or 'sms'
  
  @JsonKey(name: 'customer_email')
  final String customerEmail;
  
  @JsonKey(name: 'customer_phone')
  final String? customerPhone;
  
  @JsonKey(name: 'email_subject')
  final String? emailSubject;
  
  @JsonKey(name: 'email_body')
  final String? emailBody;
  
  @JsonKey(name: 'email_file_path')
  final String? emailFilePath;
  
  @JsonKey(name: 'sms_body')
  final String? smsBody;
  
  final String status;
  
  @JsonKey(name: 'invoice_currency')
  final String invoiceCurrency;
  
  @JsonKey(name: 'invoice_amount')
  final String invoiceAmount;
  
  @JsonKey(name: 'tax_type')
  final String taxType;
  
  @JsonKey(name: 'tax_amount')
  final String taxAmount;
  
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  
  @JsonKey(name: 'invoice_valid_from')
  final String invoiceValidFrom;
  
  @JsonKey(name: 'terms_and_conditions')
  final String? termsAndConditions;
  
  @JsonKey(name: 'payment_link_url')
  final String? paymentLinkUrl;
  
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  PaymentLink({
    required this.id,
    required this.customerName,
    required this.reference,
    required this.reference1,
    required this.deliveryType,
    required this.customerEmail,
    this.customerPhone,
    this.emailSubject,
    this.emailBody,
    this.emailFilePath,
    this.smsBody,
    required this.status,
    required this.invoiceCurrency,
    required this.invoiceAmount,
    required this.taxType,
    required this.taxAmount,
    required this.totalAmount,
    required this.invoiceValidFrom,
    this.termsAndConditions,
    this.paymentLinkUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentLink.fromJson(Map<String, dynamic> json) =>
      _$PaymentLinkFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentLinkToJson(this);
}


