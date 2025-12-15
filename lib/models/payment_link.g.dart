// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentLink _$PaymentLinkFromJson(Map<String, dynamic> json) => PaymentLink(
  id: (json['id'] as num).toInt(),
  customerName: json['customer_name'] as String,
  reference: json['reference'] as String,
  reference1: json['reference_1'] as String,
  deliveryType: json['delivery_type'] as String,
  customerEmail: json['customer_email'] as String,
  customerPhone: json['customer_phone'] as String?,
  emailSubject: json['email_subject'] as String?,
  emailBody: json['email_body'] as String?,
  emailFilePath: json['email_file_path'] as String?,
  smsBody: json['sms_body'] as String?,
  status: json['status'] as String,
  invoiceCurrency: json['invoice_currency'] as String,
  invoiceAmount: json['invoice_amount'] as String,
  taxType: json['tax_type'] as String,
  taxAmount: json['tax_amount'] as String,
  totalAmount: json['total_amount'] as String,
  invoiceValidFrom: json['invoice_valid_from'] as String,
  termsAndConditions: json['terms_and_conditions'] as String?,
  paymentLinkUrl: json['payment_link_url'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PaymentLinkToJson(PaymentLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_name': instance.customerName,
      'reference': instance.reference,
      'reference_1': instance.reference1,
      'delivery_type': instance.deliveryType,
      'customer_email': instance.customerEmail,
      'customer_phone': instance.customerPhone,
      'email_subject': instance.emailSubject,
      'email_body': instance.emailBody,
      'email_file_path': instance.emailFilePath,
      'sms_body': instance.smsBody,
      'status': instance.status,
      'invoice_currency': instance.invoiceCurrency,
      'invoice_amount': instance.invoiceAmount,
      'tax_type': instance.taxType,
      'tax_amount': instance.taxAmount,
      'total_amount': instance.totalAmount,
      'invoice_valid_from': instance.invoiceValidFrom,
      'terms_and_conditions': instance.termsAndConditions,
      'payment_link_url': instance.paymentLinkUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
