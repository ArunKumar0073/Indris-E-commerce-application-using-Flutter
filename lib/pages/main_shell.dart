import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/cart_service.dart';
import 'home_page.dart';
import 'collections_page.dart';
import 'work_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        HomePage(
          onProfileTap: () => setState(() => _currentIndex = 4),
          onCollectionsTap: () => setState(() => _currentIndex = 1),
          onCartTap: () => setState(() => _currentIndex = 3),
        ),
        const CollectionsPage(),
        const WorkPage(),
        const CartPage(),
        const ProfilePage(),
      ];

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Collections',
    ),
    _NavItem(
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      label: 'Work',
    ),
    _NavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Cart',
      isCart: true,
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _IndrisBottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ── Nav item model ────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isCart;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isCart = false,
  });
}

// ── Custom bottom nav bar ─────────────────────────────────────────────────────

class _IndrisBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _IndrisBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border:
            Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Active indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: isActive ? 20 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Icon — cart has badge
                        item.isCart
                            ? _CartIconWithBadge(
                                icon: isActive
                                    ? item.activeIcon
                                    : item.icon,
                                isActive: isActive,
                              )
                            : Icon(
                                isActive ? item.activeIcon : item.icon,
                                size: 22,
                                color: isActive
                                    ? AppColors.green
                                    : AppColors.textGrey,
                              ),

                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: navStyle(
                            size: 10,
                            color: isActive
                                ? AppColors.green
                                : AppColors.textGrey,
                            weight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Cart icon with live badge ─────────────────────────────────────────────────

class _CartIconWithBadge extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _CartIconWithBadge({required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: CartService.instance.cartCountStream,
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.green : AppColors.textGrey,
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                      minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
