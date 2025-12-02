// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Menu _$MenuFromJson(Map<String, dynamic> json) => Menu(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  icon: json['icon'] as String?,
  route: json['route'] as String?,
  path: json['path'] as String?,
  parentId: (json['parent_id'] as num?)?.toInt(),
  order: (json['order'] as num?)?.toInt(),
  isActive: json['is_active'] as bool,
  isVisible: json['is_visible'] as bool,
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => Menu.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'route': instance.route,
  'path': instance.path,
  'parent_id': instance.parentId,
  'order': instance.order,
  'is_active': instance.isActive,
  'is_visible': instance.isVisible,
  'children': instance.children,
};
