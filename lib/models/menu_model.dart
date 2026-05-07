// Simple Menu model (no code generation needed — parsed manually)
class MenuModel {
  final int id;
  final String name;
  final String icon;
  final String route;
  final String path;
  final int? parentId;
  final int order;
  final bool isActive;
  final bool isVisible;
  final List<int> userTypeIds;
  final List<MenuModel> children;
  final String? createdAt;

  MenuModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    required this.path,
    this.parentId,
    required this.order,
    required this.isActive,
    required this.isVisible,
    required this.userTypeIds,
    this.children = const [],
    this.createdAt,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final utList = (json['user_types'] as List<dynamic>? ?? []);
    final childList = (json['children'] as List<dynamic>? ?? []);
    return MenuModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      route: json['route'] as String? ?? '',
      path: json['path'] as String? ?? '',
      parentId: json['parent_id'] != null ? (json['parent_id'] as num).toInt() : null,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isVisible: json['is_visible'] == true || json['is_visible'] == 1,
      userTypeIds: utList.map((ut) => (ut['id'] as num).toInt()).toList(),
      children: childList.map((c) => MenuModel.fromJson(c as Map<String, dynamic>)).toList(),
      createdAt: json['created_at'] as String?,
    );
  }
}
