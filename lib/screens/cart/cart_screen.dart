import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/cart_item.dart';
import '../../models/franchise.dart';
import '../../providers/cart_provider.dart';
import '../../providers/franchise_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  Future<void> _showFranchisePicker(BuildContext context) async {
    final franchiseProvider = context.read<FranchiseProvider>();
    if (franchiseProvider.franchises.isEmpty) {
      await franchiseProvider.loadFranchises();
    }

    if (!context.mounted) return;

    final selected = await showModalBottomSheet<Franchise>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer<FranchiseProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage != null) {
              return Center(child: Text(provider.errorMessage!));
            }
            if (provider.franchises.isEmpty) {
              return const Center(child: Text('No stores available right now.'));
            }
            return ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.franchises.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Select a store', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                }
                final franchise = provider.franchises[i - 1];
                return ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  leading: Icon(Icons.storefront_outlined, color: AppColors.primary),
                  title: Text(franchise.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: franchise.locationLabel.isNotEmpty ? Text(franchise.locationLabel) : null,
                  onTap: () => Navigator.pop(context, franchise),
                );
              },
            );
          },
        ),
      ),
    );

    if (selected != null && context.mounted) {
      final success = await context.read<CartProvider>().selectFranchise(selected.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Ordering from ${selected.name}' : 'Couldn\'t select that store - try again')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          final cart = cartProvider.cart;

          if (cartProvider.isLoading && cart.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('Your cart is empty', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'Add medicines from the home screen to see them here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              if (!cart.hasFranchiseSelected)
                _StoreSelectionBanner(onTap: () => _showFranchisePicker(context)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: cartProvider.loadCart,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _CartItemTile(item: cart.items[i]),
                  ),
                ),
              ),
              _CheckoutBar(subtotal: cart.subtotal, enabled: cart.hasFranchiseSelected),
            ],
          );
        },
      ),
    );
  }
}

class _StoreSelectionBanner extends StatelessWidget {
  const _StoreSelectionBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: AppColors.warning.withValues(alpha: 0.12),
        child: Row(
          children: [
            Icon(Icons.storefront_outlined, size: 18, color: AppColors.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No store selected yet - prices below are unresolved. Tap to choose one.',
                style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.medication_outlined, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  item.unitPrice != null
                      ? '${AppConstants.currencySymbol}${item.unitPrice!.toStringAsFixed(2)}'
                      : 'Select a store to see price',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.unitPrice != null ? AppColors.textSecondary : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          _QuantityStepper(item: item),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Row(
      children: [
        _StepButton(icon: Icons.remove, onTap: () => cart.updateQuantity(item.id, item.quantity - 1)),
        SizedBox(width: 28, child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
        _StepButton(icon: Icons.add, onTap: () => cart.updateQuantity(item.id, item.quantity + 1)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.subtotal, required this.enabled});

  final double subtotal;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subtotal', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('${AppConstants.currencySymbol}${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: enabled
                  ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()))
                  : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
              child: const Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
