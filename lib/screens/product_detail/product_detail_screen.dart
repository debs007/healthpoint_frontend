import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_images.dart';
import '../../core/network/api_exception.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';

/// Reached from tapping a product card anywhere in the app (Home, product
/// lists, search/category results). Fetches the single-product endpoint
/// fresh rather than trusting whatever summary data got tapped, since a
/// list response may not include everything this screen shows (full
/// description, salt composition) and stock/price can have moved on since
/// the list was loaded.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _product = await context.read<ProductProvider>().getProduct(widget.productId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart() async {
    final cart = context.read<CartProvider>();
    final added = await cart.addItem(widget.productId, quantity: _quantity);

    if (!mounted) return;

    if (added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_product!.name} added to cart'),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ),
      );
    } else if (cart.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cart.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_product?.name ?? 'Product')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton(onPressed: _load, child: const Text('Try again')),
                      ],
                    ),
                  ),
                )
              : _buildContent(_product!),
      bottomNavigationBar: _product == null ? null : _buildBottomBar(_product!),
    );
  }

  Widget _buildContent(Product product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              color: AppColors.background,
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => _fallbackImage(product.id),
                    )
                  : _fallbackImage(product.id),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.prescriptionRequired)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined, size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text('Prescription required', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                Text(product.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                if (product.manufacturer != null) ...[
                  const SizedBox(height: 4),
                  Text('by ${product.manufacturer}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
                if (product.unit != null) ...[
                  const SizedBox(height: 2),
                  Text(product.unit!, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.sellingPrice != null
                          ? '${AppConstants.currencySymbol}${product.sellingPrice!.toStringAsFixed(2)}'
                          : 'Price unavailable',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${AppConstants.currencySymbol}${product.mrp!.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, color: AppColors.textMuted, decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(width: 6),
                      Text('${product.discountPercent}% off', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      product.inStock ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                      size: 16,
                      color: product.inStock ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.inStock ? 'In stock' : 'Out of stock',
                      style: TextStyle(fontSize: 13, color: product.inStock ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (product.description != null && product.description!.isNotEmpty) ...[
                  const Divider(height: 32),
                  const Text('About this product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(product.description!, style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5)),
                ],
                if (product.saltComposition != null && product.saltComposition!.isNotEmpty) ...[
                  const Divider(height: 32),
                  const Text('Salt composition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(product.saltComposition!, style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage(int productId) {
    final fallbacks = AppImages.productFallbacks;
    return Image.asset(fallbacks[productId % fallbacks.length], fit: BoxFit.contain);
  }

  Widget _buildBottomBar(Product product) {
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
            if (product.inStock) ...[
              Container(
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    SizedBox(width: 24, child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                    IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: product.inStock ? _addToCart : null,
                child: Text(product.inStock ? 'Add to Cart' : 'Out of Stock'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
