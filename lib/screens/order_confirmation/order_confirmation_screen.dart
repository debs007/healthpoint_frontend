import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/order.dart';
import '../main_shell.dart';

/// Replaces the small dialog that used to show after payment success.
/// Every figure here is real (subtotal/discount/tax/delivery all confirmed
/// as genuinely separate fields on the actual OrderResource) - there's no
/// "delivered to [address]" section like the original design mockup had,
/// because the backend's order response doesn't actually include a
/// delivery address anywhere. Not fabricating one just to match the
/// reference visually.
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Thank you for shopping with ${AppConstants.appName}',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(order.displayId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(dateFormat.format(order.placedAt), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (order.franchiseName != null) ...[
              _InfoRow(label: 'Ordering from', value: order.franchiseName!),
              const Divider(height: 28),
            ],
            _InfoRow(label: 'Fulfillment', value: order.fulfillmentType[0].toUpperCase() + order.fulfillmentType.substring(1)),
            const Divider(height: 28),
            const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.productName, style: const TextStyle(fontSize: 13))),
                      Text('x${item.quantity}', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 12),
                      Text('${AppConstants.currencySymbol}${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            _PriceRow(label: 'Subtotal', amount: order.subtotalAmount),
            if (order.discountAmount > 0) _PriceRow(label: 'Discount', amount: -order.discountAmount, isDiscount: true),
            if (order.taxAmount > 0) _PriceRow(label: 'Tax', amount: order.taxAmount),
            _PriceRow(
              label: 'Delivery Charges',
              amount: order.deliveryCharge,
              freeLabel: order.deliveryCharge == 0,
            ),
            const Divider(height: 24),
            _PriceRow(label: 'Total Amount', amount: order.totalAmount, isTotal: true),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can track this order any time from My Orders.',
                      style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                      (route) => false,
                    ),
                    child: const Text('Continue Shopping'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 2)),
                      (route) => false,
                    ),
                    child: const Text('Track Order'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isDiscount = false,
    this.freeLabel = false,
  });

  final String label;
  final double amount;
  final bool isTotal;
  final bool isDiscount;
  final bool freeLabel;

  @override
  Widget build(BuildContext context) {
    final valueText = freeLabel
        ? 'FREE'
        : '${isDiscount ? '-' : ''}${AppConstants.currencySymbol}${amount.abs().toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.primary : (isDiscount ? AppColors.success : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
