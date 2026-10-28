import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IndrisNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAccountTap;

  const IndrisNavBar({super.key, this.onAccountTap});

  static const _navItems = [
    'HOME',
    'COLLECTIONS',
    'WORK',
    'SERVICES',
    'ABOUT',
    'CONTACT',
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // Logo
              Text('Indris', style: logoStyle()),
              const Spacer(),

              // Center nav links (wide screens only)
              if (isWide)
                Row(
                  children: _navItems
                      .map((label) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(label, style: navStyle()),
                          ))
                      .toList(),
                ),

              if (isWide) const Spacer(),

              // Account icon
              IconButton(
                icon: const Icon(Icons.person_outline, color: AppColors.black),
                onPressed: onAccountTap,
              ),

              // Hamburger for small screens
              if (!isWide)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.black),
                    onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

/// Drawer shown on narrow screens, mirrors the same nav items
class IndrisEndDrawer extends StatelessWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;

  const IndrisEndDrawer({
    super.key,
    required this.onLoginTap,
    required this.onSignupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            Text('Indris', style: logoStyle()),
            const SizedBox(height: 24),
            ...IndrisNavBar._navItems.map(
              (label) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(label, style: navStyle(size: 14)),
              ),
            ),
            const Divider(height: 40, color: AppColors.border),
            TextButton(
              onPressed: onLoginTap,
              child: Text('LOGIN', style: navStyle(size: 14)),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onSignupTap,
              child: const Text('SIGN UP'),
            ),
          ],
        ),
      ),
    );
  }
}
