import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_exception.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../address_book/address_book_screen.dart';
import '../payment/payment_screen.dart';

/// Delivery-only, deliberately - this app is built for a single-location
/// consumer business, not a multi-fulfillment marketplace. There's no
/// "pickup at the store" option here since that's not how this business
/// operates; every order gets delivered to an address. If a pickup option
/// is ever genuinely needed later, that's a real feature to design, not
/// something quietly disabled here.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _selectedAddress;
  bool _placingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = context.read<AddressProvider>();
      addressProvider.loadAddresses().then((_) {
        if (mounted && addressProvider.addresses.isNotEmpty) {
          setState(() {
            _selectedAddress = addressProvider.addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addressProvider.addresses.first,
            );
          });
        }
      });
    });
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();

    // The cart's franchise comes from the server - either auto-selected
    // when there's a single active store, or picked by the customer on
    // the Cart screen when there's more than one. If it's genuinely
    // missing here, that's a real, honest gap to surface rather than
    // guess at.
    if (cart.cart.franchiseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No store is associated with this cart yet - go back to your cart to select one.')),
      );
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a delivery address first')),
      );
      return;
    }

    setState(() => _placingOrder = true);

    try {
      final order = await context.read<OrderProvider>().placeOrder(
            franchiseId: cart.cart.franchiseId!,
            fulfillmentType: 'delivery',
            addressId: _selectedAddress!.id,
          );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PaymentScreen(order: order)),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Deliver to', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              TextButton(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressBookScreen()));
                  if (mounted) context.read<AddressProvider>().loadAddresses();
                },
                child: const Text('Manage'),
              ),
            ],
          ),
          Consumer<AddressProvider>(
            builder: (context, provider, _) {
              if (provider.addresses.isEmpty) {
                return Text('No saved addresses - add one to deliver here.', style: TextStyle(color: AppColors.textMuted));
              }
              return Column(
                children: provider.addresses.map((address) {
                  final selected = _selectedAddress?.id == address.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedAddress = address),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: address.id,
                              groupValue: _selectedAddress?.id,
                              onChanged: (_) => setState(() => _selectedAddress = address),
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(address.label ?? 'Address', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text('${address.line1}, ${address.shortLabel}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Items (${cart.itemCount})', style: TextStyle(color: AppColors.textSecondary)),
                    Text('${AppConstants.currencySymbol}${cart.cart.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${AppConstants.currencySymbol}${cart.cart.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Delivery charges and taxes, if any, are calculated by the server when the order is placed.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _placingOrder ? null : _placeOrder,
            child: _placingOrder
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Place Order'),
          ),
        ),
      ),
    );
  }
}
