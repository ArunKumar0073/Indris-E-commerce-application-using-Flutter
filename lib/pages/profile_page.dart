import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/wishlist_service.dart';
import '../services/order_service.dart';
import 'orders_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoading = true;

  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final data = await AuthService.instance.getUserProfile(user.uid);
    if (!mounted) return;
    setState(() {
      _profile = data;
      _nameController.text = data?['fullName'] ?? user.displayName ?? '';
      _phoneController.text = data?['phone'] ?? '';
      _bioController.text = data?['bio'] ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    setState(() => _isSaving = true);
    try {
      await AuthService.instance.updateUserProfile(
        uid: user.uid,
        fullName: _nameController.text,
        phone: _phoneController.text,
        bio: _bioController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: AppColors.green),
      );
      setState(() => _isEditing = false);
      await _loadProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out', style: headingStyle(size: 18)),
        content: Text('Are you sure you want to sign out?',
            style: bodyStyle(size: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style:
                      navStyle(size: 13, color: AppColors.textGrey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sign Out',
                  style:
                      navStyle(size: 13, color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Indris', style: logoStyle(size: 22)),
        centerTitle: false,
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.green),
              label: Text('Edit',
                  style: navStyle(size: 13, color: AppColors.green)),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                _loadProfile();
              },
              child: Text('Cancel',
                  style: navStyle(
                      size: 13, color: AppColors.textGrey)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.green))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar ──────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: AppColors.cream,
                              child: Text(
                                _initials(_profile?['fullName'] ??
                                    user?.displayName ??
                                    'U'),
                                style: headingStyle(
                                    size: 28,
                                    color: AppColors.green),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _profile?['fullName'] ??
                                  user?.displayName ??
                                  'User',
                              style: headingStyle(size: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(user?.email ?? '',
                                style: bodyStyle(size: 13)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Quick stats ──────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.receipt_long_outlined,
                              label: 'Orders',
                              stream: OrderService.instance.ordersStream
                                  .map((o) => o.length),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const OrdersPage()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.favorite_border_rounded,
                              label: 'Wishlist',
                              stream: WishlistService
                                  .instance.countStream,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 16),

                      // ── Account info ─────────────────────────
                      const _SectionLabel('ACCOUNT INFO'),
                      const SizedBox(height: 12),
                      _InfoTile(
                        icon: Icons.fingerprint_outlined,
                        label: 'User ID',
                        value: user?.uid ?? '—',
                        mono: true,
                      ),
                      const SizedBox(height: 8),
                      _TokenTile(user: user),

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 16),

                      // ── Profile form ─────────────────────────
                      const _SectionLabel('PROFILE DETAILS'),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Full Name'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              enabled: _isEditing,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                  hintText: 'Your full name'),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Name cannot be empty'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            const _FieldLabel('Phone Number'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _phoneController,
                              enabled: _isEditing,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                  hintText: '+91 00000 00000'),
                            ),
                            const SizedBox(height: 16),
                            const _FieldLabel('Bio'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _bioController,
                              enabled: _isEditing,
                              maxLines: 3,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                  hintText:
                                      'Tell us about yourself'),
                            ),
                            const SizedBox(height: 24),
                            if (_isEditing)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : _saveProfile,
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child:
                                              CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color:
                                                      Colors.white))
                                      : const Text('SAVE CHANGES'),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Orders shortcut ──────────────────────
                      _MenuTile(
                        icon: Icons.receipt_long_outlined,
                        label: 'My Orders',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrdersPage()),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.favorite_border_rounded,
                        label: 'My Wishlist',
                        onTap: () {},
                      ),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () {},
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 16),

                      // ── Sign out ─────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded,
                              size: 16, color: Colors.redAccent),
                          label: Text('SIGN OUT',
                              style: navStyle(
                                  size: 13,
                                  color: Colors.redAccent,
                                  weight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: navStyle(size: 11.5, color: AppColors.green));
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: navStyle(size: 12.5, weight: FontWeight.w600));
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool mono;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: navStyle(
                        size: 11, color: AppColors.textGrey)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: mono
                      ? bodyStyle(size: 11.5, color: AppColors.black)
                          .copyWith(
                              fontFamily: 'monospace',
                              letterSpacing: 0.3)
                      : bodyStyle(size: 13, color: AppColors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenTile extends StatefulWidget {
  final User? user;
  const _TokenTile({required this.user});

  @override
  State<_TokenTile> createState() => _TokenTileState();
}

class _TokenTileState extends State<_TokenTile> {
  String _token = 'Loading…';
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final t = await AuthService.instance.getStoredToken();
    if (!mounted) return;
    setState(() => _token = t ?? '—');
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    final t = await AuthService.instance.refreshToken();
    if (!mounted) return;
    setState(() {
      _token = t ?? '—';
      _refreshing = false;
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JWT token refreshed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview =
        _token.length > 60 ? '${_token.substring(0, 60)}…' : _token;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.token_outlined,
                  size: 18, color: AppColors.green),
              const SizedBox(width: 10),
              Text('JWT Token',
                  style:
                      navStyle(size: 11, color: AppColors.textGrey)),
              const Spacer(),
              GestureDetector(
                onTap: _refreshing ? null : _refresh,
                child: _refreshing
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.green))
                    : const Icon(Icons.refresh_rounded,
                        size: 16, color: AppColors.green),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(preview,
              style: bodyStyle(size: 10.5, color: AppColors.textGrey)
                  .copyWith(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Stream<int> stream;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.stream,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.green),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: stream,
              builder: (_, snap) => Text(
                '${snap.data ?? 0}',
                style: headingStyle(size: 22),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: bodyStyle(size: 12)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style:
                      navStyle(size: 13.5, weight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
