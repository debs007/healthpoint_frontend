import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_images.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../product_detail/product_detail_screen.dart';

/// One reusable list screen for every "show me some products" entry point -
/// a category tap, a search, or "View All" (no filter, everything). Same
/// product card, same tap-to-detail behavior, same add-to-cart, regardless
/// of how the list was reached.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.categoryId, this.categoryName, this.searchQuery});

  final int? categoryId;
  final String? categoryName;
  final String? searchQuery;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product>? _products;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final provider = context.read<ProductProvider>();
    final results = widget.categoryId != null
        ? await provider.byCategory(widget.categoryId!)
        : widget.searchQuery != null
            ? await provider.search(widget.searchQuery!)
            : provider.products;

    if (!mounted) return;
    setState(() {
      _products = results;
      _isLoading = false;
    });
  }

  String get _title {
    if (widget.categoryName != null) return widget.categoryName!;
    if (widget.searchQuery != null) return '"${widget.searchQuery}"';
    return 'All Products';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_products == null || _products!.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      widget.searchQuery != null ? 'No products match "${widget.searchQuery}".' : 'No products found here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products!.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, i) => _GridProductCard(product: _products![i]),
                  ),
                ),
    );
  }
}

class _GridProductCard extends StatelessWidget {
  const _GridProductCard({required this.product});

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
