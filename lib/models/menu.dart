import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

@JsonSerializable()
class Menu {
  final int id;
  final String name;
  final String? icon;
  final String? route;
  final String? path;
  
  @JsonKey(name: 'parent_id')
  final int? parentId;
  
  final int? order;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'is_visible')
  final bool isVisible;
  
  final List<Menu>? children;

  Menu({
    required this.id,
    required this.name,
    this.icon,
    this.route,
    this.path,
    this.parentId,
    this.order,
    required this.isActive,
    required this.isVisible,
    this.children,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);

  Map<String, dynamic> toJson() => _$MenuToJson(this);
}

