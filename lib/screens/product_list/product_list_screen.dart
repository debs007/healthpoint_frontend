import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/grid_product_card.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

/// One reusable list screen for every "show me some products" entry point -
/// a category tap, a brand tap, a search, or "View All" (no filter,
/// everything). Same product card, same tap-to-detail behavior, same
/// add-to-cart, regardless of how the list was reached.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.categoryId, this.categoryName, this.brandId, this.brandName, this.searchQuery});

  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;
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
        : widget.brandId != null
            ? await provider.byBrand(widget.brandId!)
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
    if (widget.brandName != null) return widget.brandName!;
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
                    itemBuilder: (context, i) => GridProductCard(product: _products![i]),
                  ),
                ),
    );
  }
}
