import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:susthayan/models/cart.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cartProvider = context.read<CartProvider>();
      await cartProvider.loadCart();
      if (!mounted || cartProvider.cart.hasFranchiseSelected) return;

      // Single-store businesses shouldn't ever see a "select a store"
      // step at all - there's nothing to actually choose. This only
      // silently auto-picks when there is exactly one active franchise;
      // with two or more, the picker below still shows normally, since
      // that's a genuine choice for the customer to make.
      final franchiseProvider = context.read<FranchiseProvider>();
      await franchiseProvider.loadFranchises();
      if (!mounted) return;
      if (franchiseProvider.franchises.length == 1) {
        await cartProvider.selectFranchise(franchiseProvider.franchises.first.id);
      }
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
              const _CouponSection(),
              _CheckoutBar(cart: cart, enabled: cart.hasFranchiseSelected),
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

class _CouponSection extends StatefulWidget {
  const _CouponSection();

  @override
  State<_CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<_CouponSection> {
  final _controller = TextEditingController();
  bool _isApplying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplying = true);
    final cartProvider = context.read<CartProvider>();
    final success = await cartProvider.applyCoupon(code);
    if (!mounted) return;
    setState(() => _isApplying = false);

    if (success) {
      _controller.clear();
    } else if (cartProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cartProvider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;

    if (cart.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: cart.coupon != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"${cart.coupon!.code}" applied',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.read<CartProvider>().removeCoupon(),
                    child: Text('Remove', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Enter coupon code',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _isApplying ? null : _apply,
                    child: _isApplying
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Apply'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart, required this.enabled});

  final Cart cart;
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
                  Text(cart.coupon != null ? 'Total (after discount)' : 'Subtotal', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('${AppConstants.currencySymbol}${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (cart.coupon != null)
                    Text(
                      'You saved ${AppConstants.currencySymbol}${cart.coupon!.discountAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.success, fontWeight: FontWeight.w600),
                    ),
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
