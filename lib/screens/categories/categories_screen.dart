import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_images.dart';
import '../../core/widgets/count_badge.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/grid_product_card.dart';
import '../../core/widgets/promo_carousel.dart';
import '../../models/category.dart';
import '../../providers/brand_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/home_banner_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../coupon/coupon_products_screen.dart';
import '../product_list/product_list_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.categories.isEmpty) provider.loadHomeData();
      context.read<BrandProvider>().loadBrands();
      context.read<HomeBannerProvider>().loadBanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          Consumer<CartProvider>(
            builder: (context, cart, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
                if (cart.itemCount > 0)
                  Positioned(right: 6, top: 6, child: CountBadge(count: cart.itemCount)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.categories.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadHomeData);
          }

          final categories = provider.categories;

          return RefreshIndicator(
            onRefresh: provider.loadHomeData,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Browse medicines & healthcare products', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<HomeBannerProvider>(
                    builder: (context, bannerProvider, _) {
                      if (bannerProvider.banners.isEmpty) return const SizedBox.shrink();

                      return PromoCarousel(
                        banners: bannerProvider.banners,
                        onButtonPressed: (banner) {
                          if (banner.couponId != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CouponProductsScreen(couponId: banner.couponId!)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('This banner isn\'t linked to an offer yet')),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text('Shop by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                if (categories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Text(
                      'No categories yet - they\'re derived from the live product catalog, '
                      'so this fills in as products are added.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, i) => _CategoryTile(category: categories[i]),
                    ),
                  ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Top Brands', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      InkWell(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No dedicated brands page exists yet - see Home for the full catalog')),
                        ),
                        child: Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _TopBrandsRow(),
                const SizedBox(height: 24),
                if (provider.products.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('You May Like', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProductListScreen()),
                          ),
                          child: Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.products.length > 10 ? 10 : provider.products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, i) => GridProductCard(product: provider.products[i]),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Maps a real category name to the closest available real asset by
/// keyword, falling back to a generic Material icon when nothing matches -
/// live category names come from whatever the backend catalog actually
/// has, which won't always line up with one of the assets provided so far.
IconData _fallbackIconFor(String name) {
  final n = name.toLowerCase();
  if (n.contains('lab') || n.contains('test')) return Icons.add_box_outlined;
  if (n.contains('first aid') || n.contains('bandage')) return Icons.healing_outlined;
  if (n.contains('eye')) return Icons.visibility_outlined;
  if (n.contains('oral') || n.contains('dental')) return Icons.sentiment_satisfied_outlined;
  if (n.contains('skin')) return Icons.face_retouching_natural_outlined;
  if (n.contains('ayurved')) return Icons.grass_outlined;
  if (n.contains('pet')) return Icons.pets_outlined;
  if (n.contains('personal care')) return Icons.spa_outlined;
  if (n.contains('device')) return Icons.favorite_border_rounded;
  return Icons.category_outlined;
}

String? _realAssetFor(String name) {
  final n = name.toLowerCase();
  if (n.contains('medic')) return AppImages.homeIcons[AppIcons.categoryMedicines];
  if (n.contains('supplement') || (n.contains('health') && !n.contains('device'))) {
    return AppImages.homeIcons[AppIcons.categoryHealthcare];
  }
  if (n.contains('mother') || n.contains('baby')) return AppImages.homeIcons[AppIcons.categoryMotherBaby];
  if (n.contains('fitness') || n.contains('nutrition')) return AppImages.homeIcons[AppIcons.categoryFitness];
  if (n.contains('lab') || n.contains('test')) return AppImages.homeIcons[AppIcons.categoryLabTests];
  return null;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final realAsset = _realAssetFor(category.name);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductListScreen(categoryId: category.id, categoryName: category.name)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(color: AppColors.surfaceTint, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: realAsset != null
                ? Image.asset(realAsset, width: 34, height: 34)
                : Icon(_fallbackIconFor(category.name), color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.15),
            ),
          ),
          if (category.productCount != null)
            Text('(${category.productCount}+)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// Text-only, deliberately. Dabur/Himalaya/Zandu/Revital etc. are real,
/// trademarked brand logos - no assets for these exist in anything
/// provided so far, and approximating them (even loosely) isn't
/// appropriate. This matches the row LAYOUT from the design without
/// fabricating logos that would need to be the real, licensed artwork.
class _TopBrandsRow extends StatelessWidget {
  const _TopBrandsRow();

  @override
  Widget build(BuildContext context) {
    return Consumer<BrandProvider>(
      builder: (context, brandProvider, _) {
        if (brandProvider.isLoading && brandProvider.brands.isEmpty) {
          return const SizedBox(height: 88, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        if (brandProvider.brands.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: brandProvider.brands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final brand = brandProvider.brands[i];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProductListScreen(brandId: brand.id, brandName: brand.name)),
                ),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: brand.logoUrl != null
                            ? ClipOval(child: Image.network(brand.logoUrl!, fit: BoxFit.contain, errorBuilder: (context, error, stack) => _brandInitial(brand.name)))
                            : _brandInitial(brand.name),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        brand.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Fallback when a brand has no logo yet (or its URL fails to load) -
  /// the brand's own initial rather than a generic broken-image icon.
  Widget _brandInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}
