import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/grid_product_card.dart';
import '../../providers/coupon_provider.dart';

/// Reached by tapping a coupon-linked banner on Home or Categories. Same
/// GridProductCard as everywhere else - it already shows a struck-through
/// regular price next to the coupon price whenever couponPrice is present.
class CouponProductsScreen extends StatefulWidget {
  const CouponProductsScreen({super.key, required this.couponId});

  final int couponId;

  @override
  State<CouponProductsScreen> createState() => _CouponProductsScreenState();
}

class _CouponProductsScreenState extends State<CouponProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().loadProducts(widget.couponId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offer')),
      body: Consumer<CouponProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.products.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: () => provider.loadProducts(widget.couponId));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadProducts(widget.couponId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (provider.coupon != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                              child: Text(provider.coupon!.discountLabel, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Text(provider.coupon!.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        if (provider.coupon!.description != null) ...[
                          const SizedBox(height: 8),
                          Text(provider.coupon!.description!, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (provider.products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('No products currently available for this offer.', style: TextStyle(color: AppColors.textMuted))),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, i) => GridProductCard(product: provider.products[i]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
