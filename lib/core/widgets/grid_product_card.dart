import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_images.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../screens/product_detail/product_detail_screen.dart';

/// Extracted from ProductListScreen's original private _GridProductCard -
/// CategoriesScreen needed the identical card for its own product grid,
/// and a `_`-prefixed class can't cross files in Dart, so this became a
/// shared widget rather than a second near-duplicate copy.
class GridProductCard extends StatelessWidget {
  const GridProductCard({super.key, required this.product});

  final Product product;

  Widget _fallbackImage() {
    final fallbacks = AppImages.productFallbacks;
    return Image.asset(fallbacks[product.id % fallbacks.length], fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: Container(
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl != null
                      ? Image.network(product.imageUrl!, fit: BoxFit.contain, errorBuilder: (context, error, stack) => _fallbackImage())
                      : _fallbackImage(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            if (product.unit != null) Text(product.unit!, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            if (product.couponPrice != null && product.sellingPrice != null)
              Row(
                children: [
                  Text('${AppConstants.currencySymbol}${product.couponPrice!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.success)),
                  const SizedBox(width: 5),
                  Text(
                    '${AppConstants.currencySymbol}${product.sellingPrice!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, decoration: TextDecoration.lineThrough),
                  ),
                ],
              )
            else
              Text(
                product.sellingPrice != null ? '${AppConstants.currencySymbol}${product.sellingPrice!.toStringAsFixed(2)}' : 'Price unavailable',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: product.inStock
                    ? () async {
                        final added = await context.read<CartProvider>().addItem(product.id);
                        if (context.mounted && added) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} added to cart'), duration: const Duration(seconds: 1)),
                          );
                        }
                      }
                    : null,
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(34), padding: EdgeInsets.zero, textStyle: const TextStyle(fontSize: 12)),
                child: Text(product.inStock ? 'ADD TO CART' : 'OUT OF STOCK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
