import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_images.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/count_badge.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/promo_carousel.dart';
import '../../models/category.dart';
import '../../models/health_article.dart';
import '../../models/product.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/health_article_provider.dart';
import '../../providers/home_banner_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../coupon/coupon_products_screen.dart';
import '../coupon/offers_screen.dart';
import '../lab_tests/lab_tests_screen.dart';
import '../notifications/notifications_screen.dart';
import '../prescriptions/prescriptions_screen.dart';
import '../product_detail/product_detail_screen.dart';
import '../product_list/product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Each load runs independently now - previously these were
    // sequentially awaited in a single chain, so an exception thrown
    // anywhere in loadHomeData()/loadCategoryRows() (e.g. a single
    // malformed product) would silently prevent every load after it in
    // this callback from ever running at all - address, banners, and
    // health articles included, even though none of them were actually
    // related to the failure. Each one now fails on its own, if it fails
    // at all, and never takes any other section down with it.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productProvider = context.read<ProductProvider>();
      try {
        await productProvider.loadHomeData();
        if (mounted) await productProvider.loadCategoryRows();
      } catch (_) {
        // Already-empty state is the safe fallback here - the sections
        // below must still get their chance to load regardless.
      }
      context.read<AddressProvider>().loadAddresses();
      context.read<HomeBannerProvider>().loadBanners();
      context.read<HealthArticleProvider>().loadArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Consumer<AddressProvider>(
          builder: (context, addressProvider, _) {
            final address = addressProvider.deliveryAddress;
            return Row(
              children: [
                AppIcon(AppIcons.location, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Deliver to',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.normal),
                      ),
                      Text(
                        address?.shortLabel ?? 'Select delivery address',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifications, _) => Stack(
              children: [
                IconButton(
                  icon: AppIcon(AppIcons.notification),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                ),
                if (notifications.unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CountBadge(count: notifications.unreadCount),
                  ),
              ],
            ),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, _) => Stack(
              children: [
                IconButton(
                  icon: AppIcon(AppIcons.cart),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CountBadge(count: cart.itemCount),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.products.isEmpty) {
            return ErrorState(
              message: provider.errorMessage!,
              onRetry: provider.loadHomeData,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadHomeData,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchBar(),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _HomePromoCarousel(),
                ),
                const SizedBox(height: 20),
                _CategoryRow(categories: provider.categories),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _QuickActionRow(),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Matches the design's label - worth being clear in
                      // code (not to the user) that this isn't actually
                      // personalized reorder data, just the product
                      // catalog. A genuine "order again" would need to
                      // derive this from OrderProvider's real order
                      // history, which isn't wired up yet.
                      const Text('Order Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                _ProductRow(products: provider.products),
                const SizedBox(height: 8),
                const _CategoryProductRows(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Health Articles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      InkWell(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No articles/content endpoint exists in the API yet')),
                        ),
                        child: Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _HealthArticles(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductListScreen(searchQuery: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          AppIcon(AppIcons.search, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
              decoration: InputDecoration(
                filled: false,

                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,

                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: 'Search for medicines, health products...',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin wrapper supplying Home's own text/images to the shared
/// PromoCarousel widget - the carousel mechanics themselves (PageView +
/// dots) now live in core/widgets/promo_carousel.dart so Categories can
/// use the identical slider behavior, not just similar banner colors.
class _HomePromoCarousel extends StatelessWidget {
  const _HomePromoCarousel();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeBannerProvider>(
      builder: (context, provider, _) {
        if (provider.banners.isEmpty) return const SizedBox.shrink();

        return PromoCarousel(
          banners: provider.banners,
          height: 200,
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
    );
  }
}

/// Single row of 6 - matches the reference. Icons render at their own
/// natural size/color with no wrapper Container: the provided assets
/// already have their colored background square baked into the image
/// itself, so adding another background behind them would double up.
/// "View All" (the last item) opens the full product list; every real
/// category opens that same list filtered to it.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories});

  final List<Category> categories;

  static const _iconKeys = [
    AppIcons.categoryMedicines,
    AppIcons.categoryHealthcare,
    AppIcons.categoryLabTests,
    AppIcons.categoryMotherBaby,
    AppIcons.categoryFitness,
    AppIcons.categoryViewAll,
  ];
  static const _labels = ['Order Medicines', 'Healthcare', 'Lab Tests', 'Mother & Baby', 'Fitness', 'View All'];

  /// Best-effort match from this fixed 6-icon row to a real live category -
  /// live category names/ids come from whatever's actually in the
  /// catalog, which this static row can't know in advance. Same keyword
  /// set already proven in categories_screen.dart, not a naive first-word
  /// split (which would extract "order" from "Order Medicines" and match
  /// nothing, since no real category is likely named with "order" in it).
  Category? _matchingCategory(int index) {
    if (index == 5) return null; // View All - no single category

    bool nameContains(String needle) => categories.any((c) => c.name.toLowerCase().contains(needle));
    Category? firstMatching(String needle) => categories.firstWhere(
          (c) => c.name.toLowerCase().contains(needle),
          orElse: () => categories.first,
        );

    final keywords = switch (index) {
      0 => 'medic',
      1 => 'health',
      2 => 'lab',
      3 => 'mother',
      4 => 'fitness',
      _ => null,
    };

    if (keywords == null || !nameContains(keywords)) return null;
    return firstMatching(keywords);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_labels.length, (i) {
          final matched = _matchingCategory(i);
          final matchFailed = i != 2 && i != 5 && matched == null;
          return Padding(
            padding: EdgeInsets.only(right: i == _labels.length - 1 ? 0 : 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (i == 2) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LabTestsScreen()));
                  return;
                }
                if (matchFailed) {
                  // A failed match must never silently fall through to
                  // ProductListScreen's "no filter" behavior - that
                  // screen can't tell "show everything" (View All, i==5)
                  // apart from "a category filter was attempted and
                  // failed to resolve" once categoryId is null either
                  // way, so it's stopped here instead, with an honest
                  // message rather than an unfiltered list masquerading
                  // as a filtered one.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Couldn\'t find a matching category for "${_labels[i]}" right now.')),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductListScreen(
                      categoryId: matched?.id,
                      categoryName: matched?.name ?? (i == 5 ? null : _labels[i]),
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: 64,
                child: Column(
                  children: [
                    Image.asset(AppImages.homeIcons[_iconKeys[i]]!, width: 52, height: 52),
                    const SizedBox(height: 6),
                    // Fixed height reserves room for 2 lines regardless of
                    // whether this particular label needs one or two - the
                    // 5-column-wide "Mother & Baby" wrapping to 2 lines
                    // used to push that column's whole layout down relative
                    // to single-line neighbors like "Healthcare".
                    SizedBox(
                      height: 30,
                      child: Text(
                        _labels[i],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, height: 1.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Upload Prescription, Quick Delivery, and Offers all navigate to real
/// screens now - Quick Delivery goes to the full product list (a fast
/// path to ordering, no separate "express delivery" concept exists
/// on the backend), Offers goes to the global-coupons browse page.
class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: AppIcons.uploadPrescription,
            title: 'Upload\nPrescription',
            subtitle: 'Get quick medicines',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrescriptionsScreen()),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: AppIcons.quickDelivery,
            title: 'Quick\nDelivery',
            subtitle: 'On-time delivery',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: AppIcons.offers,
            title: 'Offers\nCoupons',
            subtitle: 'View all offers',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OffersScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceTint.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.2)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Horizontally-scrolling row, not a grid - the reference clearly shows a
/// 5th card cut off at the edge, meaning this scrolls rather than
/// wrapping into more rows. Each card now opens the real Product Detail
/// screen - it used to just add to cart with no way to see anything else
/// about the product first.
class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(child: Text('No products available right now.', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(width: 150, child: _ProductCard(product: products[i])),
      ),
    );
  }
}

/// One horizontal row per category, newest products first - sits between
/// "Order Again" and "Health Articles". Silently shows nothing while
/// loading or if a category has no products yet, rather than a row of
/// empty placeholders - this section is purely additive polish, not
/// something that should ever block or clutter the page.
class _CategoryProductRows extends StatelessWidget {
  const _CategoryProductRows();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final categoriesWithProducts = provider.categories.where((c) => (provider.latestByCategory[c.id]?.isNotEmpty ?? false)).toList();

        if (categoriesWithProducts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoriesWithProducts.expand((category) {
            final products = provider.latestByCategory[category.id]!;
            return [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(category.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => SizedBox(width: 150, child: _ProductCard(product: products[i])),
                ),
              ),
              const SizedBox(height: 24),
            ];
          }).toList(),
        );
      },
    );
  }
}

/// Real data now - launches the YouTube URL (app if installed, browser
/// otherwise) on tap. The old "read time" label was always fabricated
/// placeholder text matching the design mockup, not a real field - a
/// play-icon overlay replaces it, since these are videos, not articles
/// with a reading duration.
class _HealthArticles extends StatelessWidget {
  const _HealthArticles();

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthArticleProvider>(
      builder: (context, provider, _) {
        if (provider.articles.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.articles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => SizedBox(width: 200, child: _ArticleCard(article: provider.articles[i])),
          ),
        );
      },
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final HealthArticle article;

  Future<void> _openVideo(BuildContext context) async {
    final uri = Uri.parse(article.youtubeUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Couldn\'t open this video')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openVideo(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(color: AppColors.surfaceTint),
                  ),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15)),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  /// Deterministic, not random - the same product should always show the
  /// same fallback image across rebuilds/scrolls, not a different one
  /// each time the widget happens to rebuild.
  Widget _fallbackImage(int productId) {
    final fallbacks = AppImages.productFallbacks;
    final image = fallbacks[productId % fallbacks.length];
    return Image.asset(image, fit: BoxFit.contain);
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
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
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
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) => _fallbackImage(product.id),
                        )
                      : _fallbackImage(product.id),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            if (product.unit != null)
              Text(product.unit!, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(
              product.sellingPrice != null
                  ? '${AppConstants.currencySymbol}${product.sellingPrice!.toStringAsFixed(2)}'
                  : 'Price unavailable',
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
