import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/menu_provider.dart';
import '../models/menu.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menusAsync = ref.watch(userMenusProvider);
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: 275,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                'http://localhost:3845/assets/b880c244f137ec15c47e1d315095ec8fea5e5cef.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.account_balance, size: 40);
                },
              ),
            ),
          ),
          // Menu Items
          Expanded(
            child: menusAsync.when(
              data: (menus) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    return _MenuItem(
                      menu: menu,
                      currentPath: currentPath,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading menus: $error'),
              ),
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Design: Vijeesh vijayan',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final Menu menu;
  final String currentPath;

  const _MenuItem({
    required this.menu,
    required this.currentPath,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand if any child is active
    if (widget.menu.children != null && widget.menu.children!.isNotEmpty) {
      _isExpanded = _hasActiveChild(widget.menu.children!, widget.currentPath);
    }
  }

  bool _hasActiveChild(List<Menu> children, String currentPath) {
    return children.any((child) {
      final isChildActive = currentPath == child.path ||
          currentPath == child.route ||
          (child.path != null && currentPath.startsWith(child.path!));
      return isChildActive || _hasActiveChild(child.children ?? [], currentPath);
    });
  }

  bool _isMenuActive(Menu menu, String currentPath) {
    // If path is "#", don't consider it active based on path matching
    if (menu.path == '#' || menu.route == '#') {
      // Only check if any child is active
      if (menu.children != null && menu.children!.isNotEmpty) {
        return _hasActiveChild(menu.children!, currentPath);
      }
      return false;
    }
    
    final isActive = currentPath == menu.path ||
        currentPath == menu.route ||
        (menu.path != null && currentPath.startsWith(menu.path!));
    
    // Also check if any child is active
    if (menu.children != null && menu.children!.isNotEmpty) {
      return isActive || _hasActiveChild(menu.children!, currentPath);
    }
    
    return isActive;
  }

  IconData _getIconForName(String? iconName) {
    if (iconName == null) return Icons.circle;
    
    switch (iconName.toLowerCase()) {
      case 'dashboard':
        return Icons.dashboard;
      case 'file-text':
        return Icons.description;
      case 'plus-circle':
        return Icons.add_circle;
      case 'list':
        return Icons.list;
      case 'users':
        return Icons.people;
      case 'settings':
        return Icons.settings;
      case 'menu':
        return Icons.menu;
      case 'user-check':
        return Icons.verified_user;
      case 'link':
        return Icons.link;
      default:
        return Icons.circle;
    }
  }

  void _handleMenuTap() {
    final menu = widget.menu;
    
    // If menu has children, only toggle expansion (don't navigate)
    if (menu.children != null && menu.children!.isNotEmpty) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
      // Don't navigate when clicking parent menu with children
      return;
    }
    
    // If path is "#", don't navigate (just a container menu)
    if (menu.path == '#' || menu.route == '#') {
      return;
    }
    
    // No children and path is not "#", navigate directly
    if (menu.path != null && menu.path != '#') {
      context.go(menu.path!);
    } else if (menu.route != null && menu.route != '#') {
      context.go(menu.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    final hasChildren = menu.children != null && menu.children!.isNotEmpty;
    final isActive = _isMenuActive(menu, widget.currentPath);

    return Column(
      children: [
        // Parent Menu Item
        InkWell(
          onTap: _handleMenuTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0D6EFD) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForName(menu.icon),
                  size: 16,
                  color: isActive ? Colors.white : const Color(0xFF495057),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    menu.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: isActive ? Colors.white : const Color(0xFF495057),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                if (hasChildren)
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: 20,
                    color: isActive ? Colors.white : const Color(0xFF495057),
                  ),
              ],
            ),
          ),
        ),
        // Children Menu Items
        if (hasChildren && _isExpanded)
          ...menu.children!.map((child) {
            final isChildActive = widget.currentPath == child.path ||
                widget.currentPath == child.route ||
                (child.path != null && widget.currentPath.startsWith(child.path!));
            
            return InkWell(
              onTap: () {
                if (child.path != null) {
                  context.go(child.path!);
                } else if (child.route != null) {
                  context.go(child.route!);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                padding: const EdgeInsets.only(left: 40, right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: isChildActive ? const Color(0xFF0D6EFD) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForName(child.icon),
                      size: 14,
                      color: isChildActive ? Colors.white : const Color(0xFF495057),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        child.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: isChildActive ? Colors.white : const Color(0xFF495057),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
