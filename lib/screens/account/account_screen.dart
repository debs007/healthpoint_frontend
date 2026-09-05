import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/widgets/app_icon.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wallet_provider.dart';
import '../address_book/address_book_screen.dart';
import '../auth/login_screen.dart';
import '../edit_profile/edit_profile_screen.dart';
import '../prescriptions/prescriptions_screen.dart';
import '../wallet/wallet_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      if (provider.orders.isEmpty) provider.loadOrders();
      context.read<WalletProvider>().loadWallet();
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You\'ll need your mobile number and a new OTP to sign back in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final orders = context.watch<OrderProvider>().orders;

    final pendingCount = orders.where((o) => o.status == 'pending_payment').length;
    final shippedCount = orders.where((o) => o.status == 'out_for_delivery').length;
    final deliveredCount = orders.where((o) => o.status == 'delivered' || o.status == 'picked_up').length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.profileImageUrl != null ? NetworkImage(user!.profileImageUrl!) : null,
                    child: user?.profileImageUrl == null ? const Icon(Icons.person, color: AppColors.primary, size: 30) : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('+91 ${user?.mobile ?? ''}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        if (user?.email != null)
                          Text(user!.email!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WalletScreen()),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        AppIcon(AppIcons.wallet, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Consumer<WalletProvider>(
                            builder: (context, walletProvider, _) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Susthayan Wallet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(
                                  '${AppConstants.currencySymbol}${walletProvider.wallet.balance.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _ComingSoonTile(icon: AppIcons.coupon, label: 'My Coupons')),
            ],
          ),
          const SizedBox(height: 20),
          const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Expanded(child: _StatColumn(label: 'All Orders', value: '${orders.length}')),
                Expanded(child: _StatColumn(label: 'Pending', value: '$pendingCount')),
                Expanded(child: _StatColumn(label: 'Shipped', value: '$shippedCount')),
                Expanded(child: _StatColumn(label: 'Delivered', value: '$deliveredCount')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: AppIcons.prescriptionDoc,
            label: 'My Prescriptions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrescriptionsScreen()),
            ),
          ),
          _MenuTile(
            icon: AppIcons.addressBook,
            label: 'Address Book',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddressBookScreen()),
            ),
          ),
          _ComingSoonMenuTile(icon: AppIcons.paymentMethods, label: 'Payment Methods'),
          _ComingSoonMenuTile(icon: AppIcons.reminders, label: 'Medicine Reminders'),
          _ComingSoonMenuTile(icon: AppIcons.reviews, label: 'My Reviews'),
          _ComingSoonMenuTile(icon: AppIcons.referEarn, label: 'Refer & Earn'),
          _MenuTile(
            icon: AppIcons.helpSupport,
            label: 'Help & Support',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No help/support endpoint exists in the API yet')),
            ),
          ),
          _MenuTile(icon: AppIcons.logout, label: 'Logout', onTap: _confirmLogout, isDestructive: true),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AppIcon(icon, color: isDestructive ? AppColors.error : AppColors.primary, size: 22),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: AppIcon(AppIcons.chevronRight, color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}

/// Wallet/coupons/payment-methods/reminders/reviews/refer-earn all have no
/// backend endpoint anywhere in the API - shown honestly as not-yet-built
/// rather than tappable UI that leads nowhere real.
class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          AppIcon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Coming soon', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonMenuTile extends StatelessWidget {
  const _ComingSoonMenuTile({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AppIcon(icon, color: AppColors.textMuted, size: 22),
      title: Text(label, style: TextStyle(color: AppColors.textMuted)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
        child: Text('Soon', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ),
      onTap: null,
    );
  }
}
