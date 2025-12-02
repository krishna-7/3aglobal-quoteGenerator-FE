// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserType _$UserTypeFromJson(Map<String, dynamic> json) => UserType(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$UserTypeToJson(UserType instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
