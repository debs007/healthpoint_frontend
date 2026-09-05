import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../models/coupon_summary.dart';
import '../../providers/coupon_provider.dart';
import 'coupon_products_screen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().loadGlobalCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offers & Coupons')),
      body: Consumer<CouponProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingGlobalCoupons && provider.globalCoupons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.globalCoupons.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadGlobalCoupons);
          }
          if (provider.globalCoupons.isEmpty) {
            return Center(child: Text('No offers available right now.', style: TextStyle(color: AppColors.textMuted)));
          }

          return RefreshIndicator(
            onRefresh: provider.loadGlobalCoupons,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.globalCoupons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _OfferCard(coupon: provider.globalCoupons[i]),
            ),
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.coupon});

  final CouponSummary coupon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CouponProductsScreen(couponId: coupon.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: Text(coupon.discountLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (coupon.description != null) ...[
                    const SizedBox(height: 3),
                    Text(coupon.description!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 4),
                  Text('${coupon.productCount} ${coupon.productCount == 1 ? 'product' : 'products'} eligible', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
