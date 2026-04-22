import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/shared_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated || auth.user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: EmptyState(icon: Icons.person_outline, title: 'Sign in to your account', buttonText: 'Sign In', onButtonTap: () => Navigator.of(context).pushNamed('/login')),
      );
    }
    final user = auth.user!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Container(
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 32),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2A4F2A), Color(0xFF3B5D3B)])),
            child: Column(children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15), border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)),
                child: Center(child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)))),
              const SizedBox(height: 16),
              Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text(user.email, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star_rounded, size: 16, color: AppColors.starYellow), const SizedBox(width: 4),
                  Text('${user.loyaltyTier} Member', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white))])),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _buildMenu(context, 'My Account', [
              _tile(Icons.receipt_long_outlined, 'My Orders', () => Navigator.of(context).pushNamed('/orders')),
              _tile(Icons.favorite_border, 'Wishlist', () => Navigator.of(context).pushNamed('/wishlist')),
              _tile(Icons.location_on_outlined, 'Addresses', () {}),
            ]),
            const SizedBox(height: 16),
            _buildMenu(context, 'Settings', [
              _tile(Icons.lock_outline, 'Change Password', () {}),
              _tile(Icons.help_outline, 'Help Center', () {}),
            ]),
            const SizedBox(height: 24),
            VedashiButton(text: 'Sign Out', isOutlined: true, icon: Icons.logout, onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) Navigator.of(context).pushReplacementNamed('/login');
            }),
            const SizedBox(height: 32),
          ]))),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context, String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 16))),
      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
        child: Column(children: items)),
    ]);
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: AppColors.primary)),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
